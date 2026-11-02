unit Sqids.Form.Main;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls,
  Vcl.Buttons, System.Generics.Collections,

  Sqids.Types, Sqids.Classes,
  Sqids.Blocklist, Vcl.Imaging.pngimage;

type
  TfrmMain = class(TForm)
    memoAlphabet: TMemo;
    imgMain: TImageList;
    lblInput: TLabel;
    edtOutput: TButtonedEdit;
    pnlInput: TPanel;
    lblAlphabet: TLabel;
    lblOutput: TLabel;
    edtMinLength: TButtonedEdit;
    lblMinLength: TLabel;
    btnInputPlus: TSpeedButton;
    btnAlphabetCopy: TSpeedButton;
    timerDelete: TTimer;
    lblTitle: TLabel;
    btnAlphabetRandom: TSpeedButton;
    btnAlphabetDefault: TSpeedButton;
    Image1: TImage;
    bvlMain: TBevel;
    procedure btnAlphabetCopyClick(Sender: TObject);
    procedure btnAlphabetDefaultClick(Sender: TObject);
    procedure btnAlphabetRandomClick(Sender: TObject);
    procedure btnInputPlusClick(Sender: TObject);
    procedure edtMinLengthRightButtonClick(Sender: TObject);
    procedure edtOutputRightButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure timerDeleteTimer(Sender: TObject);
  private const
    DEFAULT_ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  private
    FDeleteProc: TProc;
    FInput: TObjectList<TButtonedEdit>;

    function NewInput(AValue: TNumber = 0): TButtonedEdit;
    procedure PlaceInput(AInput: TButtonedEdit; AIndex: Integer);
    procedure PlaceAllInput;

    procedure DoEncode(Sender: TObject);
    procedure ShowOutputError(const AMessage: string);
    procedure HandleInputDelete(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Vcl.Clipbrd, System.Math,
  System.Threading;

{$R *.dfm}

procedure TfrmMain.btnAlphabetCopyClick(Sender: TObject);
begin
  Clipboard.AsText := memoAlphabet.Lines.Text;
end;

procedure TfrmMain.btnAlphabetDefaultClick(Sender: TObject);
begin
  memoAlphabet.Lines.Text := DEFAULT_ALPHABET;
end;

procedure TfrmMain.btnAlphabetRandomClick(Sender: TObject);
begin
  // Fisher-Yates shuffle: keeps every character of the default alphabet
  var chars := DEFAULT_ALPHABET.ToCharArray;
  for var i := High(chars) downto 1 do
  begin
    var j := Random(i + 1);
    var ch := chars[i];
    chars[i] := chars[j];
    chars[j] := ch;
  end;
  memoAlphabet.Lines.Text := string.Create(chars);
end;

procedure TfrmMain.btnInputPlusClick(Sender: TObject);
begin
  NewInput();
  DoEncode(nil);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FInput.Free;
end;

procedure TfrmMain.HandleInputDelete(Sender: TObject);
begin
  FDeleteProc := procedure
    begin
      FInput.Delete((Sender as TComponent).Tag);
      PlaceAllInput;
      DoEncode(nil);
    end
   ;
   timerDelete.Enabled := True;
end;

function TfrmMain.NewInput(AValue: TNumber): TButtonedEdit;
begin
  Result := TButtonedEdit.Create(nil);
  FInput.Add(Result);

  Result.Font.Name := 'Consolas';
  Result.Font.Size := 12;
  Result.Parent := pnlInput;
  Result.DoubleBuffered := True;
  Result.Images := imgMain;
  Result.RightButton.ImageIndex := 0;
  Result.RightButton.Visible := True;
  Result.Width := 113;
  Result.Hint := 'Delete this input';
  result.ShowHint := True;
  Result.OnRightButtonClick := HandleInputDelete;
  Result.OnChange := DoEncode;

  if AValue > 0 then
    Result.Text := AValue.ToString
  else
    Result.Text := Random(500).ToString();

  PlaceInput(Result, FInput.Count - 1);
end;

procedure TfrmMain.PlaceAllInput;
begin
  for var LIndex := 0 to FInput.Count - 1 do
    PlaceInput(FInput[LIndex], LIndex);
end;

procedure TfrmMain.PlaceInput(AInput: TButtonedEdit; AIndex: Integer);
begin
  AInput.Tag := AIndex;

  if (AIndex + 1) mod 2 = 0 then
    AInput.Left := 152
  else
    AInput.Left := 16;
  AInput.Top := ((AIndex) div 2) * 33 + 22;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FInput := TObjectList<TButtonedEdit>.Create(True);
  memoAlphabet.Lines.Text := DEFAULT_ALPHABET;
  memoAlphabet.OnChange := DoEncode;
  edtMinLength.OnChange := DoEncode;

  NewInput(123);
  NewInput(456);
  NewInput(789);
end;

function TryParseNumber(const AText: string; out AValue: TNumber): Boolean;
begin
  // TryStrToUInt64 would accept '-1' and wrap it to High(UInt64)
  var LText := AText.Trim;
  Result := (LText <> '') and (LText[1] <> '-') and TryStrToUInt64(LText, AValue);
end;

procedure TfrmMain.DoEncode(Sender: TObject);
begin
  // OnChange fires while the form is still being built
  if not Assigned(FInput) then
    Exit;

  var LValid := True;
  var LNumbers: TNumbers := [];
  for var LInput in FInput do
  begin
    var LValue: TNumber;
    if TryParseNumber(LInput.Text, LValue) then
    begin
      LInput.Font.Color := clWindowText;
      LNumbers := LNumbers + [LValue];
    end
    else
    begin
      LInput.Font.Color := clRed;
      LValid := False;
    end;
  end;

  if not LValid then
  begin
    ShowOutputError('Inputs must be numbers between 0 and ' + TSqids.MaxValue.ToString);
    Exit;
  end;

  try
    var LAlpha := StringReplace(memoAlphabet.Lines.Text, sLineBreak, '', [rfReplaceAll]);
    var LOpt := TSqidsOptions.Create(LAlpha, StrToIntDef(edtMinLength.Text, 0));
    var LGen := TSqids.New(LOpt);

    edtOutput.Font.Color := clWindowText;
    edtOutput.Text := LGen.Encode(LNumbers);
  except
    on E: Exception do
      ShowOutputError(E.Message);
  end;
end;

procedure TfrmMain.ShowOutputError(const AMessage: string);
begin
  edtOutput.Font.Color := clRed;
  edtOutput.Text := AMessage;
end;

procedure TfrmMain.edtMinLengthRightButtonClick(Sender: TObject);
begin
  Clipboard.AsText := edtMinLength.Text;
end;

procedure TfrmMain.edtOutputRightButtonClick(Sender: TObject);
begin
  Clipboard.AsText := edtOutput.Text;
end;

procedure TfrmMain.timerDeleteTimer(Sender: TObject);
begin
  timerDelete.Enabled := False;
  if Assigned(FDeleteProc) then
  begin
    FDeleteProc();
    FDeleteProc := nil;
  end;
end;

initialization
  Randomize;

end.
