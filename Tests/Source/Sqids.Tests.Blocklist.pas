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
unit Sqids.Tests.Blocklist;

interface

//{$R+,O+}

uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework,

  Sqids.Types, Sqids.Classes,
  Sqids.Blocklist;

type
  [TestFixture]
  [Category('blocklist')]
  TTestBlocklist = class(TObject)
  private const
    ERR_DECODING = 'Decoding %s should produce %s, but instead produced %s';
    ERR_ENCODING = 'Encoding %s should produce %s, but instead produced %s';
  public
    constructor Create;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestBlocklistDefault', '[4572721],aho1e,JExTR')]
    procedure TestBlocklistDefault(Numbers: TNumbers; const BlockedID, UnblockedID: string);

    [Test]
    [TestCase('TestBlocklistEmpty', '[4572721],aho1e,[]')]
    procedure TestBlocklistEmpty(Numbers: TNumbers; const Id: string; const List: TBlocklist);

    [Test]
    [TestCase('TestBlocklistNotEmpty', '[4572721],aho1e,QyG4,[ArUO]')]
    procedure TestBlocklistNotEmpty(Numbers: TNumbers; const Id, ExpectedId: string; const List: TBlocklist);

    [Test]
    [TestCase('TestBlocklist', '[1000000,2000000];1aYeB7bRUt', ';')]
    procedure TestBlocklist(Numbers: TNumbers; const Id: string);

    [Test]
    [TestCase('TestDecodingBlocklistedIDs', '[1,2,3];[86Rf07,se8ojk,ARsz1p,Q8AI49,5sQRZO]', ';')]
    procedure TestDecodingBlocklistedIDs(Numbers: TNumbers; const List: TBlocklist);

    [Test]
    [TestCase('TestShortBlocklistMatch', '[1000];[pnd]', ';')]
    procedure TestShortBlocklistMatch(Numbers: TNumbers; const List: TBlocklist);

    [Test]
    procedure TestBlocklistFunction;

    [Test]
    [TestCase('TestUpperCaseAlphabetBlocklistFiltering', '[1,2,3];IBSHOZ;ABCDEFGHIJKLMNOPQRSTUVWXYZ;[sxnzkl]', ';')]
    procedure TestUpperCaseAlphabetBlocklistFiltering(Numbers: TNumbers; const Id, Alphabet: string; const List: TBlocklist);

    [Test]
    [TestCase('NoWordsLessThan3Chars', 'YESNO;[yes,no];yes', ';')]
    [TestCase('RemoveWordsNotInAlphabet', 'YESNO;[yes,nope];yes', ';')]
    procedure TestFilterBlocklist(const Alphabet: string; const List: TBlocklist; const Expected: string);

    [Test]
    procedure TestMaxEncodingAttempts;

  end;

implementation

constructor TTestBlocklist.Create;
begin
end;

procedure TTestBlocklist.Setup;
begin
end;

procedure TTestBlocklist.TearDown;
begin
end;

procedure TTestBlocklist.TestBlocklist(Numbers: TNumbers; const Id: string);
begin
  var options := TSqidsOptions.Create([
    'JSwXFaosAN', // normal result of 1st encoding, let's block that word on purpose
    'OCjV9JK64o', // result of 2nd encoding
    'rBHf',       // result of 3rd encoding is '4rBHfOiqd3', let's block a substring
    '79SM',       // result of 4th encoding is 'dyhgw479SM', let's block the postfix
    '7tE6'        // result of 4th encoding is '7tE6jdAHLe', let's block the prefix
  ]);
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(generatedID);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestBlocklist.TestBlocklistDefault(Numbers: TNumbers; const BlockedID, UnblockedID: string);
begin
  var s := TSqids.New();
	var decodedNumbers := s.Decode(BlockedID);

	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [BlockedID, numbers.ToString, decodedNumbers.ToString]);

	var generatedID := s.Encode(numbers);

	if unblockedID <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, unblockedID, generatedID]);
