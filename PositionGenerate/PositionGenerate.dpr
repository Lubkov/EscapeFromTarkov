program PositionGenerate;

uses
  MidasLib,
  System.StartUpCopy,
  FMX.Forms,
  App.Lite.Connection in 'Source\App.Lite.Connection.pas',
  App.Main.Service in 'Source\App.Main.Service.pas',
  PG.Form.Main in 'Source\PG.Form.Main.pas' {MainForm},
  App.Constants in 'Source\App.Constants.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;

  // app initialization
  AppService := TAppService.Create(Application);

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
