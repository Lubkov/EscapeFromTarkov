unit Map.Data.Classes;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections, Map.Data.Types;

type
  TJSONDataImport = class(TObject)
  private
    class procedure LoadLayers(const Source: TJSONValue; Items: TList<TLayer>);
    class procedure LoadMarkers(const Source: TJSONValue; Items: TList<TMarker>);
    class procedure LoadMarkerItems(const Source: TJSONValue; Items: TList<string>);
    class procedure LoadQuests(const Source: TJSONValue; Items: TList<TQuest>);
  public
    class procedure Load(const Data: string; Items: TList<TMap>);
    class procedure LoadFromFile(const FileName: string; Items: TList<TMap>);
  end;

implementation

class procedure TJSONDataImport.LoadLayers(const Source: TJSONValue; Items: TList<TLayer>);
var
  i: Integer;
  List: TJSONArray;
  Layer: TLayer;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    Layer := TLayer.Create;
    try
      Layer.Assign(TJSONObject(List.Items[i]));
    finally
      Items.Add(Layer);
    end;
  end;
end;

class procedure TJSONDataImport.LoadMarkers(const Source: TJSONValue; Items: TList<TMarker>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  Marker: TMarker;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Marker := TMarker.Create;
    try
      Marker.Assign(JSONObject);
      LoadMarkerItems(JSONObject.FindValue('items'), Marker.Items);
    finally
      Items.Add(Marker);
    end;
  end;
end;

class procedure TJSONDataImport.LoadMarkerItems(const Source: TJSONValue; Items: TList<string>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
begin
  if (Source = nil) or not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Items.Add(JSONObject.GetValue<string>('id'));
  end;
end;

class procedure TJSONDataImport.LoadQuests(const Source: TJSONValue; Items: TList<TQuest>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  Quest: TQuest;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Quest := TQuest.Create;
    try
      Quest.Assign(JSONObject);
      LoadMarkers(JSONObject.FindValue('markers'), Quest.Markers);
    finally
      Items.Add(Quest);
    end;
  end;
end;

class procedure TJSONDataImport.Load(const Data: string; Items: TList<TMap>);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  Map: TMap;
  i: Integer;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := TJSONArray(JSONObject);
  try
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      Map := TMap.Create;
      try
        Map.Assign(JSONObject);
        LoadLayers(JSONObject.FindValue('layers'), Map.Layers);
        LoadMarkers(JSONObject.FindValue('markers'), Map.Markers);
        LoadQuests(JSONObject.FindValue('quests'), Map.Quests);
      finally
        Items.Add(Map);
      end;
    end;
  finally
    Root.Free;
  end;
end;

class procedure TJSONDataImport.LoadFromFile(const FileName: string; Items: TList<TMap>);
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);
    Load(Data.Text, Items);
  finally
    Data.Free;
  end;
end;

end.
