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
    procedure AssignTo(const Dest: TJSONObject);

    property Level: Integer read FLevel write FLevel;
    property Name: string read FName write FName;
    property IsMainLevel: Boolean read GetIsMainLevel;
  end;

  TLocationImage = class
  private
    FName: string;
    FCaption: string;
  public
    procedure Assign(const Source: TJSONValue);
    procedure AssignTo(const Dest: TJSONObject);

    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;

  end;

  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);
  TMarkerKindSet = set of TMarkerKind;

  TMarker = class
  private
    FName: string;
    FCaption: string;
    FKind: TMarkerKind;
    FLeft: Integer;
    FTop: Integer;
    FItems: TList<string>;
    FImages: TList<TLocationImage>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue);
    procedure AssignTo(const Dest: TJSONObject);

    class function KindToStr(Value: TMarkerKind): string; static;

    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property Kind: TMarkerKind read FKind write FKind;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Items: TList<string> read FItems;
    property Images: TList<TLocationImage> read FImages;
  end;

  TTrader = (None, Prapor, Therapist, Skier, Peacemaker, Mechanic, Ragman, Jaeger, Fence, Lightkeeper);

  TQuest = class
  private
    FName: string;
    FCaption: string;
    FTrader: TTrader;
    FMarkers: TList<TMarker>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue);
    procedure AssignTo(const Dest: TJSONObject);
    procedure ClearMarkers;

    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property Trader: TTrader read FTrader write FTrader;
    property Markers: TList<TMarker> read FMarkers write FMarkers;
  end;

  TMap = class(TObject)
  private
    FName: string;
    FCaption: string;
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
    procedure AssignTo(const Dest: TJSONObject);
    procedure ClearLevels;
    procedure ClearMarkers;
    procedure ClearQuests;

    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
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

procedure TLayer.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('level', Level);
  Dest.AddPair('name', Name);
end;

function TLayer.GetIsMainLevel: Boolean;
begin
  Result := Level = MainLayerIndex;
end;

{ TLocationImage }

procedure TLocationImage.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Caption := Source.GetValue<string>('caption');
end;

procedure TLocationImage.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('name', Name);
  Dest.AddPair('caption', Caption);
end;

{ TMarker }

constructor TMarker.Create;
begin
  inherited;

  FItems := TList<string>.Create;
  FImage := '';
end;

destructor TMarker.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TMarker.Assign(const Source: TJSONValue);
begin
  Name := Source.GetValue<string>('name');
  Source.TryGetValue<string>('caption', FCaption);
  Kind := TRttiEnumerationType.GetValue<TMarkerKind>(Source.GetValue<string>('kind'));
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
  Source.TryGetValue<string>('image', FImage);
end;

procedure TMarker.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('name', Name);
  Dest.AddPair('caption', Caption);
  Dest.AddPair('kind', TRttiEnumerationType.GetName<TMarkerKind>(Kind));
  Dest.AddPair('left', Left.ToString);
  Dest.AddPair('top', Top.ToString);
  Dest.AddPair('image', Image);
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
var
  TraderValue: string;
begin
  Name := Source.GetValue<string>('name');
  Source.TryGetValue<string>('caption', FCaption);
  if Source.TryGetValue<string>('trader', TraderValue) then
    Trader := TRttiEnumerationType.GetValue<TTrader>(TraderValue)
  else
    Trader := TTrader.None;
end;

procedure TQuest.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('name', Name);
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
  Caption := Source.GetValue<string>('caption');
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
  Right := Source.GetValue<Integer>('right');
  Bottom := Source.GetValue<Integer>('bottom');
end;

procedure TMap.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('name', Name);
  Dest.AddPair('caption', Caption);
  Dest.AddPair('left', Left);
  Dest.AddPair('top', Top);
  Dest.AddPair('right', Right);
  Dest.AddPair('bottom', Bottom);
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
