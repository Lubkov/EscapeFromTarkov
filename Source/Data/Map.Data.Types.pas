unit Map.Data.Types;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON;

const
  MainLayerIndex = 0;

type
  PLayer = ^TLayer;
  TLayer = record
  private
    FLevel: Integer;
    FName: string;
    function GetIsMainLevel: Boolean;
  public
    procedure Assign(const Source: TJSONValue);

    property Level: Integer read FLevel write FLevel;
    property Name: string read FName write FName;
    property IsMainLevel: Boolean read GetIsMainLevel;
  end;

  PLayerArray = ^TLayerArray;
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

    class function KindToStr(Value: TMarkerKind): string; static;

    property Name: string read FName write FName;
    property Kind: TMarkerKind read FKind write FKind;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
  end;

  PMarkerArray = ^TMarkerArray;
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

  PQuestArray = ^TQuestArray;
  TQuestArray = array of TQuest;

  PMap = ^TMap;
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
    function GetMainLayer: PLayer;
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
    property MainLayer: PLayer read GetMainLayer;
  end;

  PMapArray = ^TMapArray;
  TMapArray = array of TMap;

  TJSONData = class(TObject)
  private
    FMapList: TMapArray;
  
    function GetMapItem(Index: Integer): TMap;
    procedure LoadLayers(const Source: TJSONValue; Items: PLayerArray);
    procedure LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
    procedure LoadQuests(const Source: TJSONValue; Items: PQuestArray);
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

function TLayer.GetIsMainLevel: Boolean;
begin
  Result := Level = MainLayerIndex;
end;

{ TMarker }

procedure TMarker.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Kind := TRttiEnumerationType.GetValue<TMarkerKind>(Source.GetValue<string>('kind'));
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
end;

class function TMarker.KindToStr(Value: TMarkerKind): string;
begin
  case Value of
    TMarkerKind.PMCExtraction:
      Result := 'Выход ЧВК';
    TMarkerKind.ScavExtraction:
      Result := 'Выход дикого';
    TMarkerKind.CoopExtraction:
      Result := 'Совм. выход';
  else
    Result := '';
  end;
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

function TMap.GetMainLayer: PLayer;
var
  Layer: TLayer;
begin
  for Layer in Layers do
    if Layer.IsMainLevel then begin
      Result^ := Layer;
      Exit;
    end;

  Result := nil;
end;

{ TJSONData }

function TJSONData.GetMapItem(Index: Integer): TMap;
begin
  Result := FMapList[Index];
end;

procedure TJSONData.SetMapItem(Index: Integer; const Value: TMap);
begin
  FMapList[Index] := Value;
end;

procedure TJSONData.LoadLayers(const Source: TJSONValue; Items: PLayerArray);
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

procedure TJSONData.LoadMarkers(const Source: TJSONValue; Items: PMarkerArray);
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

procedure TJSONData.LoadQuests(const Source: TJSONValue; Items: PQuestArray);
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
    LoadMarkers(JSONObject.FindValue('markers'), @(Items^[i].FMarkers));
  end;
end;

procedure TJSONData.Load(const Data: string);
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
    SetLength(FMapList, Root.Count);
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      Map[i].Assign(JSONObject);
      LoadLayers(JSONObject.FindValue('layers'), @(FMapList[i].FLayers));
      LoadMarkers(JSONObject.FindValue('markers'), @(FMapList[i].FMarkers));
      LoadQuests(JSONObject.FindValue('quests'), @(FMapList[i].FQuests));
    end;
  finally
    Root.Free;
  end;
end;

procedure TJSONData.LoadFromFile(const FileName: string);
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
