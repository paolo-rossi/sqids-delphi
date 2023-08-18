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

  Sqids.Classes,
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
    [TestCase('TestBlocklistDefault', '[200044],sexy,d171vI')]
    procedure TestBlocklistDefault(Numbers: TNumbers; const BlockedID, UnblockedID: string);

    [Test]
    [TestCase('TestBlocklistEmpty', '[200044],sexy,[]')]
    procedure TestBlocklistEmpty(Numbers: TNumbers; const Id: string; const List: TBlocklist);

    [Test]
    [TestCase('TestBlocklistNotEmpty', '[200044],sexy,7T1X8k,[AvTg]')]
    procedure TestBlocklistNotEmpty(Numbers: TNumbers; const Id, ExpectedId: string; const List: TBlocklist);

    [Test]
    [TestCase('TestBlocklist', '[1,2,3];TM0x1Mxz', ';')]
    procedure TestBlocklist(Numbers: TNumbers; const Id: string);

    [Test]
    [TestCase('TestDecodingBlocklistedIDs', '[1,2,3];[8QRLaD,7T1cd0dL,RA8UeIe7,WM3Limhw,LfUQh4HN]', ';')]
    procedure TestDecodingBlocklistedIDs(Numbers: TNumbers; const List: TBlocklist);

    [Test]
    [TestCase('TestShortBlocklistMatch', '[1000];[pPQ]', ';')]
    procedure TestShortBlocklistMatch(Numbers: TNumbers; const List: TBlocklist);

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
    '8QRLaD',   // normal result of 1st encoding, let's block that word on purpose
    '7T1cd0dL', // result of 2nd encoding
    'UeIe',     // result of 3rd encoding is 'RA8UeIe7', let's block a substring
    'imhw',     // result of 4th encoding is 'WM3Limhw', let's block the postfix
    'LfUQ'      // result of 4th encoding is 'LfUQh4HN', let's block the prefix
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
  	Assert.FailFmt(ERR_ENCODING, [numbers, unblockedID, generatedID]);
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
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, decodedNumbers.ToString]);
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
  	Assert.FailFmt(ERR_ENCODING, [numbers.ToString, id, decodedNumbers.ToString]);

  var expectedNumbers: TNumbers := [100_000];
	// make sure we are using the passed blocklist
	decodedNumbers := s.Decode(List[0]);
  if not decodedNumbers.IsEqual(expectedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, expectedNumbers.ToString, decodedNumbers.ToString]);

	generatedID := s.Encode(expectedNumbers);
	if generatedID <> expectedId then
		Assert.FailFmt(ERR_ENCODING, [expectedNumbers, ExpectedId, generatedID]);

	decodedNumbers := s.Decode(ExpectedId);
	if not decodedNumbers.IsEqual(expectedNumbers) then
  	Assert.FailFmt(ERR_DECODING, [id, expectedNumbers.ToString, decodedNumbers.ToString]);
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

initialization
  TDUnitX.RegisterTestFixture(TTestBlocklist);

end.
