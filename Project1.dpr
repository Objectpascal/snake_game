program Project1;
{$apptype console}

uses
  Vcl.Forms,
  frmMain_u in 'frmMain_u.pas' {Form1},
  entity_u in 'entity_u.pas',
  matrix_operation_u in 'matrix_operation_u.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := true;
  Application.MainFormOnTaskbar := true;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
