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
    procedure ExportToJSON(const FileName: string);
  end;

implementation

uses
  ME.Service.Layer, ME.Service.Map, ME.Service.Marker, ME.Service.Quest;

{ TExportService }

procedure TExportService.ExportToJSON(const FileName: string);

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
        JSONObject.AddPair('level', Layer.Level);
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
        JSONObject.AddPair('left', Marker.Left);
        JSONObject.AddPair('top', Marker.Top);
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

  procedure SaveToFile(Data: TJSONArray);
  var
    List: TStrings;
  begin
    List := TStringList.Create;
    try
      List.Add(Data.ToJSON);
      List.SaveToFile(FileName);
    finally
      List.Free;
    end;
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
        JSONObject.AddPair('left', Map.Left);
        JSONObject.AddPair('top', Map.Top);
        JSONObject.AddPair('right', Map.Right);
        JSONObject.AddPair('bottom', Map.Bottom);

        ExportLayers(JSONObject, Map.Layers);
        ExportMarkers(JSONObject, Map.Tags);
        ExportQuests(JSONObject, Map.Quests);

        Root.Add(JSONObject);
      end;

      SaveToFile(Root);
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
