program PositionGenerate;

uses
  MidasLib,
  System.StartUpCopy,
  FMX.Forms,
  PG.Form.Main in 'Source\PG.Form.Main.pas' {MainForm},
  PG.Service in 'Source\PG.Service.pas',
  PG.Constants in 'Source\PG.Constants.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;

  // app initialization
  PositionService := TPositionService.Create(Application);

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
