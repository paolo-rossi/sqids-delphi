unit Sqids.Form.Main;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls,
  Vcl.Buttons, System.Generics.Collections,

  Sqids.Classes,
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
  var len := Length(DEFAULT_ALPHABET);
  var alphabet := '';
  for var i := 0 to len do
  begin
    var ch := DEFAULT_ALPHABET.Chars[Random(len-1)];
    if alphabet.IndexOf(ch) > -1 then
      Continue;
    alphabet := alphabet + ch;
  end;
  memoAlphabet.Lines.Text := alphabet;
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

procedure TfrmMain.DoEncode(Sender: TObject);
begin
  var LNumbers: TNumbers := [];
  for var LIndex := 0 to FInput.Count - 1 do
    LNumbers := LNumbers + [StrToInt(FInput[LIndex].Text)];

  var LAlpha := StringReplace(memoAlphabet.Lines.Text, sLineBreak, '', [rfReplaceAll]);
  var LOpt := TSqidsOptions.Create(LAlpha, StrToIntDef(edtMinLength.Text, 0));
  var LGen := TSqids.New(LOpt);

  edtOutput.Text := LGen.Encode(LNumbers);
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
