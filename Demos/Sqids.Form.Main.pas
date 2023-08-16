unit Sqids.Form.Main;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls,
  System.Generics.Collections,

  Sqids.Classes,
  Sqids.Blocklist, Vcl.Buttons;

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
    btnAlphabetShuffle: TSpeedButton;
    btnAlphabetCopy: TSpeedButton;
    timerDelete: TTimer;
    procedure btnAlphabetShuffleClick(Sender: TObject);
    procedure btnInputPlusClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure timerDeleteTimer(Sender: TObject);
  private const
    DEFAULT_ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  private
    FDeleteProc: TProc;
    FInput: TObjectList<TButtonedEdit>;

    function NewInput(): TButtonedEdit;
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
  System.Threading;

{$R *.dfm}

procedure TfrmMain.btnAlphabetShuffleClick(Sender: TObject);
begin
  var LAlpha := StringReplace(memoAlphabet.Lines.Text, sLineBreak, '', [rfReplaceAll]);
  memoAlphabet.Lines.Text := TSqids.New.Shuffle(LAlpha);
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

function TfrmMain.NewInput: TButtonedEdit;
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
  Result.OnRightButtonClick := HandleInputDelete;
  Result.OnChange := DoEncode;

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
