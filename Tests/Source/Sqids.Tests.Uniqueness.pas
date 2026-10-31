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
unit Sqids.Tests.Uniqueness;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections, DUnitX.TestFramework,

  Sqids.Classes;

type
  [TestFixture]
  [Category('uniqueness')]
  TTestUniqueness = class(TObject)
  private const
    DEFAULT_ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    UPPER = 10_000;
    ERR_DECODING = 'Decoding %s should produce %s, but instead produced %s';
  private
    procedure CheckUniques(const ASqids: TSqids; Start: TNumber; Count: Integer);
  public
    constructor Create;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestUniquesWithPadding;

    [Test]
    procedure TestUniquesLowRanges;

    [Test]
    procedure TestUniquesHighRanges;

    [Test]
    procedure TestUniquesMulti;

  end;

implementation

constructor TTestUniqueness.Create;
begin
end;

procedure TTestUniqueness.Setup;
begin
end;

procedure TTestUniqueness.TearDown;
begin
end;

procedure TTestUniqueness.CheckUniques(const ASqids: TSqids; Start: TNumber; Count: Integer);
begin
  var s := ASqids;
  var set_ := TDictionary<string, Boolean>.Create;
  try
    for var i := Start to Start + TNumber(Count) - 1 do
    begin
      var numbers: TNumbers := [i];
      var id := s.Encode(numbers);
      set_.AddOrSetValue(id, True);

      var decodedNumbers := s.Decode(id);
      if not numbers.IsEqual(decodedNumbers) then
        Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
    end;

    if set_.Count <> Count then
      Assert.Fail('Invalid set count');
  finally
    set_.Free;
  end;
end;

procedure TTestUniqueness.TestUniquesWithPadding;
begin
  var options := TSqidsOptions.Create('', Length(DEFAULT_ALPHABET));
	var s := TSqids.New(options);

  CheckUniques(s, 0, UPPER);
end;

procedure TTestUniqueness.TestUniquesLowRanges;
begin
	var s := TSqids.New();

  CheckUniques(s, 0, UPPER);
end;

procedure TTestUniqueness.TestUniquesHighRanges;
begin
	var s := TSqids.New();

  CheckUniques(s, 100_000_000, UPPER);
end;

procedure TTestUniqueness.TestUniquesMulti;
begin
	var s := TSqids.New();

  var set_ := TDictionary<string, Boolean>.Create;
  try
    for var i: TNumber := 0 to UPPER - 1 do
    begin
      var numbers: TNumbers := [i, i, i, i, i];
      var id := s.Encode(numbers);
      set_.AddOrSetValue(id, True);

      var decodedNumbers := s.Decode(id);
      if not numbers.IsEqual(decodedNumbers) then
        Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
    end;

    if set_.Count <> UPPER then
      Assert.Fail('Invalid set count');
  finally
    set_.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUniqueness);

end.
