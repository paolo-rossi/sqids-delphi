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
unit Sqids.Types;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  TNumber = UInt64;
  TNumbers = TArray<TNumber>;
  TNumbersHelper = record helper for TNumbers
  public
    function ToString(): string;
    function IsEqual(Other: TNumbers): Boolean;
  end;


  /// <summary>
  ///   Utility class to emulate (as much as possible) golang slices
  /// </summary>
  TSlice = class
  public const
    Start = 0;
    Last = -1;
  public
    class function CopySlice<T>(const Slice: TArray<T>; StartIndex, EndIndex: Integer): TArray<T>; static;
    class function CopyString(const Slice: string; StartIndex, EndIndex: Integer): string; static;
    class function Intersection<T>(const Slice1, Slice2: TArray<T>): TArray<T>; static;

    /// <summary>
    ///   Only for simple types (not classes or records)
    /// </summary>
    class function DeepEqual<T>(const Slice1, Slice2: TArray<T>): Boolean; static;
  end;

implementation

{ TNumbersHelper }

function TNumbersHelper.IsEqual(Other: TNumbers): Boolean;
begin
	if (Self = nil) or (Other = nil) then
		Exit(Self = Other);

  if Length(Self) <> Length(Other) then
    Exit(False);

  for var i := 0 to Length(Self) - 1 do
  begin
    if Self[i] <> Other[i] then
      Exit(False);
  end;
  Result := True;
end;

function TNumbersHelper.ToString: string;
begin
  Result := '[';
  for var num in Self do
    Result := Result + num.ToString + ', ';

  Result := Result.Remove(Length(Result) -2) + ']';
end;

class function TSlice.CopySlice<T>(const Slice: TArray<T>; StartIndex, EndIndex: Integer): TArray<T>;
begin
  if EndIndex = TSlice.Last then
    EndIndex := Length(Slice);

  Result := Copy(Slice, StartIndex, EndIndex - StartIndex);
end;

class function TSlice.CopyString(const Slice: string; StartIndex,
    EndIndex: Integer): string;
begin
  if EndIndex = TSlice.Last then
    EndIndex := Length(Slice);

  Result := Slice.Substring(StartIndex, EndIndex - StartIndex);
end;

class function TSlice.DeepEqual<T>(const Slice1, Slice2: TArray<T>): Boolean;
begin
	if (Slice1 = nil) or (Slice2 = nil) then
		Exit(Slice1 = Slice2);

  if Length(Slice1) <> Length(Slice2) then
    Exit(False);

  var comparer := TEqualityComparer<T>.Default;
  for var i := 0 to Length(Slice1) - 1 do
    if not comparer.Equals(Slice1[i], Slice2[i]) then
      Exit(False);

  Result := True;
end;

class function TSlice.Intersection<T>(const Slice1, Slice2: TArray<T>): TArray<T>;
begin
  Result := [];
  var intersectionSet := TDictionary<T, Boolean>.Create;
  try
    for var el in Slice2 do
      intersectionSet.AddOrSetValue(el, True);

    for var el in Slice1 do
      if intersectionSet.ContainsKey(el) then
        Result := Result + [el];
  finally
    intersectionSet.Free;
  end;
end;

end.
