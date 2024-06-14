unit ME.Service.Export;

interface

uses
  System.SysUtils, System.Classes,  System.Rtti, System.TypInfo, System.SysConst,
  System.JSON, Generics.Collections, Data.DB, ME.DB.Entity, ME.DB.Service,
  ME.DB.Map, ME.DB.Quest, ME.DB.Marker, ME.DB.Layer;

type
  TExportService = class(TObject)
  private
  public
    function ExportToJSON: string;
  end;

implementation

uses
  ME.Service.Layer, ME.Service.Map, ME.Service.Marker, ME.Service.Quest;

{ TExportService }

function TExportService.ExportToJSON: string;

  procedure ExportLayers(Root: TJSONObject; Items: TList<TLayer>);
  var
    Layer: TLayer;
    JSONItems: TJSONArray;
    JSONObject: TJSONObject;
  begin
    JSONItems := TJSONArray.Create;
    for Layer in Items do begin
      JSONObject := TJSONObject.Create;
      try
        JSONObject.AddPair('level', Layer.Level.ToString);
        JSONObject.AddPair('name', Layer.Name);
      finally
        JSONItems.Add(JSONObject);
      end;
    end;
    Root.AddPair('layers', JSONItems);
  end;

  procedure ExportMarkers(Root: TJSONObject; Items: TList<TMarker>);
  var
    Marker: TMarker;
    JSONItems: TJSONArray;
    JSONObject: TJSONObject;
  begin
    JSONItems := TJSONArray.Create;
    for Marker in Items do begin
      JSONObject := TJSONObject.Create;
      try
        JSONObject.AddPair('name', Marker.Name);
        JSONObject.AddPair('kind', TRttiEnumerationType.GetName<TMarkerKind>(Marker.Kind));
        JSONObject.AddPair('left', Marker.Left.ToString);
        JSONObject.AddPair('top', Marker.Top.ToString);
      finally
        JSONItems.Add(JSONObject);
      end;
    end;
    Root.AddPair('markers', JSONItems);
  end;

  procedure ExportQuests(Root: TJSONObject; Items: TList<TQuest>);
  var
    Quest: TQuest;
    JSONItems: TJSONArray;
    JSONObject: TJSONObject;
  begin
    JSONItems := TJSONArray.Create;
    for Quest in Items do begin
      JSONObject := TJSONObject.Create;
      try
        JSONObject.AddPair('name', Quest.Name);

        ExportMarkers(JSONObject, Quest.Markers);
      finally
        JSONItems.Add(JSONObject);
      end;
    end;
    Root.AddPair('quests', JSONItems);
  end;

var
  Source: TList<TEntity>;
  i: Integer;
  Map: TMap;
  Root: TJSONArray;
  JSONObject: TJSONObject;
begin
  Source := TList<TEntity>.Create;
  try
    MapService.GetAll(Source);

    Root := TJSONArray.Create;
    try
      for i := 0 to Source.Count - 1 do begin
        Map := TMap(Source[i]);

        MapService.LoadLayers(Map, False);
        MapService.LoadMarkers(Map);
        MapService.LoadQuests(Map);

        JSONObject := TJSONObject.Create;
        JSONObject.AddPair('name', Map.Name);
        JSONObject.AddPair('left', Map.Left.ToString);
        JSONObject.AddPair('top', Map.Top.ToString);
        JSONObject.AddPair('right', Map.Right.ToString);
        JSONObject.AddPair('bottom', Map.Bottom.ToString);

        ExportLayers(JSONObject, Map.Layers);
        ExportMarkers(JSONObject, Map.Tags);
        ExportQuests(JSONObject, Map.Quests);

        Root.Add(JSONObject);
      end;

      Result := Root.ToJSON;
    finally
      Root.Free;
    end;
  finally
    for i := 0 to Source.Count - 1 do
      Source[i].Free;

    Source.Free;
  end;
end;

end.
