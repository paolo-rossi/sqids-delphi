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

  Sqids.Classes;

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
    [TestCase('TestMinLengthSimple', '[1,2,3];75JILToVsGerOADWmHlY38xvbaNZKQ9wdFS0B6kcMEtnRpgizhjU42qT1cd0dL', ';')]
    procedure TestMinLengthSimple(Numbers: TNumbers; const Id: string);

    [Test]
    [TestCase('0_0', 'jf26PLNeO5WbJDUV7FmMtlGXps3CoqkHnZ8cYd19yIiTAQuvKSExzhrRghBlwf;[0,0]', ';')]
    [TestCase('0_1', 'vQLUq7zWXC6k9cNOtgJ2ZK8rbxuipBFAS10yTdYeRa3ojHwGnmMV4PDhESI2jL;[0,1]', ';')]
    [TestCase('0_2', 'YhcpVK3COXbifmnZoLuxWgBQwtjsSaDGAdr0ReTHM16yI9vU8JNzlFq5Eu2oPp;[0,2]', ';')]
    [TestCase('0_3', 'OTkn9daFgDZX6LbmfxI83RSKetJu0APihlsrYoz5pvQw7GyWHEUcN2jBqd4kJ9;[0,3]', ';')]
    [TestCase('0_4', 'h2cV5eLNYj1x4ToZpfM90UlgHBOKikQFvnW36AC8zrmuJ7XdRytIGPawqYEbBe;[0,4]', ';')]
    [TestCase('0_5', '7Mf0HeUNkpsZOTvmcj836P9EWKaACBubInFJtwXR2DSzgYGhQV5i4lLxoT1qdU;[0,5]', ';')]
    [TestCase('0_6', 'APVSD1ZIY4WGBK75xktMfTev8qsCJw6oyH2j3OnLcXRlhziUmpbuNEar05QCsI;[0,6]', ';')]
    [TestCase('0_7', 'P0LUhnlT76rsWSofOeyRGQZv1cC5qu3dtaJYNEXwk8Vpx92bKiHIz4MgmiDOF7;[0,7]', ';')]
    [TestCase('0_8', 'xAhypZMXYIGCL4uW0te6lsFHaPc3SiD1TBgw5O7bvodzjqUn89JQRfk2Nvm4JI;[0,8]', ';')]
    [TestCase('0_9', '94dRPIZ6irlXWvTbKywFuAhBoECQOVMjDJp53s2xeqaSzHY8nc17tmkLGwfGNl;[0,9]', ';')]
    procedure TestMinLengthIncrementalNumbers(const Id: string; Numbers: TNumbers);

    [Test]
    procedure TestMinLengths;

    [Test]
    procedure TestOutOfRangeInvalidMinLength;

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
      TSqids.New(TSqidsOptions.Create('', Length(DEFAULT_ALPHABET) + 1));
    end,
    Exception, 'Should not allow out of range min length');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMinLength);

end.
