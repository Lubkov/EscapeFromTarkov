unit Map.Data.Types;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections;

const
  MainLayerIndex = 0;

type
  TPoint = record
  private
    FEmpty: Boolean;
    FLeft: Integer;
    FTop: Integer;

    procedure SetLelf(const Value: Integer);
    procedure SetTop(const Value: Integer);
  public
    constructor Create(X, Y: Integer);

    property Left: Integer read FLeft write SetLelf;
    property Top: Integer read FTop write SetTop;
    property Empty: Boolean read FEmpty write FEmpty;
  end;

  TLayer = class
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

  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);
  TMarkerKindSet = set of TMarkerKind;

  TMarker = class
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

  TQuest = class
  private
    FName: string;
    FMarkers: TList<TMarker>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue);
    procedure ClearMarkers;

    property Name: string read FName write FName;
    property Markers: TList<TMarker> read FMarkers write FMarkers;
  end;

  TMap = class(TObject)
  private
    FName: string;
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
    FLayers: TList<TLayer>;
    FMarkers: TList<TMarker>;
    FQuests: TList<TQuest>;

    function GetMainLayer: TLayer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue);
    procedure ClearLevels;
    procedure ClearMarkers;
    procedure ClearQuests;

    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Right: Integer read FRight write FRight;
    property Bottom: Integer read FBottom write FBottom;
    property Layers: TList<TLayer> read FLayers write FLayers;
    property Markers: TList<TMarker> read FMarkers write FMarkers;
    property Quests: TList<TQuest> read FQuests write FQuests;
    property MainLayer: TLayer read GetMainLayer;
  end;

implementation

{ TPoint }

constructor TPoint.Create(X, Y: Integer);
begin
  FLeft := X;
  FTop := Y;
  Self.Empty := False;
end;

procedure TPoint.SetLelf(const Value: Integer);
begin
  FLeft := Value;
  FEmpty := False;
end;

procedure TPoint.SetTop(const Value: Integer);
begin
  FTop := Value;
  FEmpty := False;
end;

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

constructor TQuest.Create;
begin
  inherited;

  FMarkers := TList<TMarker>.Create;
end;

destructor TQuest.Destroy;
begin
  ClearMarkers;
  FMarkers.Free;

  inherited;
end;

procedure TQuest.ClearMarkers;
var
  i: Integer;
begin
  for i := 0 to FMarkers.Count - 1 do
    FMarkers[i].Free;

  FMarkers.Clear;
end;

procedure TQuest.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
end;

{ TMap }

constructor TMap.Create;
begin
  inherited;

  FName := '';
  FLeft := 0;
  FTop := 0;
  FRight := 0;
  FBottom := 0;
  FLayers := TList<TLayer>.Create;
  FMarkers := TList<TMarker>.Create;
  FQuests := TList<TQuest>.Create;
end;

destructor TMap.Destroy;
begin
  ClearLevels;
  FLayers.Free;

  ClearMarkers;
  FMarkers.Free;

  ClearQuests;
  FQuests.Free;

  inherited;
end;

procedure TMap.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
  Right := Source.GetValue<Integer>('right');
  Bottom := Source.GetValue<Integer>('bottom');
end;

procedure TMap.ClearLevels;
var
  i: Integer;
begin
  for i := 0 to FLayers.Count - 1 do
    FLayers[i].Free;

  FLayers.Clear;
end;

procedure TMap.ClearMarkers;
var
  i: Integer;
begin
  for i := 0 to FMarkers.Count - 1 do
    FMarkers[i].Free;

  FMarkers.Clear;
end;

procedure TMap.ClearQuests;
var
  i: Integer;
begin
  for i := 0 to FQuests.Count - 1 do
    FQuests[i].Free;

  FQuests.Clear;
end;

function TMap.GetMainLayer: TLayer;
var
  Layer: TLayer;
begin
  for Layer in FLayers do
    if Layer.IsMainLevel then begin
      Result := Layer;
      Exit;
    end;

  Result := nil;
end;

end.
