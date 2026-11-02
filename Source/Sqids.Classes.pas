{******************************************************************************}
{                                                                              }
{  Sqids: ID Hashing Library for Delphi                                        }
{                                                                              }
{  Copyright (c) 2023 Paolo Rossi                                              }
{  https://github.com/paolo-rossi/sqids-delphi                                 }
{                                                                              }
{  Licensed under the MIT license                                              }
{                                                                              }
{******************************************************************************}
unit Sqids.Classes;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Sqids.Types, Sqids.Blocklist;

type
  // Aliases so code that only uses Sqids.Classes keeps compiling.
  // TNumbersHelper (ToString, IsEqual) needs Sqids.Types in the uses clause.
  TNumber = Sqids.Types.TNumber;
  TNumbers = Sqids.Types.TNumbers;

  /// <summary>
  /// The configuration options for <see cref="TSqids" />.
  /// Build it with one of the Create constructors. On Delphi 10.4+ a plain
  /// record variable is zero-initialized (managed record); on older versions
  /// use Default(TSqidsOptions), otherwise a local's MinLength contains garbage.
  /// An empty Alphabet falls back to the default alphabet; the Blocklist does NOT
  /// fall back (see <see cref="Blocklist" />).
  /// </summary>
  TSqidsOptions = record
    /// <summary>
    /// Custom alphabet that will be used for the IDs.
    /// Must contain at least 5 characters.
    /// The default is lowercase letters, uppercase letters, and digits.
    /// </summary>
    Alphabet: string;

    /// <summary>
    /// The minimum length for the IDs.
    /// The default is 0; meaning the IDs will be as short as possible.
    /// </summary>
    MinLength: Integer;

    /// <summary>
    /// List of blocked words that must not appear in the IDs.
    /// It replaces the default blocklist: use DefaultBlocklist + [...] to extend it.
    /// An empty list (or nil) disables the blocklist.
    /// Create(AAlphabet, AMinLength) sets it to DefaultBlocklist.
    /// </summary>
    Blocklist: TBlocklist;

    constructor Create(const AAlphabet: string; AMinLength: Integer); overload;
    constructor Create(const AAlphabet: string; AMinLength: Integer; const AList: TBlocklist); overload;
    constructor Create(const AList: TBlocklist); overload;

    {$IF CompilerVersion >= 34.0} // Delphi 10.4 Sydney: custom managed records
    class operator Initialize(out Dest: TSqidsOptions);
    {$ENDIF}
  end;

  /// <summary>
  /// The Sqids encoder/decoder. This is the main class.
  /// </summary>
  TSqids = record
  private
    FAlphabet: string;
    FAlphabetLen: Integer;
    FMinLength: Integer;
    FBlocklist: TBlocklist;
    // FBlocklistHasDigit[i] = FBlocklist[i] contains a digit (precomputed for IsBlockedID)
    FBlocklistHasDigit: TArray<Boolean>;
  private
    class function DefaultOptions: TSqidsOptions; static;
  public const
    /// <summary>
    /// The minimum numeric value that can be encoded/decoded using <see cref="TSqids" />.
    /// This is always zero across all ports of Sqids.
    /// </summary>
    MinValue: TNumber = 0;

    /// <summary>
    /// The maximum numeric value that can be encoded/decoded using <see cref="TSqids" />.
    /// It's equal to `Max UInt64`.
    /// </summary>
    MaxValue: TNumber = High(UInt64);
  private
    function Shuffle(const Alphabet: string): string;
    function EncodeNumbers(Numbers: TNumbers; Partitioned: Boolean = False): string;
    function ToID(Number: UInt64; const Alphabet: string): string;
    function ToNumber(const Id, Alphabet: string): TNumber;
    function HasUniqueChars(const Str: string): Boolean;
    function IsBlockedID(const Id: string): Boolean;

    constructor Create(const Options: TSqidsOptions);
  public
    /// <summary>
    /// Initializes a new instance of <see cref="TSqids" /> with the default options.
    /// </summary>
    class function New: TSqids; overload; static;

    /// <summary>
    /// Initializes a new instance of <see cref="TSqids" /> with custom options.
    /// </summary>
    /// <param name="Options">
    /// The custom options.
    /// All properties of <see cref="TSqidsOptions" /> are optional and will fall back to their
    /// defaults if not explicitly set.
    /// </param>
    class function New(const Options: TSqidsOptions): TSqids; overload; static;

    class function FilterBlocklist(const Alphabet: string; const Blocklist: TBlocklist): TBlocklist; static;
    class function CalculateOffset(const Alphabet: string; const Numbers: TNumbers): Integer; static;

    /// <summary>
    /// Encodes a collection of numbers into a Sqids ID.
    /// </summary>
    /// <param name="Numbers">The numbers to encode.</param>
    /// <returns>A string containing the encoded IDs, or an empty string if the array passed is empty.</returns>
    function Encode(const Numbers: TNumbers): string;

    /// <summary>
    /// Decodes an ID into numbers.
    /// </summary>
    /// <param name="Id">The encoded ID.</param>
    /// <returns>
    /// An array of integers containing the decoded number(s) (it would contain only one element
    /// if the ID represents a single number); or an empty array if the input ID is null,
    /// empty, or includes characters not found in the alphabet.
    /// </returns>
    function Decode(Id: string): TNumbers;

    /// <summary>
    /// Encodes a single number into a Sqids ID.
    /// </summary>
    /// <param name="Number">The number to encode.</param>
    /// <returns>A string containing the encoded ID.</returns>
    function EncodeSingle(Number: TNumber): string;

    /// <summary>
    ///   Decodes a Sqids ID into a sigle number
    /// </summary>
    /// <param name="Id">
    ///   The string ID to decode
    /// </param>
    /// <returns>
    ///   A sigle number represented by the ID
    /// </returns>
    /// <remarks>
    ///   You must be sure that the ID represent a single number, given that
    ///   the function tries to decode the ID and then picks the first element
    ///   (if any) of the array
    /// </remarks>
    function DecodeSingle(const Id: string): TNumber;
  end;

  PSqids = ^TSqids;


implementation

{ TSquids }

constructor TSqids.Create(const Options: TSqidsOptions);
begin
  FAlphabet := Options.Alphabet;
  if FAlphabet.IsEmpty then
    FAlphabet := DefaultOptions.Alphabet;

  FAlphabet := Shuffle(FAlphabet);
  FAlphabetLen := Length(FAlphabet);

  FMinLength := Options.MinLength;

	// check that the alphabet does not contain multibyte characters
	for var c in FAlphabet do
		if Ord(c) > 127 then
			raise Exception.Create('alphabet must not contain any multibyte characters');

	// check the length of the alphabet
	if FAlphabetLen < 5 then
		raise Exception.Create('alphabet length must be at least 5');

	// check that the alphabet has only unique characters
	if not HasUniqueChars(FAlphabet) then
		raise Exception.Create('alphabet must contain unique characters');

	// test min length (type [might be lang-specific] + min length + max length)
	if (FMinLength < int(MinValue)) or (FMinLength > Length(FAlphabet)) then
		raise Exception.CreateFmt('minimum length has to be between %d and %d', [MinValue, Length(FAlphabet)]);

  FBlocklist := FilterBlocklist(FAlphabet, Options.Blocklist);

  SetLength(FBlocklistHasDigit, Length(FBlocklist));
  for var i := 0 to High(FBlocklist) do
  begin
    FBlocklistHasDigit[i] := False;
    for var c in FBlocklist[i] do
      if CharInSet(c, ['0'..'9']) then
      begin
        FBlocklistHasDigit[i] := True;
        Break;
      end;
  end;
end;

class function TSqids.FilterBlocklist(const Alphabet: string; const Blocklist: TBlocklist): TBlocklist;
begin
	// clean up blocklist:
	// 1. all blocklist words should be lowercase
	// 2. no words less than 3 chars
	// 3. if some words contain chars that are not in the alphabet, remove those
	Result := [];
	var lowerAlphabet := Alphabet.ToLower;
  for var word in Blocklist do
  begin
		if Length(word) >= 3 then
    begin
			var lowerWord := word.ToLower;
			var allInAlphabet := True;
			for var c in lowerWord do
				if lowerAlphabet.IndexOf(c) < 0 then
				begin
					allInAlphabet := False;
					Break;
				end;
			if allInAlphabet then
        Result := Result + [lowerWord];
    end;
  end;
end;

class function TSqids.CalculateOffset(const Alphabet: string; const Numbers: TNumbers): Integer;
begin
	Result := Length(Numbers);
	var len := Length(Alphabet);

	if (Result = 0) or (len = 0) then
		Exit(-1);

	for var i := 0 to Length(Numbers) - 1 do
  begin
		Result := Result + Ord(Alphabet.Chars[Numbers[i] mod UInt64(len)]) + i;
  end;
	Result := Result mod len;
end;

class function TSqids.DefaultOptions: TSqidsOptions;
begin
  Result.Alphabet := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Result.MinLength := 0;
  Result.Blocklist := nil;
end;

function TSqids.Decode(Id: string): TNumbers;
begin
	Result := [];

	if id = '' then
		Exit(Result);

  for var c in id do
    if not FAlphabet.Contains(c) then
      Exit(Result);

	var prefix := id.Chars[0];
	var offset := FAlphabet.IndexOf(prefix);
  var alphabet := TSlice.CopyString(FAlphabet, offset, TSlice.Last) + TSlice.CopyString(FAlphabet, TSlice.Start, offset);
	var partition := alphabet.Chars[1];
	alphabet := TSlice.CopyString(alphabet, 2, TSlice.Last);
  id := TSlice.CopyString(id, 1, TSlice.Last);

	var partitionIndex := id.IndexOf(partition);
	if (partitionIndex > 0) and (partitionIndex < (Length(id)-1)) then
  begin
		id := TSlice.CopyString(id, partitionIndex+1, TSlice.Last);
		alphabet := Shuffle(alphabet);
  end;

  while Length(id) > 0 do
  begin
		var separator := alphabet.Chars[Length(alphabet)-1];
		var chunks := id.Split([separator]);

    if Length(chunks) > 0 then
    begin
			var alphabetWithoutSeparator := TSlice.CopyString(alphabet, TSlice.Start, Length(alphabet)-1);

      if chunks[0] = '' then
        Exit(nil);

      for var c in chunks[0] do
        if not alphabetWithoutSeparator.Contains(c) then
          Exit(nil);

      Result := Result + [ToNumber(chunks[0], alphabetWithoutSeparator)];

			if Length(chunks) > 1 then
				alphabet := Shuffle(alphabet);
    end;

    chunks := TSlice.CopySlice<string>(chunks, 1, TSlice.Last);
    id := string.Join(separator, chunks);
  end;
end;

function TSqids.DecodeSingle(const Id: string): TNumber;
begin
  var LResult := Decode(ID);

  if Length(LResult) = 0 then
    raise Exception.Create('can''t decode the ID');

  if Length(LResult) > 1 then
    raise Exception.Create('produced more than one number');

  Result := LResult[0]
end;

function TSqids.EncodeSingle(Number: TNumber): string;
begin
  Result := Encode([Number]);
end;

function TSqids.Encode(const Numbers: TNumbers): string;
begin
	if Length(numbers) = 0 then
		Exit('');

	// No range check: TNumber is UInt64, so every value is already within
	// [MinValue, MaxValue]. Pass a copy so EncodeNumbers can never modify
	// the caller's array.
	Result := EncodeNumbers(Copy(Numbers), False);
end;

function TSqids.EncodeNumbers(Numbers: TNumbers; Partitioned: Boolean): string;
begin
	var offset := CalculateOffset(FAlphabet, Numbers);

  var alphabet := TSlice.CopyString(FAlphabet, offset, TSlice.Last) + TSlice.CopyString(FAlphabet, TSlice.Start, offset);
	var prefix := alphabet.Chars[0];
	var partition := alphabet.Chars[1];
	alphabet :=  TSlice.CopyString(alphabet, 2, TSlice.Last);

  var ret: string := prefix;

	for var j := 0 to Length(Numbers) - 1 do
  begin
		var alphabetWithoutSeparator := TSlice.CopyString(alphabet, TSlice.Start, Length(alphabet)-1);
		ret := ret + ToID(Numbers[j], alphabetWithoutSeparator);

		if j < Length(Numbers) - 1 then
    begin
			var separator: Char;
			if partitioned and (j = 0) then
				separator := partition
			else
				separator := alphabet.Chars[Length(alphabet)-1];

			ret := ret + separator;
			alphabet := shuffle(alphabet);
		end;
  end;

  var id := ret;

	if FMinLength > Length(id) then
  begin
		if not partitioned then
    begin
      numbers := [0] + numbers;
			id := EncodeNumbers(numbers, True);
		end;

    if FMinLength > Length(id) then
			id := TSlice.CopyString(id, TSlice.Start, 1) +
        TSlice.CopyString(alphabet, TSlice.Start, FMinLength - Length(id)) +
        TSlice.CopyString(id, 1, TSlice.Last);
  end;

  // Gestione Blocklist
	if isBlockedID(id) then
  begin
		if partitioned then
    begin
			if numbers[0] + 1 > MaxValue then
        raise Exception.Create('ran out of range checking against the blocklist');
			numbers[0] := numbers[0] + 1;
    end else
			numbers := [0] + numbers;

		id := EncodeNumbers(numbers, true);
  end;

  Result := id;
end;

function TSqids.HasUniqueChars(const Str: string): Boolean;
begin
  Result := True;
	var chars := TDictionary<Char, Boolean>.Create;
  try
    for var c in str do
    begin
      if chars.ContainsKey(c) then
        Exit(False);
      chars.Add(c, True);
    end;
  finally
    chars.Free;
  end;
end;

function TSqids.IsBlockedID(const Id: string): Boolean;
begin
	var lowerId := string.LowerCase(Id);

  Result := False;
	for var i := 0 to High(FBlocklist) do
  begin
		var word := FBlocklist[i];
		if Length(word) <= Length(lowerId) then
    begin
			if (Length(lowerId) <= 3) or (Length(word) <= 3) then
      begin
				if lowerId = word then
					Exit(True);
			end else if FBlocklistHasDigit[i] then
      begin
				if lowerId.StartsWith(word) or lowerId.EndsWith(word) then
					Exit(True)
			end else if lowerId.Contains(word) then
				Exit(True);
    end;
  end;
end;

class function TSqids.New(const Options: TSqidsOptions): TSqids;
begin
  Result := TSqids.Create(Options);
end;

function TSqids.Shuffle(const Alphabet: string): string;
begin
  var len := Alphabet.Length;
  if len = 0 then
    Exit('');

	var chars := Alphabet.ToCharArray;

  var i := 0;
  var j := len - 1;

  while j > 0 do
  begin
    var r := (i * j + Ord(chars[i]) + Ord(chars[j])) mod len;
    var c := chars[i];
    chars[i] := chars[r];
    chars[r] := c;

    i := i+1; j := j-1;
  end;
  SetString(Result, PChar(@chars[0]), Length(chars));
end;

function TSqids.ToID(Number: UInt64; const Alphabet: string): string;
begin
  Result := '';
  var len: UInt64 := Length(Alphabet);
  repeat
    var index := number mod len;
    Result := Alphabet.Chars[index] + Result;
    number := number div len;
  until number = 0;
end;

function TSqids.ToNumber(const Id, Alphabet: string): TNumber;
begin
	Result := 0;
  var len: UInt64 := Alphabet.Length;

	for var c in id do
		Result := Result * len + UInt64(Alphabet.IndexOf(c));
end;

class function TSqids.New: TSqids;
begin
  Result := TSqids.Create(TSqidsOptions.Create(DefaultOptions.Alphabet, DefaultOptions.MinLength));
end;

{ TSqidsOptions }

{$IF CompilerVersion >= 34.0}
class operator TSqidsOptions.Initialize(out Dest: TSqidsOptions);
begin
  Dest.Alphabet := '';
  Dest.MinLength := 0;
  Dest.Blocklist := nil;
end;
{$ENDIF}

constructor TSqidsOptions.Create(const AAlphabet: string; AMinLength: Integer);
begin
  Create(AAlphabet, AMinLength, DefaultBlocklist);
end;

constructor TSqidsOptions.Create(const AAlphabet: string; AMinLength: Integer; const AList: TBlocklist);
begin
  Alphabet := AAlphabet;
  MinLength := AMinLength;
  Blocklist := AList;
end;

constructor TSqidsOptions.Create(const AList: TBlocklist);
begin
  Alphabet := '';
  MinLength := 0;
  Blocklist := AList;
end;

end.
