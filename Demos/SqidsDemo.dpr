program SqidsDemo;

uses
  Vcl.Forms,
  Sqids.Form.Main in 'Sqids.Form.Main.pas' {frmMain},
  Sqids.Types in '..\Source\Sqids.Types.pas',
  Sqids.Classes in '..\Source\Sqids.Classes.pas',
  Sqids.Blocklist in '..\Source\Sqids.Blocklist.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
