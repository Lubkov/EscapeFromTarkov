unit Map.Data.Types;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections, FMX.Graphics;

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

  TEntity = class(TObject)
  private
    FID: string;

    function GetIsNewInstance: Boolean;
  public
    constructor Create; virtual;

    procedure Assign(const Source: TJSONValue); virtual;
    procedure AssignTo(const Dest: TJSONObject); virtual;
    procedure GenerateNewID;

    property ID: string read FID write FID;
    property IsNewInstance: Boolean read GetIsNewInstance;
  end;

  TLayer = class(TEntity)
  private
    FLevel: Integer;
    FCaption: string;

    function GetIsMainLevel: Boolean;
  public
    procedure Assign(const Source: TJSONValue); override;
    procedure AssignTo(const Dest: TJSONObject); override;

    property Level: Integer read FLevel write FLevel;
    property Caption: string read FCaption write FCaption;
    property IsMainLevel: Boolean read GetIsMainLevel;
  end;

  TResource = class(TEntity)
  private
    FDescription: string;
    FBitmap: TBitmap;

    function GetIsEmpty: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue); override;
    procedure AssignTo(const Dest: TJSONObject); override;

    property Description: string read FDescription write FDescription;
    property Bitmap: TBitmap read FBitmap write FBitmap;
    property IsEmpty: Boolean read GetIsEmpty;
  end;

  TResourceClass = class of TResource;

  TQuestItem = class(TEntity)
  end;

  TMarkerImage = class(TResource)
  end;

//  TMarkerImage = class(TEntity)
//  private
//    FCaption: string;
//  public
//    procedure Assign(const Source: TJSONValue); override;
//    procedure AssignTo(const Dest: TJSONObject); override;
//
//    property Caption: string read FCaption write FCaption;
//  end;

  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);
  TMarkerKindSet = set of TMarkerKind;

  TMarker = class(TEntity)
  private
    FCaption: string;
    FKind: TMarkerKind;
    FLeft: Integer;
    FTop: Integer;
    FItems: TObjectList<TQuestItem>;
    FImages: TObjectList<TMarkerImage>;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue); override;
    procedure AssignTo(const Dest: TJSONObject); override;

    class function KindToStr(Value: TMarkerKind): string; static;

    property Caption: string read FCaption write FCaption;
    property Kind: TMarkerKind read FKind write FKind;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Items: TObjectList<TQuestItem> read FItems;
    property Images: TObjectList<TMarkerImage> read FImages;
  end;

  TTrader = (None, Prapor, Therapist, Skier, Peacemaker, Mechanic, Ragman, Jaeger, Fence, Lightkeeper);

  TQuest = class(TEntity)
  private
    FCaption: string;
    FTrader: TTrader;
    FMarkers: TObjectList<TMarker>;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue); override;
    procedure AssignTo(const Dest: TJSONObject); override;

    class function TraderToStr(Value: TTrader): string; static;

    property Caption: string read FCaption write FCaption;
    property Trader: TTrader read FTrader write FTrader;
    property Markers: TObjectList<TMarker> read FMarkers write FMarkers;
  end;

  TMap = class(TEntity)
  private
    FCaption: string;
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
    FLayers: TObjectList<TLayer>;
    FMarkers: TObjectList<TMarker>;
    FQuests: TObjectList<TQuest>;

    function GetMainLayer: TLayer;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TJSONValue); override;
    procedure AssignTo(const Dest: TJSONObject); override;

    property Caption: string read FCaption write FCaption;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Right: Integer read FRight write FRight;
    property Bottom: Integer read FBottom write FBottom;
    property Layers: TObjectList<TLayer> read FLayers write FLayers;
    property Markers: TObjectList<TMarker> read FMarkers write FMarkers;
    property Quests: TObjectList<TQuest> read FQuests write FQuests;
    property MainLayer: TLayer read GetMainLayer;
  end;

  TMapChangedEvent = procedure(const Map: TMap) of object;
  TQuestChangedEvent = procedure(const Quest: TQuest) of object;

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

{ TEntity }

constructor TEntity.Create;
begin
  inherited;

  FID := '';
end;

function TEntity.GetIsNewInstance: Boolean;
begin
  Result := (Trim(FID) = '');
end;

procedure TEntity.Assign(const Source: TJSONValue);
begin
  ID := Source.GetValue<string>('id');
end;

procedure TEntity.AssignTo(const Dest: TJSONObject);
begin
  Dest.AddPair('id', ID);
end;

procedure TEntity.GenerateNewID;
var
  Key: TGUID;
begin
  CreateGUID(Key);
  FID := GUIDToString(Key);
end;

{ TLayer }

procedure TLayer.Assign(const Source: TJSONValue);
begin
  inherited;

  Level := Source.GetValue<Integer>('level');
  Caption := Source.GetValue<string>('caption');
end;

