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
unit Sqids.Tests.MinLength;

interface

uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework,

  Sqids.Types, Sqids.Classes;

type
  [TestFixture]
  [Category('minlength')]
  TTestMinLength = class(TObject)
  private const
    DEFAULT_ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    ERR_DECODING = 'Decoding %s should produce %s, but instead produced %s';
    ERR_ENCODING = 'Encoding %s should produce %s, but instead produced %s';
  public
    constructor Create;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestMinLengthSimple', '[1,2,3];86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM', ';')]
    procedure TestMinLengthSimple(Numbers: TNumbers; const Id: string);

    [Test]
    [TestCase('0_0', 'SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu;[0,0]', ';')]
    [TestCase('0_1', 'n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc;[0,1]', ';')]
    [TestCase('0_2', 'tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ;[0,2]', ';')]
    [TestCase('0_3', 'eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE;[0,3]', ';')]
    [TestCase('0_4', 'rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX;[0,4]', ';')]
    [TestCase('0_5', 'sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2;[0,5]', ';')]
    [TestCase('0_6', 'uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0;[0,6]', ';')]
    [TestCase('0_7', '74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy;[0,7]', ';')]
    [TestCase('0_8', '30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS;[0,8]', ';')]
    [TestCase('0_9', 'moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin;[0,9]', ';')]
    procedure TestMinLengthIncrementalNumbers(const Id: string; Numbers: TNumbers);

    [Test]
    [TestCase('MinLength6', '6;86Rf07', ';')]
    [TestCase('MinLength7', '7;86Rf07x', ';')]
    [TestCase('MinLength8', '8;86Rf07xd', ';')]
    [TestCase('MinLength9', '9;86Rf07xd4', ';')]
    [TestCase('MinLength10', '10;86Rf07xd4z', ';')]
    [TestCase('MinLength11', '11;86Rf07xd4zB', ';')]
    [TestCase('MinLength12', '12;86Rf07xd4zBm', ';')]
    [TestCase('MinLength13', '13;86Rf07xd4zBmi', ';')]
    [TestCase('MinLength62', '62;86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM', ';')]
    [TestCase('MinLength63', '63;86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy', ';')]
    [TestCase('MinLength64', '64;86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf', ';')]
    [TestCase('MinLength65', '65;86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1', ';')]
    procedure TestMinLengthIncremental(MinLength: Integer; const Id: string);

    [Test]
    procedure TestMinLengths;

    [Test]
    procedure TestOutOfRangeInvalidMinLength;

    {$IF CompilerVersion >= 34.0}
    [Test]
    procedure TestUninitializedOptionsDefaultToZero;
    {$ENDIF}

  end;

implementation

constructor TTestMinLength.Create;
begin
end;

procedure TTestMinLength.Setup;
begin
end;

procedure TTestMinLength.TearDown;
begin
end;

procedure TTestMinLength.TestMinLengthSimple(Numbers: TNumbers; const Id: string);
begin
  var options := TSqidsOptions.Create('', Length(DEFAULT_ALPHABET));
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestMinLength.TestMinLengthIncrementalNumbers(const Id: string; Numbers: TNumbers);
begin
  var options := TSqidsOptions.Create('', Length(DEFAULT_ALPHABET));
	var s := TSqids.New(options);

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestMinLength.TestMinLengthIncremental(MinLength: Integer; const Id: string);
begin
  var numbers: TNumbers := [1, 2, 3];
  var s := TSqids.New(TSqidsOptions.Create('', MinLength));

  var generatedID := s.Encode(numbers);
  if id <> generatedID then
    Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

  if Length(generatedID) <> MinLength then
    Assert.FailFmt('Encoding %s should produce %d length, but produced %d length instead',
      [numbers.ToString, MinLength, Length(generatedID)]);

  var decodedNumbers := s.Decode(id);
  if not numbers.IsEqual(decodedNumbers) then
    Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestMinLength.TestMinLengths;
begin
  var minLengths: TArray<Integer> := [0, 1, 5, 10, Length(DEFAULT_ALPHABET)];
  var numbersList: TArray<TNumbers> := [
    [TSqids.MinValue],
    [0, 0, 0, 0, 0],
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    [100, 200, 300],
    [1000, 2000, 3000],
    [1000000],
    [TSqids.MaxValue]
  ];

  for var minLength in minLengths do
    for var numbers in numbersList do
    begin
      var options := TSqidsOptions.Create('', minLength);
      var s := TSqids.New(options);

      var generatedID := s.Encode(numbers);
      if Length(generatedID) < minLength then
        Assert.FailFmt('Encoding %s with min length %d produced %s', [numbers.ToString, minLength, generatedID]);

      var decodedNumbers := s.Decode(generatedID);
      if not numbers.IsEqual(decodedNumbers) then
        Assert.FailFmt(ERR_DECODING, [generatedID, numbers.ToString, decodedNumbers.ToString]);
    end;
end;

procedure TTestMinLength.TestOutOfRangeInvalidMinLength;
begin
  Assert.WillRaise(
    procedure
    begin
      TSqids.New(TSqidsOptions.Create('', -1));
    end,
    Exception, 'Should not allow out of range min length');

  Assert.WillRaise(
    procedure
    begin
      TSqids.New(TSqidsOptions.Create('', TSqids.MaxMinLength + 1));
    end,
    Exception, 'Should not allow out of range min length');
end;

{$IF CompilerVersion >= 34.0}
procedure TTestMinLength.TestUninitializedOptionsDefaultToZero;
var
  options: TSqidsOptions; // deliberately not built via Create
begin
  Assert.AreEqual(0, options.MinLength, 'MinLength of a plain TSqidsOptions local must be 0');
  Assert.IsEmpty(options.Alphabet);
  Assert.IsTrue(options.Blocklist = nil);

  options.Alphabet := DEFAULT_ALPHABET;
  var s := TSqids.New(options);
  var id := s.Encode([1, 2, 3]);
  Assert.AreEqual(TSqids.New.Encode([1, 2, 3]), id);
end;
{$ENDIF}

initialization
  TDUnitX.RegisterTestFixture(TTestMinLength);

end.