end;

procedure TTestBlocklist.TestBlocklistEmpty(Numbers: TNumbers; const Id: string;
  const List: TBlocklist);
begin
  var options := TSqidsOptions.Create(List);
	var s := TSqids.New(options);

	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);
end;

procedure TTestBlocklist.TestDecodingBlocklistedIDs(Numbers: TNumbers; const List: TBlocklist);
begin
  var options := TSqidsOptions.Create(List);
	var s := TSqids.New(options);

  for var id in List do
  begin
    var decodedNumbers := s.Decode(id);
    if not decodedNumbers.IsEqual(numbers) then
      Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
  end;
end;

procedure TTestBlocklist.TestBlocklistNotEmpty(Numbers: TNumbers;
  const Id, ExpectedId: string; const List: TBlocklist);
begin
  var options := TSqidsOptions.Create(List);
	var s := TSqids.New(options);

	// make sure we don't use the default blocklist
	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

  var expectedNumbers: TNumbers := [100_000];
	// make sure we are using the passed blocklist
	decodedNumbers := s.Decode(List[0]);
  if not decodedNumbers.IsEqual(expectedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [List[0], expectedNumbers.ToString, decodedNumbers.ToString]);

	generatedID := s.Encode(expectedNumbers);
	if generatedID <> expectedId then
		Assert.FailFmt(ERR_ENCODING, [expectedNumbers.ToString, ExpectedId, generatedID]);

	decodedNumbers := s.Decode(ExpectedId);
	if not decodedNumbers.IsEqual(expectedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [ExpectedId, expectedNumbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestBlocklist.TestShortBlocklistMatch(Numbers: TNumbers; const List: TBlocklist);
begin
  var options := TSqidsOptions.Create(List);
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	var decodedNumbers := s.Decode(generatedID);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [generatedID, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestBlocklist.TestBlocklistFunction;
begin
  var defaultList := Blocklist([]);
  var customList := Blocklist(['custom1', 'custom2']);

	if Length(defaultList) <> Length(DefaultBlocklist) then
  	Assert.FailFmt('Length(defaultBlocklist) = %d, want %d', [Length(defaultList), Length(DefaultBlocklist)]);

	if Length(customList) <> Length(defaultList) + 2 then
  	Assert.FailFmt('Length(customBlocklist) = %d, want %d', [Length(customList), Length(defaultList) + 2]);
end;

procedure TTestBlocklist.TestUpperCaseAlphabetBlocklistFiltering(Numbers: TNumbers;
  const Id, Alphabet: string; const List: TBlocklist);
begin
  var options := TSqidsOptions.Create(Alphabet, 0, List);
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	var decodedNumbers := s.Decode(id);

	// without blocklist, would've been "SXNZKL"
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [generatedID, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestBlocklist.TestFilterBlocklist(const Alphabet: string;
  const List: TBlocklist; const Expected: string);
begin
  var filtered := TSqids.FilterBlocklist(Alphabet, List);

	if Length(filtered) <> 1 then
  	Assert.FailFmt('Length(filtered) = %d, want %d', [Length(filtered), 1]);

	if filtered[0] <> Expected then
  	Assert.FailFmt('filtered[0] = %s, want %s', [filtered[0], Expected]);
end;

procedure TTestBlocklist.TestMaxEncodingAttempts;
begin
  var alphabet := 'abc';
  var minLength := 3;
  var blocklist: TBlocklist := ['cab', 'abc', 'bca'];

  var s := TSqids.New(TSqidsOptions.Create(alphabet, minLength, blocklist));

  if (Length(alphabet) <> minLength) or (Length(blocklist) <> minLength) then
    Assert.Fail('TestMaxEncodingAttempts is not setup properly');

  Assert.WillRaise(
    procedure
    begin
      s.Encode([0]);
    end,
    Exception, 'Should throw error about max regeneration attempts');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestBlocklist);

end.
