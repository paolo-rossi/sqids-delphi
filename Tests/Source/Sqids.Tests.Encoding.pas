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
unit Sqids.Tests.Encoding;

interface

uses
  System.SysUtils, System.Rtti, DUnitX.TestFramework,

  Sqids.Types, Sqids.Classes;

type
  [TestFixture]
  [Category('encoding')]
  TTestEncoding = class(TObject)
  private const
    ERR_DECODING = 'Decoding %s should produce %s, but instead produced %s';
    ERR_ENCODING = 'Encoding %s should produce %s, but instead produced %s';
    ERR_ENCODE_DECODE = 'Could not encode/decode %s';
  private
    procedure EncodeDecode(Numbers: TNumbers; const Id: string);
  public
    constructor Create;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestEncodingSimple', '[1,2,3]', ';')]
    procedure TestEncodingSimple(Numbers: TNumbers);

    [Test]
    procedure TestEncodingDifferentInputs;

    [Test]
    [TestCase('bV', 'bV;[0]', ';')]
    [TestCase('U9', 'U9;[1]', ';')]
    [TestCase('g8', 'g8;[2]', ';')]
    [TestCase('Ez', 'Ez;[3]', ';')]
    [TestCase('V8', 'V8;[4]', ';')]
    [TestCase('ul', 'ul;[5]', ';')]
    [TestCase('O3', 'O3;[6]', ';')]
    [TestCase('AF', 'AF;[7]', ';')]
    [TestCase('ph', 'ph;[8]', ';')]
    [TestCase('n8', 'n8;[9]', ';')]
    procedure TestEncodingIncrementalNumbers(const Id: string; Numbers: TNumbers);

    [Test]
    [TestCase('SrIu', 'SrIu;[0,0]', ';')]
    [TestCase('nZqE', 'nZqE;[0,1]', ';')]
    [TestCase('tJyf', 'tJyf;[0,2]', ';')]
    [TestCase('e86S', 'e86S;[0,3]', ';')]
    [TestCase('rtC7', 'rtC7;[0,4]', ';')]
    [TestCase('sQ8R', 'sQ8R;[0,5]', ';')]
    [TestCase('uz2n', 'uz2n;[0,6]', ';')]
    [TestCase('7Td9', '7Td9;[0,7]', ';')]
    [TestCase('3nWE', '3nWE;[0,8]', ';')]
    [TestCase('mIxM', 'mIxM;[0,9]', ';')]
    procedure TestEncodingIncrementalNumbersSameIndex0(const Id: string; Numbers: TNumbers);

    [Test]
    [TestCase('SrIu', 'SrIu;[0,0]', ';')]
    [TestCase('nbqh', 'nbqh;[1,0]', ';')]
    [TestCase('t4yj', 't4yj;[2,0]', ';')]
    [TestCase('eQ6L', 'eQ6L;[3,0]', ';')]
    [TestCase('r4Cc', 'r4Cc;[4,0]', ';')]
    [TestCase('sL82', 'sL82;[5,0]', ';')]
    [TestCase('uo2f', 'uo2f;[6,0]', ';')]
    [TestCase('7Zdq', '7Zdq;[7,0]', ';')]
    [TestCase('36Wf', '36Wf;[8,0]', ';')]
    [TestCase('m4xT', 'm4xT;[9,0]', ';')]
    procedure TestEncodingIncrementalNumbersSameIndex1(const Id: string; Numbers: TNumbers);

    [Test]
    procedure TestEncodingMultiInput;

    [Test]
    procedure TestEncodingEmptySlice;

    [Test]
    procedure TestEncodingEmptyString;

    [Test]
    [TestCase('TestEncodingInvalidCharacter', '*')]
    [TestCase('TestDecodeInvalidIDWithRepeatingReservedCharacter', 'fff')]
    procedure TestDecodeInvalid(const Id: string);

  end;

implementation

constructor TTestEncoding.Create;
begin
end;

procedure TTestEncoding.Setup;
begin
end;

procedure TTestEncoding.TearDown;
begin
end;

procedure TTestEncoding.EncodeDecode(Numbers: TNumbers; const Id: string);
begin
	var s := TSqids.New();

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, numbers.ToString, decodedNumbers.ToString]);
end;

procedure TTestEncoding.TestEncodingSimple(Numbers: TNumbers);
begin
	var s := TSqids.New();

	var id := s.Encode(numbers);
	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_ENCODE_DECODE, [numbers.ToString]);
end;

procedure TTestEncoding.TestEncodingDifferentInputs;
begin
  var numbers: TNumbers := [TSqids.MinValue, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, TSqids.MaxValue];
	var s := TSqids.New();

	var id := s.Encode(numbers);
	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_ENCODE_DECODE, [numbers.ToString]);
end;

procedure TTestEncoding.TestEncodingIncrementalNumbers(const Id: string; Numbers: TNumbers);
begin
  EncodeDecode(Numbers, Id);
end;

procedure TTestEncoding.TestEncodingIncrementalNumbersSameIndex0(const Id: string; Numbers: TNumbers);
begin
  EncodeDecode(Numbers, Id);
end;

procedure TTestEncoding.TestEncodingIncrementalNumbersSameIndex1(const Id: string; Numbers: TNumbers);
begin
  EncodeDecode(Numbers, Id);
end;

procedure TTestEncoding.TestEncodingMultiInput;
begin
  var numbers: TNumbers := [];
  for var i := 0 to 99 do
    numbers := numbers + [TNumber(i)];

	var s := TSqids.New();

	var id := s.Encode(numbers);
	var decodedNumbers := s.Decode(id);
	if not numbers.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_ENCODE_DECODE, [numbers.ToString]);
end;

procedure TTestEncoding.TestEncodingEmptySlice;
begin
	var s := TSqids.New();

	if s.Encode([]) <> '' then
  	Assert.Fail('Could not encode empty slice');
end;

procedure TTestEncoding.TestEncodingEmptyString;
begin
	var s := TSqids.New();

  var empty: TNumbers := [];
	if not empty.IsEqual(s.Decode('')) then
  	Assert.Fail('Could not decode empty string');
end;

procedure TTestEncoding.TestDecodeInvalid(const Id: string);
begin
	var s := TSqids.New();

  var empty: TNumbers := [];
	var decodedNumbers := s.Decode(id);
	if not empty.IsEqual(decodedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, '[]', decodedNumbers.ToString]);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestEncoding);

end.
