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
unit Sqids.Tests.Alphabet;

interface

uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework,

  Sqids.Types, Sqids.Classes;

type
  [TestFixture]
  [Category('alphabet')]
  TTestAlphabet = class(TObject)
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
    procedure TestMultibyteAlphabet;

    [Test]
    [TestCase('TestAlphabetSimple', '[1,2,3];4d9fd2;0123456789abcdef', ';')]
    procedure TestAlphabetSimple(Numbers: TNumbers; const Id, Alphabet: string);

    [Test]
    [TestCase('TestAlphabetShort', '[1,2,3];abcde', ';')]
    procedure TestAlphabetShort(Numbers: TNumbers; const Alphabet: string);

    [Test]
    procedure TestAlphabetLong;

    [Test]
    [TestCase('TestRepeatingAlphabetCharacters', 'aabcdefg')]
    procedure TestRepeatingAlphabetCharacters(const Alphabet: string);

    [Test]
    [TestCase('TestTooShortOfAnAlphabet', 'abcd')]
    procedure TestTooShortOfAnAlphabet(const Alphabet: string);

  end;

implementation

constructor TTestAlphabet.Create;
begin
end;

procedure TTestAlphabet.Setup;
begin
end;

procedure TTestAlphabet.TearDown;
begin
end;

procedure TTestAlphabet.TestMultibyteAlphabet;
begin
  Assert.WillRaise(
    procedure
    begin
      TSqids.New(TSqidsOptions.Create(#$00EB'1092', 0));
    end,
    Exception);
end;

procedure TTestAlphabet.TestAlphabetSimple(Numbers: TNumbers; const Id, Alphabet: string);
begin
  var options := TSqidsOptions.Create(Alphabet, 0);
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(generatedID);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestAlphabet.TestAlphabetShort(Numbers: TNumbers; const Alphabet: string);
begin
  var options := TSqidsOptions.Create(Alphabet, 0);
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	var decodedNumbers := s.Decode(generatedID);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [generatedID, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestAlphabet.TestAlphabetLong;
begin
  var options := TSqidsOptions.Create('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:''"/?.>,<`~', 0);
	var s := TSqids.New(options);

  var numbers: TNumbers := [1, 2, 3];

	var generatedID := s.Encode(numbers);
	var decodedNumbers := s.Decode(generatedID);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [generatedID, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestAlphabet.TestRepeatingAlphabetCharacters(const Alphabet: string);
begin
  Assert.WillRaise(
    procedure
    begin
      TSqids.New(TSqidsOptions.Create(Alphabet, 0));
    end,
    Exception, 'Should not accept alphabet with repeating characters');
end;

procedure TTestAlphabet.TestTooShortOfAnAlphabet(const Alphabet: string);
begin
  Assert.WillRaise(
    procedure
    begin
      TSqids.New(TSqidsOptions.Create(Alphabet, 0));
    end,
    Exception, 'Should not accept too short of an alphabet');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAlphabet);

end.
