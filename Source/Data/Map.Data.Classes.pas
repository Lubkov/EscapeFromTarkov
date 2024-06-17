unit Map.Data.Classes;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Map.Data.Types;

type
  TJSONDataImport = class(TObject)
  private
    procedure LoadLayers(const Source: TJSONValue; Items: PLayerArray);
    procedure LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
    procedure LoadQuests(const Source: TJSONValue; Items: PQuestArray);
  public
    procedure Load(const Data: string; Items: PMapArray);
    procedure LoadFromFile(const FileName: string; Items: PMapArray);
  end;

  TJSONMapData = class(TObject)
  private
    FMapArray: TMapArray;

    function GetMapItem(Index: Integer): TMap;
    procedure SetMapItem(Index: Integer; const Value: TMap);
    function GetCount: Integer;
  public
    procedure Clear;
    procedure Load(const Data: string);
    procedure LoadFromFile(const FileName: string);

    property Count: Integer read GetCount;
    property Map[Index: Integer]: TMap read GetMapItem write SetMapItem;
  end;

implementation

procedure TJSONDataImport.LoadLayers(const Source: TJSONValue; Items: PLayerArray);
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

procedure TJSONDataImport.LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
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

procedure TJSONDataImport.LoadQuests(const Source: TJSONValue; Items: PQuestArray);
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

procedure TJSONDataImport.Load(const Data: string; Items: PMapArray);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  List: TJSONArray;
  i: Integer;
  Layers: TLayerArray;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := TJSONArray(JSONObject);
  try
    SetLength(Items^, Root.Count);
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      Items^[i].Assign(JSONObject);
      LoadLayers(JSONObject.FindValue('layers'), @(Items^[i].Layers));
      LoadMarkers(JSONObject.FindValue('markers'), @(Items^[i].Markers));
      LoadQuests(JSONObject.FindValue('quests'), @(Items^[i].Quests));
    end;
  finally
    Root.Free;
  end;
end;

procedure TJSONDataImport.LoadFromFile(const FileName: string; Items: PMapArray);
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

{ TJSONMapData }

function TJSONMapData.GetCount: Integer;
begin
  Result := Length(FMapArray);
end;

function TJSONMapData.GetMapItem(Index: Integer): TMap;
begin
  Result := FMapArray[Index];
end;

procedure TJSONMapData.SetMapItem(Index: Integer; const Value: TMap);
begin
  FMapArray[Index] := Value;
end;

procedure TJSONMapData.Clear;
begin
  SetLength(FMapArray, 0);
end;

procedure TJSONMapData.Load(const Data: string);
var
  DataImport: TJSONDataImport;
begin
  Clear;

  DataImport := TJSONDataImport.Create;
  try
    DataImport.Load(Data, @FMapArray);
  finally
    DataImport.Free;
  end;
end;

procedure TJSONMapData.LoadFromFile(const FileName: string);
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);
    Load(Data.Text);
  finally
    Data.Free;
  end;
end;

end.
