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
unit Sqids.Tests.Sqids;

interface

uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework,

  Sqids.Classes;

const
  DEFAULT_ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

type
  [TestFixture]
  [Category('slice')]
  TTestSlice = class(TObject)
  public
    [Test]
    procedure TestDeepEqualSameValues;
    [Test]
    procedure TestDeepEqualDifferentValues;
    [Test]
    procedure TestDeepEqualDifferentLengths;
    [Test]
    procedure TestDeepEqualEmpty;
    [Test]
    procedure TestDeepEqualStrings;
  end;

  [TestFixture]
  [Category('sqids')]
  TTestSqids = class(TObject)
  public
    constructor Create;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestMinValue;

    [Test]
    procedure TestMaxValue;

    [Test]
    [TestCase('1', ';[];-1', ';')]
    [TestCase('2', ';[0];-1', ';')]
    [TestCase('3', 'abcde;[0];3', ';')]
    [TestCase('4', 'fghij;[0];3', ';')]
    [TestCase('5', 'abcde;[1];4', ';')]
    [TestCase('6', 'abcde;[2];0', ';')]
    [TestCase('7', DEFAULT_ALPHABET + ';[24];60', ';')]
    [TestCase('8', DEFAULT_ALPHABET + ';[25];61', ';')]
    [TestCase('9', DEFAULT_ALPHABET + ';[26];4', ';')]
    [TestCase('10', DEFAULT_ALPHABET + ';[27];5', ';')]
    [TestCase('11', DEFAULT_ALPHABET + ';[1,2,3];55', ';')]
    [TestCase('12', DEFAULT_ALPHABET + ';[4,5,6];2', ';')]
    procedure TestCalculateOffset(const Alphabet: string; Numbers: TNumbers; Want: Integer);

    [Test]
    procedure TestDecode;

  end;

implementation

constructor TTestSqids.Create;
begin
end;

procedure TTestSqids.Setup;
begin
end;

procedure TTestSqids.TearDown;
begin
end;

procedure TTestSqids.TestMinValue;
begin
  if TSqids.MinValue <> 0 then
    Assert.FailFmt('MinValue = %s, want %s', [UIntToStr(TSqids.MinValue), '0']);
end;

procedure TTestSqids.TestMaxValue;
begin
  if TSqids.MaxValue <> 18446744073709551615 then
    Assert.FailFmt('MaxValue = %s, want %s', [UIntToStr(TSqids.MaxValue), '18446744073709551615']);
end;

procedure TTestSqids.TestCalculateOffset(const Alphabet: string; Numbers: TNumbers; Want: Integer);
begin
  var options := TSqidsOptions.Create(Alphabet, 0);
	TSqids.New(options);

  var got := TSqids.CalculateOffset(Alphabet, Numbers);
  if got <> Want then
    Assert.FailFmt('CalculateOffset(%s, %s) = %d, want %d', [Alphabet, Numbers.ToString, got, Want]);
end;

procedure TTestSqids.TestDecode;
begin
	var s := TSqids.New();

  if Length(s.Decode('Re')) <> 0 then
    Assert.FailFmt('Length(s.Decode("Re")) = %d, want %d', [Length(s.Decode('Re')), 0]);

  if Length(s.Decode('U9')) <> 1 then
    Assert.FailFmt('Length(s.Decode("U9")) = %d, want %d', [Length(s.Decode('U9')), 1]);
end;

{ TTestSlice }

procedure TTestSlice.TestDeepEqualSameValues;
begin
  Assert.IsTrue(TSlice.DeepEqual<UInt64>([1, 2, 3], [1, 2, 3]));
end;

procedure TTestSlice.TestDeepEqualDifferentValues;
begin
  Assert.IsFalse(TSlice.DeepEqual<UInt64>([1, 2, 3], [4, 5, 6]));
  Assert.IsFalse(TSlice.DeepEqual<UInt64>([1, 2, 3], [1, 2, 4]));
end;

procedure TTestSlice.TestDeepEqualDifferentLengths;
begin
  Assert.IsFalse(TSlice.DeepEqual<UInt64>([1, 2], [1, 2, 3]));
  Assert.IsFalse(TSlice.DeepEqual<UInt64>([], [1]));
end;

procedure TTestSlice.TestDeepEqualEmpty;
begin
  Assert.IsTrue(TSlice.DeepEqual<UInt64>([], []));
end;

procedure TTestSlice.TestDeepEqualStrings;
begin
  Assert.IsTrue(TSlice.DeepEqual<string>(['ab', 'cd'], ['ab', 'cd']));
  Assert.IsFalse(TSlice.DeepEqual<string>(['ab', 'cd'], ['ab', 'CD']));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSlice);
  TDUnitX.RegisterTestFixture(TTestSqids);

end.
