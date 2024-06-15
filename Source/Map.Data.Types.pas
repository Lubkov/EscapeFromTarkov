unit Map.Data.Types;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON;

type
  TLayer = record
  private
    FLevel: Integer;
    FName: string;
  public
    procedure Assign(const Source: TJSONValue);

    property Level: Integer read FLevel write FLevel;
    property Name: string read FName write FName;
  end;

  TLayerArray = array of TLayer;
  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);
  TMarkerKindSet = set of TMarkerKind;

  TMarker = record
  private
    FName: string;
    FKind: TMarkerKind;
    FLeft: Integer;
    FTop: Integer;
  public
    procedure Assign(const Source: TJSONValue);

    property Name: string read FName write FName;
    property Kind: TMarkerKind read FKind write FKind;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
  end;

  TMarkerArray = array of TMarker;

  TQuest = record
  private
    FName: string;
    FMarkers: TMarkerArray;
  public
    procedure Assign(const Source: TJSONValue);

    property Name: string read FName write FName;
    property Markers: TMarkerArray read FMarkers write FMarkers;
  end;

  TQuestArray = array of TQuest;

  TMap = record
  private
    FName: string;
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
    FLayers: TLayerArray;
    FMarkers: TMarkerArray;
    FQuests: TQuestArray;
  public
    procedure Assign(const Source: TJSONValue);

    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Right: Integer read FRight write FRight;
    property Bottom: Integer read FBottom write FBottom;
    property Layers: TLayerArray read FLayers write FLayers;
    property Markers: TMarkerArray read FMarkers write FMarkers;
    property Quests: TQuestArray read FQuests write FQuests;
  end;

  TMapArray = array of TMap;

  TJSONDataImport = class(TObject)
  private
    FMapList: TMapArray;
  
    function GetMapItem(Index: Integer): TMap;
    function LoadLayers(const Source: TJSONValue): TLayerArray;
    procedure LoadMarkers(const Source: TJSONValue; var Items: TMarkerArray);
    procedure LoadQuests(const Source: TJSONValue; var Items: TQuestArray);
    procedure SetMapItem(Index: Integer; const Value: TMap);
  public
    procedure Load(const Data: string);
    procedure LoadFromFile(const FileName: string);

    property Map[Index: Integer]: TMap read GetMapItem write SetMapItem; 
  end;

implementation

{ TLayer }

procedure TLayer.Assign(const Source: TJSONValue);
begin
  Level := Source.GetValue<Integer>('level');
  Name := Source.GetValue<string>('name');
end;

{ TMarker }

procedure TMarker.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Kind := TRttiEnumerationType.GetValue<TMarkerKind>(Source.GetValue<string>('kind'));
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
end;

{ TQuest }

procedure TQuest.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
end;

{ TMap }

procedure TMap.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
  Right := Source.GetValue<Integer>('right');
  Bottom := Source.GetValue<Integer>('bottom');
end;

{ TJSONDataImport }

function TJSONDataImport.GetMapItem(Index: Integer): TMap;
begin
  Result := FMapList[Index];
end;

procedure TJSONDataImport.SetMapItem(Index: Integer; const Value: TMap);
begin
  FMapList[Index] := Value;
end;

function TJSONDataImport.LoadLayers(const Source: TJSONValue): TLayerArray;
var
  i: Integer;
  List: TJSONArray;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Result, List.Count);
  for i := 0 to List.Count - 1 do
    Result[i].Assign(TJSONObject(List.Items[i]));
end;

procedure TJSONDataImport.LoadMarkers(const Source: TJSONValue; var Items: TMarkerArray);
var
  i: Integer;
  List: TJSONArray;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Items, List.Count);
  for i := 0 to List.Count - 1 do
    Items[i].Assign(TJSONObject(List.Items[i]));
end;

procedure TJSONDataImport.LoadQuests(const Source: TJSONValue; var Items: TQuestArray);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  SetLength(Items, List.Count);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Items[i].Assign(JSONObject);
    LoadMarkers(JSONObject.FindValue('markers'), Items[i].FMarkers);
  end;
end;

procedure TJSONDataImport.Load(const Data: string);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  List: TJSONArray;
  i: Integer;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := TJSONArray(JSONObject);
  try
    SetLength(FMapList, Root.Count);
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      Map[i].Assign(JSONObject);
      Map[i].FLayers := LoadLayers(JSONObject.FindValue('layers'));
      LoadMarkers(JSONObject.FindValue('markers'), FMapList[i].FMarkers);
      LoadQuests(JSONObject.FindValue('quests'), FMapList[i].FQuests);
    end;
  finally
    Root.Free;
  end;
end;

procedure TJSONDataImport.LoadFromFile(const FileName: string);
begin

end;

end.
