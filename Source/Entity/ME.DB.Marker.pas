unit ME.DB.Marker;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.DB, ME.DB.Entity;

type
  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);
  TMarkerKindSet = set of TMarkerKind;

  TMarker = class(TEntity)
  private
    FMapID: Variant;
    FQuestID: Variant;
    FName: string;
    FKind: TMarkerKind;
    FLeft: Integer;
    FTop: Integer;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TEntity); overload; override;
    procedure Assign(const DataSet: TDataSet); overload; override;

    class function EntityName: string; override;
    class function FieldList: string; override;
    class function KindToStr(Value: TMarkerKind): string;

    property MapID: Variant read FMapID write FMapID;
    property QuestID: Variant read FQuestID write FQuestID;
    property Name: string read FName write FName;
    property Kind: TMarkerKind read FKind write FKind;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
  end;

implementation

{ TMarker }

constructor TMarker.Create;
begin
  inherited;

  FMapID := Null;
  FQuestID := Null;
  FName := '';
  FKind := TMarkerKind.PMCExtraction;
  FLeft := 0;
  FTop := 0;
end;

destructor TMarker.Destroy;
begin

  inherited;
end;

procedure TMarker.Assign(const Source: TEntity);
begin
  inherited;

  MapID := TMarker(Source).MapID;
  QuestID := TMarker(Source).QuestID;
  Name := TMarker(Source).Name;
  Kind := TMarker(Source).Kind;
  Left := TMarker(Source).Left;
  Top := TMarker(Source).Top;
end;

procedure TMarker.Assign(const DataSet: TDataSet);
begin
  inherited;

  MapID := DataSet.FieldByName('MapID').Value;
  QuestID := DataSet.FieldByName('QuestID').Value;
  Name := DataSet.FieldByName('Name').AsString;
  Kind := TMarkerKind(DataSet.FieldByName('Kind').AsInteger);
  Left := DataSet.FieldByName('Left').AsInteger;
  Top := DataSet.FieldByName('Top').AsInteger;
end;

class function TMarker.EntityName: string;
begin
  Result := 'Marker';
end;

class function TMarker.FieldList: string;
begin
  Result := 'ID, "MapID", "QuestID", "Name", "Kind", "Left", "Top"';
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

end.
