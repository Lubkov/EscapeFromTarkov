program TarkovMap;

uses
  System.StartUpCopy,
  FMX.Forms,
  TM.MainForm in 'Source\GUI\Form\TM.MainForm.pas' {MainForm},
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
  TM.Map.Wrapper in 'Source\GUI\TM.Map.Wrapper.pas',
  TM.Form.Location in 'Source\GUI\Form\TM.Form.Location.pas' {LocationForm},
  TM.Frame.MarkerFilter in 'Source\GUI\Frame\TM.Frame.MarkerFilter.pas' {MarkerFilterList: TFrame},
  ME.MarkerFilter in 'Source\Entity\ME.MarkerFilter.pas',
  App.DB.Connection in 'Source\Common\App.DB.Connection.pas',
  App.SQLite.Connection in 'Source\Common\App.SQLite.Connection.pas',
  App.Constants in 'Source\Common\App.Constants.pas',
  App.Service in 'Source\Common\App.Service.pas',
  TM.Frame.Location in 'Source\GUI\Frame\TM.Frame.Location.pas' {LocationGrid: TFrame},
  Map.Data.Classes in 'Source\Data\Map.Data.Classes.pas',
  Map.Data.Types in 'Source\Data\Map.Data.Types.pas',
  Map.Data.Service in 'Source\Data\Map.Data.Service.pas',
  Map.Frame.InteractiveMap in 'Source\GUI\Frame\Map.Frame.InteractiveMap.pas' {InteractiveMap: TFrame};

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
