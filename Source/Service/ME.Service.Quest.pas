unit ME.Service.Quest;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, Data.DB, ME.DB.Entity,
  ME.DB.DAO, ME.DB.Service, ME.DB.Quest, ME.DB.Marker, ME.DAO.Quest;

type
  TQuestService = class(TServiceCommon)
  protected
    function GetDAOClass: TDAOClass; override;
  public
    procedure Insert(const Entity: TEntity); override;

    procedure LoadQuests(const MapID: Variant; const Items: TList<TQuest>);
    procedure LoadMarkers(const MapID, QuestID: Variant; const Items: TList<TMarker>);
  end;

var
  QuestService: TQuestService;

implementation

uses
  ME.Service.Marker;

{ TQuestService }

function TQuestService.GetDAOClass: TDAOClass;
begin
  Result := TQuestDAO;
end;

procedure TQuestService.Insert(const Entity: TEntity);
var
  Quest: TQuest;
  Marker: TMarker;
  TranStarted: Boolean;
begin
  Quest := TQuest(Entity);
  TranStarted := InTransaction;

  if not TranStarted then
    StartTransaction;
  try
    DAO.Insert(Quest);

    for Marker in Quest.Markers do begin
      Marker.MapID := Quest.MapID;
      Marker.QuestID := Quest.ID;
      MarkerService.Insert(Marker);
    end;

    if not TranStarted then
      CommitTransaction;
  except
    if not TranStarted then
      RollbackTransaction;
    raise;
  end;
end;

procedure TQuestService.LoadQuests(const MapID: Variant; const Items: TList<TQuest>);
begin
  TQuestDAO(DAO).LoadQuests(MapID, Items);
end;

procedure TQuestService.LoadMarkers(const MapID, QuestID: Variant; const Items: TList<TMarker>);
begin
  MarkerService.LoadQuestMarkers(MapID, QuestID, Items);
end;

end.
