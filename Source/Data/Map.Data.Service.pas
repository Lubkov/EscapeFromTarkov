unit Map.Data.Service;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.IOUtils, FMX.Graphics,
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

    function GetSourceFileName(const Source: TEntity): string;
    procedure LoadImage(const Source: TEntity; const Dest: TBitmap);
    procedure SaveImage(const Source: TEntity; const Dest: TBitmap);
    procedure DeleteImage(const Source: TEntity);

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
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);
    TJSONDataImport.Load(Data.Text, Items);
  finally
    Data.Free;
  end;
end;

function TDataSertvice.GetSourceFileName(const Source: TEntity): string;
var
  Folder, Ext: string;
begin
  if Source is TMap then begin
    Folder := 'Maps';
    Ext := 'jpg';
  end
  else
  if Source is TLayer then begin
    Folder := 'Levels';
    Ext := 'png';
  end
  else
  if Source is TQuestItem then begin
    Folder := 'Items';
    Ext := 'png';
  end
  else
  if Source is TResource then begin
    Folder := 'Markers';
    Ext := 'jpg';
  end;

  Result := TPath.Combine(AppParams.DataPath, TPath.Combine(Folder, Source.ID + '.' + Ext));
end;

procedure TDataSertvice.LoadImage(const Source: TEntity; const Dest: TBitmap);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if FileExists(FileName) then
    Dest.LoadFromFile(FileName)
  else
    Dest.Assign(nil);
end;

procedure TDataSertvice.SaveImage(const Source: TEntity; const Dest: TBitmap);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if Dest.IsEmpty then
    DeleteImage(Source)
  else
    Dest.SaveToFile(FileName);
end;

procedure TDataSertvice.DeleteImage(const Source: TEntity);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if FileExists(FileName) then
    TFile.Delete(FileName);
end;

end.
