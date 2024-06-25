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
    procedure InternalLoadImage(const Folder, Name, Ext: string; const Dest: TBitmap);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Load(const FileName: string);
    procedure LoadMarkerImage(const Name: string; const Dest: TBitmap);
    procedure LoadItemImage(const Name: string; const Dest: TBitmap);
    procedure LoadIMapIcon(const Name: string; const Dest: TBitmap);

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

procedure TDataSertvice.InternalLoadImage(const Folder, Name, Ext: string; const Dest: TBitmap);
var
  FileName: string;
begin
  FileName := TPath.Combine(AppParams.DataPath, Folder);
  FileName := TPath.Combine(FileName, Name + '.' + Ext);

  if FileExists(FileName) then
    Dest.LoadFromFile(FileName)
  else
    Dest.Assign(nil);
end;

procedure TDataSertvice.LoadMarkerImage(const Name: string; const Dest: TBitmap);
const
  FolderName = 'Markers';
begin
  InternalLoadImage(FolderName, Name, 'png', Dest);
end;

procedure TDataSertvice.LoadItemImage(const Name: string; const Dest: TBitmap);
const
  FolderName = 'Items';
begin
  InternalLoadImage(FolderName, Name, 'png', Dest);
end;

procedure TDataSertvice.LoadIMapIcon(const Name: string; const Dest: TBitmap);
const
  FolderName = 'Maps';
begin
  InternalLoadImage(FolderName, Name, 'jpg', Dest);
end;

end.
