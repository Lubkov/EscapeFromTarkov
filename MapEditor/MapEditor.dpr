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
  ME.DAO.Map in '..\Source\DAO\ME.DAO.Map.pas',
  ME.DAO.Layer in '..\Source\DAO\ME.DAO.Layer.pas',
  ME.DB.Map in '..\Source\Entity\ME.DB.Map.pas',
  ME.DB.Layer in '..\Source\Entity\ME.DB.Layer.pas',
  ME.Service.Map in '..\Source\Service\ME.Service.Map.pas',
  ME.Service.Layer in '..\Source\Service\ME.Service.Layer.pas',
  ME.Frame.Map in 'Source\GUI\Frame\ME.Frame.Map.pas' {frMap: TFrame},
  ME.Presenter.Map in 'Source\GUI\ME.Presenter.Map.pas',
  ME.Dialog.Message in 'Source\GUI\Dialog\ME.Dialog.Message.pas' {edMessage},
  ME.Frame.Layer in 'Source\GUI\Frame\ME.Frame.Layer.pas' {frLayerList: TFrame},
  ME.Presenter.Layer in 'Source\GUI\ME.Presenter.Layer.pas',
  ME.Edit.Form in '..\Source\Common\ME.Edit.Form.pas' {EditForm},
  ME.Edit.Map in 'Source\GUI\Dialog\ME.Edit.Map.pas' {edMap},
  ME.Edit.Layer in 'Source\GUI\Dialog\ME.Edit.Layer.pas' {edLayer},
  ME.Frame.Picture in 'Source\GUI\Frame\ME.Frame.Picture.pas' {frPicture: TFrame},
  ME.DB.Marker in '..\Source\Entity\ME.DB.Marker.pas',
  ME.DAO.Marker in '..\Source\DAO\ME.DAO.Marker.pas',
  ME.Service.Marker in '..\Source\Service\ME.Service.Marker.pas',
  ME.Frame.Marker in 'Source\GUI\Frame\ME.Frame.Marker.pas' {frMarkerGrid: TFrame},
  ME.Edit.Marker in 'Source\GUI\Dialog\ME.Edit.Marker.pas' {edMarker},
  ME.Presenter.Marker in 'Source\GUI\ME.Presenter.Marker.pas',
  ME.DB.Quest in '..\Source\Entity\ME.DB.Quest.pas',
  ME.DAO.Quest in '..\Source\DAO\ME.DAO.Quest.pas',
  ME.Service.Quest in '..\Source\Service\ME.Service.Quest.pas',
  ME.Frame.Quest in 'Source\GUI\Frame\ME.Frame.Quest.pas' {frQuest: TFrame},
  ME.Edit.Quest in 'Source\GUI\Dialog\ME.Edit.Quest.pas' {edQuest},
  ME.Presenter.Quest in 'Source\GUI\ME.Presenter.Quest.pas',
  ME.Edit.QuestPart in 'Source\GUI\Dialog\ME.Edit.QuestPart.pas' {edQuestPart},
  ME.Frame.QuestPart in 'Source\GUI\Frame\ME.Frame.QuestPart.pas' {frQuestPartGrid: TFrame},
  ME.Presenter.QuestPart in 'Source\GUI\ME.Presenter.QuestPart.pas',
  LocalMap in '..\Source\Entity\LocalMap.pas',
  App.Constants in '..\Source\Common\App.Constants.pas',
  App.DB.Connection in '..\Source\Common\App.DB.Connection.pas',
  App.SQLite.Connection in '..\Source\Common\App.SQLite.Connection.pas',
  App.Service in '..\Source\Common\App.Service.pas',
  ME.Service.Export in 'Source\ME.Service.Export.pas',
  Map.Data.Classes in '..\Source\Data\Map.Data.Classes.pas',
  Map.Data.Service in '..\Source\Data\Map.Data.Service.pas',
  Map.Data.Types in '..\Source\Data\Map.Data.Types.pas',
  ME.Filter.Map in 'Source\GUI\Frame\ME.Filter.Map.pas' {MapFilter: TFrame},
  ME.Frame.MapData in 'Source\GUI\Frame\ME.Frame.MapData.pas' {frMapData: TFrame},
  ME.Frame.MarkerItem in 'Source\GUI\Frame\ME.Frame.MarkerItem.pas' {frQuestItemsGrid: TFrame};

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
