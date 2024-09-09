unit Map.Data.Service;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.IOUtils, FMX.Graphics,
  Generics.Collections, ME.DB.Entity, ME.DB.Map;

type
  TDataService = class
  private
    FItems: TObjectList<TDBMap>;

    function GetCount: Integer;
    function GetMapItem(Index: Integer): TDBMap;
    procedure SetMapItem(Index: Integer; const Value: TDBMap);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(const FileName: string);

    function GetSourceFileName(const Source: TEntity): string;
    procedure LoadImage(const Source: TEntity; const Dest: TBitmap);
    procedure SaveImage(const Source: TEntity; const Dest: TBitmap);
    procedure DeleteImage(const Source: TEntity);

    property Items: TObjectList<TDBMap> read FItems;
    property Count: Integer read GetCount;
    property Map[Index: Integer]: TDBMap read GetMapItem write SetMapItem;
  end;

var
  DataService: TDataService;

implementation

uses
  App.Constants, ME.Service.Map;

{ TDataService }

constructor TDataService.Create;
begin
  inherited;

  FItems := TObjectList<TDBMap>.Create;
end;

destructor TDataService.Destroy;
begin
  FItems.Free;

  inherited;
end;

function TDataService.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDataService.GetMapItem(Index: Integer): TDBMap;
begin
  Result := Items[Index];
end;

procedure TDataService.SetMapItem(Index: Integer; const Value: TDBMap);
begin
  Items[Index] := Value;
end;

procedure TDataService.Load(const FileName: string);
//var
//  Data: TStrings;
begin
  MapService.GetAll(TList<TEntity>(FItems));
//  Data := TStringList.Create;
//  try
//    Data.LoadFromFile(FileName, TEncoding.UTF8);
//    TJSONDataImport.Load(Data.Text, Items);
//  finally
//    Data.Free;
//  end;
end;

function TDataService.GetSourceFileName(const Source: TEntity): string;
//var
//  Folder, Ext: string;
begin
//  if Source is TDBMap then begin
//    Folder := 'Maps';
//    Ext := 'jpg';
//  end
//  else
//  if Source is TLayer then begin
//    Folder := 'Levels';
//    Ext := 'png';
//  end
//  else
//  if Source is TQuestItem then begin
//    Folder := 'Items';
//    Ext := 'png';
//  end
//  else
//  if Source is TResource then begin
//    Folder := 'Markers';
//    Ext := 'jpg';
//  end;
//
//  Result := TPath.Combine(AppParams.DataPath, TPath.Combine(Folder, Source.ID + '.' + Ext));
end;

procedure TDataService.LoadImage(const Source: TEntity; const Dest: TBitmap);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if FileExists(FileName) then
    Dest.LoadFromFile(FileName)
  else
    Dest.Assign(nil);
end;

procedure TDataService.SaveImage(const Source: TEntity; const Dest: TBitmap);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if Dest.IsEmpty then
    DeleteImage(Source)
  else
    Dest.SaveToFile(FileName);
end;

procedure TDataService.DeleteImage(const Source: TEntity);
var
  FileName: string;
begin
  FileName := GetSourceFileName(Source);

  if FileExists(FileName) then
    TFile.Delete(FileName);
end;

end.
