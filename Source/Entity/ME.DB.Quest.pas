unit ME.DB.Quest;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Generics.Collections,
  Data.DB, ME.DB.Entity, ME.DB.Marker;

type
  TQuest = class(TEntity)
  private
    FMapID: Variant;
    FName: string;
    FMarkers: TList<TMarker>;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TEntity); overload; override;
    procedure Assign(const DataSet: TDataSet); overload; override;

    class function EntityName: string; override;
    class function FieldList: string; override;

    procedure ClearMarkers;

    property MapID: Variant read FMapID write FMapID;
    property Name: string read FName write FName;
    property Markers: TList<TMarker> read FMarkers;
  end;

implementation

{ TQuest }

constructor TQuest.Create;
begin
  inherited;

  FMapID := Null;
  FName := '';
  FMarkers := TList<TMarker>.Create;
end;

destructor TQuest.Destroy;
begin
  ClearMarkers;
  FMarkers.Free;

  inherited;
end;

procedure TQuest.Assign(const Source: TEntity);
begin
  inherited;

  FMapID := TQuest(Source).MapID;
  FName := TQuest(Source).Name;
end;

procedure TQuest.Assign(const DataSet: TDataSet);
begin
  inherited;

  FMapID := DataSet.FieldByName('MapID').Value;
  FName := DataSet.FieldByName('Name').AsString;
end;

class function TQuest.EntityName: string;
begin
  Result := 'Quest';
end;

class function TQuest.FieldList: string;
begin
  Result := 'ID, MapID, Name';
end;

procedure TQuest.ClearMarkers;
var
  i: Integer;
begin
  for i := 0 to FMarkers.Count - 1 do
    FMarkers[i].Free;

  FMarkers.Clear;
end;

end.
