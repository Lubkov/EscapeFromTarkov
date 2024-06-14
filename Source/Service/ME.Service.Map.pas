unit ME.Service.Map;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Data.DB, ME.DB.Entity, ME.DB.DAO, ME.DB.Service,
  ME.DB.Map, ME.DB.Layer, ME.DB.Marker, ME.DAO.Map, ME.DB.Quest;

type
  TMapService = class(TServiceCommon)
  private
    function GetMapDAO: TMapDAO;
  protected
    function GetDAOClass: TDAOClass; override;

    procedure LoadLayerFromJSON(const Value: TJSONValue; const Items: TList<TLayer>);
    procedure LoadMarkersFromJSON(const Value: TJSONValue; const Items: TList<TMarker>);
    procedure LoadQuestsFromJSON(const Value: TJSONValue; const Items: TList<TQuest>);
  public
    function GetAt(ID: Integer; const Entity: TEntity): Boolean; override;
    procedure Insert(const Entity: TEntity); override;
    procedure Update(const Entity: TEntity); override;
    procedure Remove(const ID: Variant); override;

    procedure LoadLayers(const Map: TMap; LoadPicture: Boolean);
    procedure LoadMarkers(const Map: TMap);
    procedure LoadQuests(const Map: TMap);

    procedure LoadFromJSON(const Data: string; const Items: TList<TMap>);

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
      LayerService.SavePicture(Layer)
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

procedure TMapService.LoadLayerFromJSON(const Value: TJSONValue; const Items: TList<TLayer>);
var
  i: Integer;
  List: TJSONArray;
  Item: TJSONValue;
  Layer: TLayer;
begin
  if not (Value is TJSONArray) then
    Exit;

  List := Value as TJSONArray;
  for i := 0 to List.Count - 1 do begin
    Item := List.Items[i] as TJSONObject;

    Layer := TLayer.Create;
    try
      Layer.Level := Item.GetValue<Integer>('level');
      Layer.Name := Item.GetValue<string>('name');
    finally
      Items.Add(Layer);
    end;
  end;
end;

procedure TMapService.LoadMarkersFromJSON(const Value: TJSONValue; const Items: TList<TMarker>);
var
  List: TJSONArray;
  Item: TJSONValue;
  Marker: TMarker;
  i: Integer;
begin
  if not (Value is TJSONArray) then
    Exit;

  List := Value as TJSONArray;
  for i := 0 to List.Count - 1 do begin
    Item := List.Items[i] as TJSONObject;

    Marker := TMarker.Create;
    try
      Marker.Name := Item.GetValue<string>('name');
      Marker.Kind := TRttiEnumerationType.GetValue<TMarkerKind>(Item.GetValue<string>('kind'));
      Marker.Left := Item.GetValue<Integer>('left');
      Marker.Top := Item.GetValue<Integer>('top');
    finally
      Items.Add(Marker);
    end;
  end;
end;

procedure TMapService.LoadQuestsFromJSON(const Value: TJSONValue; const Items: TList<TQuest>);
var
  i: Integer;
  List: TJSONArray;
  Item: TJSONValue;
  Quest: TQuest;
begin
  if not (Value is TJSONArray) then
    Exit;

  List := Value as TJSONArray;
  for i := 0 to List.Count - 1 do begin
    Item := List.Items[i] as TJSONObject;

    Quest := TQuest.Create;
    try
      Quest.Name := Item.GetValue<string>('name');

      LoadMarkersFromJSON(Item.FindValue('markers'), Quest.Markers);
    finally
      Items.Add(Quest);
    end;
  end;
end;

procedure TMapService.LoadFromJSON(const Data: string; const Items: TList<TMap>);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  i: Integer;
  Map: TMap;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := JSONObject as TJSONArray;
  try
    for i := 0 to Root.Count - 1 do begin
      JSONObject := Root.Items[i] as TJSONObject;

      Map := TMap.Create;
      try
        Map.Name := JSONObject.GetValue<string>('name');
        Map.Left := JSONObject.GetValue<Integer>('left');
        Map.Top := JSONObject.GetValue<Integer>('top');
        Map.Right := JSONObject.GetValue<Integer>('right');
        Map.Bottom := JSONObject.GetValue<Integer>('bottom');

        LoadLayerFromJSON(JSONObject.FindValue('layers'), Map.Layers);
        LoadMarkersFromJSON(JSONObject.FindValue('markers'), Map.Tags);
        LoadQuestsFromJSON(JSONObject.FindValue('quests'), Map.Quests);
      finally
        Items.Add(Map);
      end;
    end;
  finally
    Root.Free;
  end;
end;

end.

