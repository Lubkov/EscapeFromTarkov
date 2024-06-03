unit ME.DB.Map;

interface

uses
  System.SysUtils, System.Classes, System.Variants, FMX.Graphics, Generics.Collections,
  Data.DB, ME.DB.Entity, ME.DB.Layer, ME.DB.Marker, ME.DB.Quest;

type
  TMap = class(TEntity)
  private
    FName: string;
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
    FPicture: TBitmap;
    FLayers: TList<TLayer>;
    FTags: TList<TMarker>;
    FQuests: TList<TQuest>;

    procedure SetPicture(const Value: TBitmap);
    function GetMainLayer: TLayer;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TEntity); overload; override;
    procedure Assign(const DataSet: TDataSet); overload; override;

    class function EntityName: string; override;
    class function FieldList: string; override;

    procedure ClearLevelList;
    procedure ClearTagList;
    procedure ClearQuestList;

    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Right: Integer read FRight write FRight;
    property Bottom: Integer read FBottom write FBottom;
    property Picture: TBitmap read FPicture write SetPicture;
    property Layers: TList<TLayer> read FLayers;
    property Tags: TList<TMarker> read FTags;
    property Quests: TList<TQuest> read FQuests;
    property MainLayer: TLayer read GetMainLayer;
  end;

implementation

{ TMap }

constructor TMap.Create;
begin
  inherited;

  FName := '';
  FLeft := 0;
  FTop := 0;
  FRight := 0;
  FBottom := 0;
  FPicture := TBitmap.Create;
  FLayers := TList<TLayer>.Create;
  FTags := TList<TMarker>.Create;
  FQuests := TList<TQuest>.Create;
end;

destructor TMap.Destroy;
begin
  FPicture.Free;

  ClearLevelList;
  FLayers.Free;

  ClearTagList;
  FTags.Free;

  ClearQuestList;
  FQuests.Free;

  inherited;
end;

procedure TMap.SetPicture(const Value: TBitmap);
begin
  FPicture.Assign(Value);
end;

function TMap.GetMainLayer: TLayer;
var
  Layer: TLayer;
begin
  Result := nil;
  for Layer in Layers do
    if Layer.IsMainLevel then begin
      Result := Layer;
      Exit;
    end;
end;

procedure TMap.Assign(const Source: TEntity);
var
  Map: TMap;
begin
  inherited;

  Map := TMap(Source);
  FName := Map.Name;
  FLeft := Map.Left;
  FTop := Map.Top;
  FRight := Map.Right;
  FBottom := Map.Bottom;
  Picture := TMap(Source).Picture;
end;

procedure TMap.Assign(const DataSet: TDataSet);
begin
  inherited;

  FName := DataSet.FieldByName('Name').AsString;
  FLeft := DataSet.FieldByName('Left').AsInteger;
  FTop := DataSet.FieldByName('Top').AsInteger;
  FRight := DataSet.FieldByName('Right').AsInteger;
  FBottom := DataSet.FieldByName('Bottom').AsInteger;

  if DataSet.FindField('Picture') <> nil then
    AssignPicture(DataSet.FieldByName('Picture'), Picture);
end;

class function TMap.EntityName: string;
begin
  Result := 'Map';
end;

class function TMap.FieldList: string;
begin
  Result := 'ID, "Name", "Left", "Top", "Right", "Bottom"';
end;

procedure TMap.ClearLevelList;
var
  i: Integer;
begin
  for i := 0 to FLayers.Count - 1 do
    FLayers[i].Free;

  FLayers.Clear;
end;

procedure TMap.ClearTagList;
var
  i: Integer;
begin
  for i := 0 to FTags.Count - 1 do
    FTags[i].Free;

  FTags.Clear;
end;

procedure TMap.ClearQuestList;
var
  i: Integer;
begin
  for i := 0 to FQuests.Count - 1 do
    FQuests[i].Free;

  FQuests.Clear;
end;

end.
