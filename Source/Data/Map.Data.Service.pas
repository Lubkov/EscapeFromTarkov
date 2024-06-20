unit Map.Data.Service;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.IOUtils,
  Generics.Collections, Map.Data.Types, Map.Data.Classes;

type
  TDataSertvice = class
  private
    FItems: TList<TMap>;

    function GetCount: Integer;
    function GetMapItem(Index: Integer): TMap;
    procedure SetMapItem(Index: Integer; const Value: TMap);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Load(const FileName: string);

    property Items: TList<TMap> read FItems;
    property Count: Integer read GetCount;
    property Map[Index: Integer]: TMap read GetMapItem write SetMapItem;
  end;

var
  DataSertvice: TDataSertvice;

implementation

uses
  App.Constants;

{ TDataSertvice }

constructor TDataSertvice.Create;
begin
  inherited;

  FItems := TList<TMap>.Create;
end;

destructor TDataSertvice.Destroy;
begin
  Clear;
  FItems.Free;

  inherited;
end;

function TDataSertvice.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDataSertvice.GetMapItem(Index: Integer): TMap;
begin
  Result := Items[Index];
end;

procedure TDataSertvice.SetMapItem(Index: Integer; const Value: TMap);
begin
  Items[Index] := Value;
end;

procedure TDataSertvice.Clear;
var
  i: Integer;
begin
  try
    for i := 0 to FItems.Count - 1 do
      FItems[i].Free;
  finally
    FItems.Clear;
  end;
end;

procedure TDataSertvice.Load(const FileName: string);
var
  Data: TStrings;
  DataImport: TJSONDataImport;
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);

    DataImport := TJSONDataImport.Create;
    try
      DataImport.Load(Data.Text, Items);
    finally
      DataImport.Free;
    end;
  finally
    Data.Free;
  end;
end;

end.
