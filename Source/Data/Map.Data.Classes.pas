unit Map.Data.Classes;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections, Map.Data.Types;

type
  TJSONDataImport = class(TObject)
  private
    class procedure LoadLayers(const Source: TJSONValue; Items: PLayerArray);
    class procedure LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
    class procedure LoadQuests(const Source: TJSONValue; Items: PQuestArray);
  public
    class procedure Load(const Data: string; Items: TList<TMap>);
    class procedure LoadFromFile(const FileName: string; Items: TList<TMap>);
  end;

implementation

class procedure TJSONDataImport.LoadLayers(const Source: TJSONValue; Items: PLayerArray);
var
  i: Integer;
  List: TJSONArray;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Items^, List.Count);
  for i := 0 to List.Count - 1 do
    Items^[i].Assign(TJSONObject(List.Items[i]));
end;

class procedure TJSONDataImport.LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
var
  i: Integer;
  List: TJSONArray;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Items^, List.Count);
  for i := 0 to List.Count - 1 do
    Items^[i].Assign(TJSONObject(List.Items[i]));
end;

class procedure TJSONDataImport.LoadQuests(const Source: TJSONValue; Items: PQuestArray);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Items^, List.Count);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Items^[i].Assign(JSONObject);
    LoadMarkers(JSONObject.FindValue('markers'), @(Items^[i].Markers));
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
        LoadLayers(JSONObject.FindValue('layers'), @(Map.Layers));
        LoadMarkers(JSONObject.FindValue('markers'), @(Map.Markers));
        LoadQuests(JSONObject.FindValue('quests'), @(Map.Quests));
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
