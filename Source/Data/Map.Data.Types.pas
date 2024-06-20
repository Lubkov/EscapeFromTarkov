unit Map.Data.Types;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections;

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
  PMarker = ^TMarker;

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

  TMap = class(TObject)
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
    constructor Create;
    destructor Destroy; override;

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

constructor TMap.Create;
begin
  inherited;

end;

destructor TMap.Destroy;
begin

  inherited;
end;

function TMap.GetMainLayer: PLayer;
var
  i: Integer;
begin
  for i := 0 to Length(Layers) - 1  do
    if Layers[i].IsMainLevel then begin
      Result := @Layers[i];
      Exit;
    end;

  Result := nil;
end;

end.
