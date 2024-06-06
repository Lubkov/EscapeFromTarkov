program TarkovMap;

uses
  System.StartUpCopy,
  FMX.Forms,
  TM.MainForm in 'Source\GUI\Form\TM.MainForm.pas' {MainForm},
  App.Constants in 'Source\App.Constants.pas',
  ME.DB.DAO in 'Source\Common\ME.DB.DAO.pas',
  ME.DB.Entity in 'Source\Common\ME.DB.Entity.pas',
  ME.DB.Service in 'Source\Common\ME.DB.Service.pas',
  ME.DB.Utils in 'Source\Common\ME.DB.Utils.pas',
  ME.Del.Form.Presenter in 'Source\Common\ME.Del.Form.Presenter.pas',
  ME.Dialog.Presenter in 'Source\Common\ME.Dialog.Presenter.pas',
  ME.Edit.Form in 'Source\Common\ME.Edit.Form.pas' {EditForm},
  ME.Edit.Form.Presenter in 'Source\Common\ME.Edit.Form.Presenter.pas',
  ME.DAO.Layer in 'Source\DAO\ME.DAO.Layer.pas',
  ME.DAO.Map in 'Source\DAO\ME.DAO.Map.pas',
  ME.DAO.Marker in 'Source\DAO\ME.DAO.Marker.pas',
  ME.DAO.Quest in 'Source\DAO\ME.DAO.Quest.pas',
  ME.DB.Layer in 'Source\Entity\ME.DB.Layer.pas',
  ME.DB.Map in 'Source\Entity\ME.DB.Map.pas',
  ME.DB.Marker in 'Source\Entity\ME.DB.Marker.pas',
  ME.DB.Quest in 'Source\Entity\ME.DB.Quest.pas',
  TM.FilesMonitor in 'Source\Service\TM.FilesMonitor.pas',
  ME.Service.Layer in 'Source\Service\ME.Service.Layer.pas',
  ME.Service.Map in 'Source\Service\ME.Service.Map.pas',
  ME.Service.Marker in 'Source\Service\ME.Service.Marker.pas',
  ME.Service.Quest in 'Source\Service\ME.Service.Quest.pas',
  TM.Form.Wrapper in 'Source\GUI\TM.Form.Wrapper.pas',
  App.DB.Connection in 'Source\App.DB.Connection.pas',
  App.Service in 'Source\App.Service.pas',
  TM.Map.Wrapper in 'Source\GUI\TM.Map.Wrapper.pas',
  TM.Form.Location in 'Source\GUI\Form\TM.Form.Location.pas' {LocationForm},
  ME.Point in 'Source\Entity\ME.Point.pas';

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