procedure TLayer.AssignTo(const Dest: TJSONObject);
begin
  inherited;

  Dest.AddPair('level', Level.ToString);
  Dest.AddPair('caption', Caption);
end;

function TLayer.GetIsMainLevel: Boolean;
begin
  Result := Level = MainLayerIndex;
end;

{ TResource }

constructor TResource.Create;
begin
  inherited;

  FBitmap := TBitmap.Create;
end;

destructor TResource.Destroy;
begin
  FBitmap.Free;

  inherited;
end;

function TResource.GetIsEmpty: Boolean;
begin
  Result := FBitmap.IsEmpty;
end;

procedure TResource.Assign(const Source: TJSONValue);
begin
  inherited;

  if not Source.TryGetValue<string>('caption', FDescription) then
    FDescription := '';
end;

procedure TResource.AssignTo(const Dest: TJSONObject);
begin
  inherited;

  Dest.AddPair('caption', Description);
end;

//{ TMarkerImage }
//
//procedure TMarkerImage.Assign(const Source: TJSONValue);
//begin
//  inherited;
//
//  Caption := Source.GetValue<string>('caption');
//end;
//
//procedure TMarkerImage.AssignTo(const Dest: TJSONObject);
//begin
//  inherited;
//
//  Dest.AddPair('caption', Caption);
//end;

{ TMarker }

constructor TMarker.Create;
begin
  inherited;

  FItems := TObjectList<TQuestItem>.Create;
  FImages := TObjectList<TMarkerImage>.Create;
end;

destructor TMarker.Destroy;
begin
  FItems.Free;
  FImages.Free;

  inherited;
end;

procedure TMarker.Assign(const Source: TJSONValue);
begin
  inherited;

  FCaption := Source.GetValue<string>('caption');
  Kind := TRttiEnumerationType.GetValue<TMarkerKind>(Source.GetValue<string>('kind'));
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
end;

procedure TMarker.AssignTo(const Dest: TJSONObject);
begin
  inherited;

  Dest.AddPair('caption', Caption);
  Dest.AddPair('kind', TRttiEnumerationType.GetName<TMarkerKind>(Kind));
  Dest.AddPair('left', Left.ToString);
  Dest.AddPair('top', Top.ToString);
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

  FMarkers := TObjectList<TMarker>.Create;
end;

destructor TQuest.Destroy;
begin
  FMarkers.Free;

  inherited;
end;

procedure TQuest.Assign(const Source: TJSONValue);
var
  TraderValue: string;
begin
  inherited;

  FCaption := Source.GetValue<string>('caption');
  TraderValue := Source.GetValue<string>('trader');
  Trader := TRttiEnumerationType.GetValue<TTrader>(TraderValue);
end;

procedure TQuest.AssignTo(const Dest: TJSONObject);
begin
  inherited;

  Dest.AddPair('caption', Caption);
  Dest.AddPair('trader', TRttiEnumerationType.GetName<TTrader>(Trader));
end;

class function TQuest.TraderToStr(Value: TTrader): string;
begin
  case Value of
    TTrader.Prapor:
      Result := 'Прапор';
    TTrader.Therapist:
      Result := 'Терапевт';
    TTrader.Skier:
      Result := 'Лыжник';
    TTrader.Peacemaker:
      Result := 'Миротворец';
    TTrader.Mechanic:
      Result := 'Механик';
    TTrader.Ragman:
      Result := 'Барахольщик';
    TTrader.Jaeger:
      Result := 'Егерь';
    TTrader.Fence:
      Result := 'Скупщик';
    TTrader.Lightkeeper:
      Result := 'Смотритель';
  else
    Result := '';
  end;
end;

{ TMap }

constructor TMap.Create;
begin
  inherited;

  FCaption := '';
  FLeft := 0;
  FTop := 0;
  FRight := 0;
  FBottom := 0;
  FLayers := TObjectList<TLayer>.Create;
  FMarkers := TObjectList<TMarker>.Create;
  FQuests := TObjectList<TQuest>.Create;
end;

destructor TMap.Destroy;
begin
  FLayers.Free;
  FMarkers.Free;
  FQuests.Free;

  inherited;
end;

procedure TMap.Assign(const Source: TJSONValue);
begin
  inherited;

  Caption := Source.GetValue<string>('caption');
  Left := Source.GetValue<Integer>('left');
  Top := Source.GetValue<Integer>('top');
  Right := Source.GetValue<Integer>('right');
  Bottom := Source.GetValue<Integer>('bottom');
end;

procedure TMap.AssignTo(const Dest: TJSONObject);
begin
  inherited;

  Dest.AddPair('caption', Caption);
  Dest.AddPair('left', Left.ToString);
  Dest.AddPair('top', Top.ToString);
  Dest.AddPair('right', Right.ToString);
  Dest.AddPair('bottom', Bottom.ToString);
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
