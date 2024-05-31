program MapEditor;

uses
  System.StartUpCopy,
  FMX.Forms,
  ME.MainForm in 'Source\ME.MainForm.pas' {MainForm},
  ME.DB.DAO in '..\Source\Common\ME.DB.DAO.pas',
  ME.DB.Entity in '..\Source\Common\ME.DB.Entity.pas',
  ME.DB.Service in '..\Source\Common\ME.DB.Service.pas',
  ME.DB.Utils in '..\Source\Common\ME.DB.Utils.pas',
  ME.Del.Form.Presenter in '..\Source\Common\ME.Del.Form.Presenter.pas',
  ME.Dialog.Presenter in '..\Source\Common\ME.Dialog.Presenter.pas',
  ME.Edit.Form.Presenter in '..\Source\Common\ME.Edit.Form.Presenter.pas',
  ME.Connection in 'Source\ME.Connection.pas',
  ME.AppService in 'Source\ME.AppService.pas',
  ME.DAO.Map in '..\Source\DAO\ME.DAO.Map.pas',
  ME.DAO.Layer in '..\Source\DAO\ME.DAO.Layer.pas',
  ME.DAO.Point in '..\Source\DAO\ME.DAO.Point.pas',
  ME.DB.Map in '..\Source\Entity\ME.DB.Map.pas',
  ME.DB.Layer in '..\Source\Entity\ME.DB.Layer.pas',
  ME.DB.Point in '..\Source\Entity\ME.DB.Point.pas',
  ME.Service.Map in '..\Source\Service\ME.Service.Map.pas',
  ME.Service.Layer in '..\Source\Service\ME.Service.Layer.pas',
  ME.Service.Point in '..\Source\Service\ME.Service.Point.pas',
  ME.Frame.Map in 'Source\GUI\Frame\ME.Frame.Map.pas' {frMap: TFrame},
  ME.Presenter.Map in 'Source\GUI\ME.Presenter.Map.pas',
  ME.Dialog.Message in 'Source\GUI\Dialog\ME.Dialog.Message.pas' {edMessage},
  ME.Frame.Layer in 'Source\GUI\Frame\ME.Frame.Layer.pas' {frLayerList: TFrame},
  ME.Presenter.Layer in 'Source\GUI\ME.Presenter.Layer.pas',
  ME.Edit.Form in '..\Source\Common\ME.Edit.Form.pas' {EditForm},
  ME.Edit.Map in 'Source\GUI\Dialog\ME.Edit.Map.pas' {edMap},
  ME.Edit.Layer in 'Source\GUI\Dialog\ME.Edit.Layer.pas' {edLayer},
  App.Constants in '..\Source\App.Constants.pas',
  ME.Frame.Picture in 'Source\GUI\Frame\ME.Frame.Picture.pas' {frPicture: TFrame},
  ME.DB.Marker in '..\Source\Entity\ME.DB.Marker.pas',
  ME.DAO.Marker in '..\Source\DAO\ME.DAO.Marker.pas',
  ME.Service.Marker in '..\Source\Service\ME.Service.Marker.pas',
  ME.Frame.Extraction in 'Source\GUI\Frame\ME.Frame.Extraction.pas' {frExtraction: TFrame},
  ME.Edit.Extraction in 'Source\GUI\Dialog\ME.Edit.Extraction.pas' {edExtraction},
  ME.Presenter.Extraction in 'Source\GUI\ME.Presenter.Extraction.pas',
  ME.DB.Quest in '..\Source\Entity\ME.DB.Quest.pas',
  ME.DAO.Quest in '..\Source\DAO\ME.DAO.Quest.pas',
  ME.Service.Quest in '..\Source\Service\ME.Service.Quest.pas',
  ME.Edit.Point in 'Source\GUI\Dialog\ME.Edit.Point.pas' {edPoint},
  ME.Presenter.Point in 'Source\GUI\ME.Presenter.Point.pas',
  ME.Frame.Quest in 'Source\GUI\Frame\ME.Frame.Quest.pas' {frQuest: TFrame},
  ME.Edit.Quest in 'Source\GUI\Dialog\ME.Edit.Quest.pas' {edQuest},
  ME.Presenter.Quest in 'Source\GUI\ME.Presenter.Quest.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;

  // app initialization
  AppService := TMEService.Create(Application);

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
