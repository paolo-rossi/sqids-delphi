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
    [TestCase('TestEncodingSimple', '[1,2,3];86Rf07', ';')]
    procedure TestEncodingSimple(Numbers: TNumbers; const Id: string);

    [Test]
    procedure TestEncodingDifferentInputs;

    [Test]
    [TestCase('bM', 'bM;[0]', ';')]
    [TestCase('Uk', 'Uk;[1]', ';')]
    [TestCase('gb', 'gb;[2]', ';')]
    [TestCase('Ef', 'Ef;[3]', ';')]
    [TestCase('Vq', 'Vq;[4]', ';')]
    [TestCase('uw', 'uw;[5]', ';')]
    [TestCase('OI', 'OI;[6]', ';')]
    [TestCase('AX', 'AX;[7]', ';')]
    [TestCase('p6', 'p6;[8]', ';')]
    [TestCase('nJ', 'nJ;[9]', ';')]
    procedure TestEncodingIncrementalNumbers(const Id: string; Numbers: TNumbers);

    [Test]
    [TestCase('SvIz', 'SvIz;[0,0]', ';')]
    [TestCase('n3qa', 'n3qa;[0,1]', ';')]
    [TestCase('tryF', 'tryF;[0,2]', ';')]
    [TestCase('eg6q', 'eg6q;[0,3]', ';')]
    [TestCase('rSCF', 'rSCF;[0,4]', ';')]
    [TestCase('sR8x', 'sR8x;[0,5]', ';')]
    [TestCase('uY2M', 'uY2M;[0,6]', ';')]
    [TestCase('74dI', '74dI;[0,7]', ';')]
    [TestCase('30WX', '30WX;[0,8]', ';')]
    [TestCase('moxr', 'moxr;[0,9]', ';')]
    procedure TestEncodingIncrementalNumbersSameIndex0(const Id: string; Numbers: TNumbers);

    [Test]
    [TestCase('SvIz', 'SvIz;[0,0]', ';')]
    [TestCase('nWqP', 'nWqP;[1,0]', ';')]
    [TestCase('tSyw', 'tSyw;[2,0]', ';')]
    [TestCase('eX68', 'eX68;[3,0]', ';')]
    [TestCase('rxCY', 'rxCY;[4,0]', ';')]
    [TestCase('sV8a', 'sV8a;[5,0]', ';')]
    [TestCase('uf2K', 'uf2K;[6,0]', ';')]
    [TestCase('7Cdk', '7Cdk;[7,0]', ';')]
    [TestCase('3aWP', '3aWP;[8,0]', ';')]
    [TestCase('m2xn', 'm2xn;[9,0]', ';')]
    procedure TestEncodingIncrementalNumbersSameIndex1(const Id: string; Numbers: TNumbers);

    [Test]
    procedure TestEncodingMultiInput;

    [Test]
    procedure TestEncodingEmptySlice;

    [Test]
    procedure TestEncodingEmptyString;

    [Test]
    [TestCase('TestEncodingInvalidCharacter', '*')]
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

procedure TTestEncoding.TestEncodingSimple(Numbers: TNumbers; const Id: string);
begin
	var s := TSqids.New();

	var generatedID := s.Encode(numbers);
	if id <> generatedID then
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, generatedID]);

	var decodedNumbers := s.Decode(generatedID);
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
