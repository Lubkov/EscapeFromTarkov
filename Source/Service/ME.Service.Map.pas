unit ME.Service.Map;

interface

uses
  System.SysUtils, System.Classes, Data.DB, ME.DB.Entity, ME.DB.DAO, ME.DB.Service,
  ME.DB.Map, ME.DB.Layer, ME.DB.Marker, ME.DAO.Map, ME.DB.Quest;

type
  TMapService = class(TServiceCommon)
  private
    function GetMapDAO: TMapDAO;
  protected
    function GetDAOClass: TDAOClass; override;
  public
    function GetAt(ID: Integer; const Entity: TEntity): Boolean; override;
    procedure Insert(const Entity: TEntity); override;
    procedure Update(const Entity: TEntity); override;
    procedure Remove(const ID: Variant); override;

    procedure LoadLayers(const Map: TMap; LoadPicture: Boolean);
    procedure LoadMarkers(const Map: TMap);
    procedure LoadQuests(const Map: TMap);

    property MapDAO: TMapDAO read GetMapDAO;
  end;

var
  MapService: TMapService;

implementation

uses
  ME.DB.Utils, ME.Service.Layer, ME.Service.Marker,
  ME.Service.Quest;

{ TMapService }

function TMapService.GetMapDAO: TMapDAO;
begin
  Result := TMapDAO(DAO);
end;

function TMapService.GetDAOClass: TDAOClass;
begin
  Result := TMapDAO;
end;

function TMapService.GetAt(ID: Integer; const Entity: TEntity): Boolean;
begin
  Result := inherited GetAt(ID, Entity);
end;

procedure TMapService.Insert(const Entity: TEntity);
var
  Map: TMap;
  Layer: TLayer;
  Marker: TMarker;
  Quest: TQuest;
begin
  Map := TMap(Entity);

  StartTransaction;
  try
    DAO.Insert(Map);

    for Layer in Map.Layers do begin
      Layer.MapID := Map.ID;
      LayerService.Insert(Layer);
    end;

    for Marker in Map.Tags do begin
      Marker.MapID := Map.ID;
      MarkerService.Insert(Marker);
    end;

    for Quest in Map.Quests do begin
      Quest.MapID := Map.ID;
      QuestService.Insert(Quest);
    end;

    CommitTransaction;
  except
    RollbackTransaction;
    raise;
  end;
end;

procedure TMapService.Update(const Entity: TEntity);
var
  Map: TMap;
begin
  Map := TMap(Entity);

  StartTransaction;
  try
    DAO.Update(Map);

    CommitTransaction;
  except
    RollbackTransaction;
    raise;
  end;
end;

procedure TMapService.Remove(const ID: Variant);
begin
  StartTransaction;
  try
    MapDAO.RemoveLayers(ID);
    DAO.Remove(ID);

    CommitTransaction;
  except
    RollbackTransaction;
    raise;
  end;
end;

procedure TMapService.LoadLayers(const Map: TMap; LoadPicture: Boolean);
begin
  Map.ClearLevelList;
  MapDAO.LoadLayers(Map, LoadPicture);
end;

procedure TMapService.LoadMarkers(const Map: TMap);
begin
  Map.ClearTagList;
  MarkerService.LoadMarkers(Map.ID, Map.Tags);
end;

procedure TMapService.LoadQuests(const Map: TMap);
begin
  Map.ClearQuestList;
  QuestService.LoadQuests(Map.ID, Map.Quests);
end;

end.

