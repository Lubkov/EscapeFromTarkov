﻿unit ME.MapTag;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.DB, ME.DB.Entity,
  ME.Point;

type
  TTagKind = (tkPMCExtraction, tkScavExtraction, tkCoopExtraction);

  TMapTag = class(TEntity)
  private
    FMapID: Variant;
    FName: string;
    FKind: TTagKind;
    FPosition: TPoint;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(const Source: TEntity); overload; override;
    procedure Assign(const DataSet: TDataSet); overload; override;

    class function EntityName: string; override;
    class function FieldList: string; override;
    class function KindToStr(Value: TTagKind): string;

    property MapID: Variant read FMapID write FMapID;
    property Name: string read FName write FName;
    property Kind: TTagKind read FKind write FKind;
    property Position: TPoint read FPosition write FPosition;
  end;

implementation

{ TMapTag }

constructor TMapTag.Create;
begin
  inherited;

  FMapID := Null;
  FName := '';
  FKind := tkPMCExtraction;
  FPosition := TPoint.Create;
end;

destructor TMapTag.Destroy;
begin
  FPosition.Free;

  inherited;
end;

procedure TMapTag.Assign(const Source: TEntity);
begin
  FMapID := TMapTag(Source).MapID;
  FName := TMapTag(Source).Name;
  FKind := TMapTag(Source).Kind;
  FPosition.Assign(TMapTag(Source).Position);
end;

procedure TMapTag.Assign(const DataSet: TDataSet);
begin
  FMapID := DataSet.FieldByName('MapID').Value;
  FName := DataSet.FieldByName('Name').AsString;
  FKind := TTagKind(DataSet.FieldByName('Kind').AsInteger);
  FPosition.Assign(DataSet);
end;

class function TMapTag.EntityName: string;
begin
  Result := 'MapTag';
end;

class function TMapTag.FieldList: string;
begin
  Result := 'ID, MapID, Name, Kind, Position';
end;

class function TMapTag.KindToStr(Value: TTagKind): string;
begin
  case Value of
    tkPMCExtraction:
      Result := 'Выход ЧВК';
    tkScavExtraction:
      Result := 'Выход дикого';
    tkCoopExtraction:
      Result := 'Совм. выход';
  else
    Result := '';
  end;
end;

end.