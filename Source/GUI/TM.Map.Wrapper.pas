unit TM.Map.Wrapper;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.UITypes,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.ImgList,
  Map.Data.Types, TM.FilesMonitor, ME.MarkerFilter;

type
  TMarkerIconArray = array[Low(TMarkerKind) .. High(TMarkerKind)] of TBitmap;
  TOnMapChangeEvent = procedure (Bitmap: TBitmap) of object;
  TPositionChangeEvent = procedure (Position: TPoint) of object;

  TMapWrapper = class
  private
    FDirectory: string;
    FTrackLocation: Boolean;
    FMap: TMap;
    FBackground: TBitmap;
    FChangeMonitor: TChangeMonitor;
    FPosition: TPoint;
    FZoom: Integer;
    FImages: TImageList;
    FMarkerIcons: TMarkerIconArray;
    FMarkerFilter: TMarkerFilter;
    FMarkers: TList;
    FOnMapChange: TOnMapChangeEvent;
    FOnPositionChange: TPositionChangeEvent;

    procedure DoMapChange(Bitmap: TBitmap);
    procedure OnFileChange(Sender: TObject);
    procedure SetImages(const Value: TImageList);
    function GetMarkerIcon(Index: TMarkerKind): TBitmap;
    procedure OnFilterChanged(Sender: TObject);
  public
    constructor Create(const Directory: string); virtual;
    destructor Destroy; override;

    function GetScreenshotName: string;
    procedure DeleteAllScreenshots;
    procedure LoadMap(const Value: TMap);

    function ExtractPoint(const FileName: string): TPoint;
    procedure DrawPoint(const Value: TPoint);
    procedure ZoomIn;
    procedure ZoomOut;

    procedure Start;
    procedure Stop;
    procedure Refresh;

    property Map: TMap read FMap;
    property Background: TBitmap read FBackground;
    property Position: TPoint read FPosition;
    property Directory: string read FDirectory;
    property TrackLocation: Boolean read FTrackLocation write FTrackLocation;
    property Images: TImageList read FImages write SetImages;
    property MarkerIcon[Index: TMarkerKind]: TBitmap read GetMarkerIcon;
    property MarkerFilter: TMarkerFilter read FMarkerFilter;
    property Markers: TList read FMarkers;
    property OnMapChange: TOnMapChangeEvent read FOnMapChange write FOnMapChange;
    property OnPositionChange: TPositionChangeEvent read FOnPositionChange write FOnPositionChange;
  end;

implementation

uses
  App.Constants, Map.Data.Service;

{ TMapWrapper }

constructor TMapWrapper.Create(const Directory: string);
begin
  inherited Create;

  FMap := nil;
  FDirectory := Directory;
  FPosition.Empty := True;
  FTrackLocation := True;
  FOnMapChange := nil;
  FChangeMonitor := nil;
  FBackground := TBitmap.Create;
//  FBackground.PixelFormat := pf32bit;
  FZoom := 100;

  FMarkerFilter := TMarkerFilter.Create;
  FMarkerFilter.OnChanged := OnFilterChanged;

  FMarkers := TList.Create;
  FOnPositionChange := nil;
end;

destructor TMapWrapper.Destroy;
begin
  FMarkerFilter.Free;
  FChangeMonitor.Free;
  FOnMapChange := nil;
  FBackground.Free;

  FMarkers.Free;
  FOnPositionChange := nil;

  inherited;
end;

procedure TMapWrapper.DoMapChange(Bitmap: TBitmap);
begin
  if Assigned(FOnMapChange) then
    FOnMapChange(Bitmap);
end;

procedure TMapWrapper.OnFileChange(Sender: TObject);
var
  FileName: string;
  p: TPoint;
begin
  if not TrackLocation then
    Exit;

  FileName := ExtractFileName(GetScreenshotName);
  if Trim(FileName) = '' then
    Exit;
  try
    p := ExtractPoint(FileName);
    DrawPoint(p);
//    Logger.Lines.Add('TPoint.Create({0}, {1})', [p.X, p.Y]);
  finally
    DeleteAllScreenshots;
  end;
end;

procedure TMapWrapper.SetImages(const Value: TImageList);
var
  Kind: TMarkerKind;
begin
  FImages := Value;

  for Kind := Low(TMarkerKind) to High(TMarkerKind) do
    FMarkerIcons[kind] := Images.Bitmap(TSizeF.Create(32, 32), Ord(Kind));
end;

function TMapWrapper.GetMarkerIcon(Index: TMarkerKind): TBitmap;
begin
  Result := FMarkerIcons[Index];
end;

procedure TMapWrapper.OnFilterChanged(Sender: TObject);
begin
  Refresh;
end;

function TMapWrapper.GetScreenshotName: string;
var
  FileName: string;
begin
  for FileName in TDirectory.GetFiles(FDirectory, '*.png', TSearchOption.soTopDirectoryOnly) do
    Exit(FileName);
end;

procedure TMapWrapper.DeleteAllScreenshots;
var
  FileName: string;
begin
  for FileName in TDirectory.GetFiles(FDirectory, '*.png', TSearchOption.soTopDirectoryOnly) do
    TFile.Delete(FileName);
end;

procedure TMapWrapper.LoadMap(const Value: TMap);
const
  FolderName = 'Levels';
  fmtFileName = '%s_%s.png';
var
  Layer: TLayer;
  FileName: string;
begin
  FMap := Value;
  FPosition.Empty := True;
  FZoom := 100;

  Layer := Map.MainLayer;
  if Layer = nil then begin
    FBackground.Assign(nil);
    Exit;
  end;

  FileName := TPath.Combine(AppParams.DataPath, FolderName);
  FileName := TPath.Combine(FileName, Format(fmtFileName, [Map.Name, Layer.Name]));
  FBackground.LoadFromFile(FileName);

  MarkerFilter.Init(Value);
  DrawPoint(FPosition);
end;

function TMapWrapper.ExtractPoint(const FileName: string): TPoint;
var
  k: Integer;
  Str: string;
  List: TStringList;
begin
  List := TStringList.Create;
  try
    List.Delimiter := ',';
    List.DelimitedText := FileName;

    Assert(List.Count > 2);

    Str := Trim(List[0]);
    k := Pos('_', Str);
    Str := Copy(Str, k + 1, Length(Str) - k);
    if FormatSettings.DecimalSeparator = ',' then
      Str := StringReplace(Str, '.', ',', [rfReplaceAll]);
    Result.Left := Round(StrToFloat(Str));

    Str := Trim(List[2]);
    k := Pos('_', Str);
    Str := Copy(Str, 1, k - 1);
    if FormatSettings.DecimalSeparator = ',' then
      Str := StringReplace(Str, '.', ',', [rfReplaceAll]);
    Result.Top := Round(StrToFloat(Str));
  finally
    List.Free;
  end;
end;

procedure TMapWrapper.DrawPoint(const Value: TPoint);
const
  PointColor = $FFE41A10; // $FF53FF53;
var
  bmp: TBitmap;
  p: TPoint;
  Offset: Double;
  src, trg: TRectF;
begin
  FPosition := Value;
  if FMap = nil then
    Exit;

  bmp := TBitmap.Create;
  try
//    bmp.PixelFormat := TPixelFormat.pf32bit;
//    bmp.Assign(FBackground);
    bmp.Height := Trunc(FBackground.Height * (FZoom / 100));
    bmp.Width := Trunc(FBackground.Width * (FZoom / 100));

    src := RectF(0, 0, FBackground.Width, FBackground.Height);
    trg := RectF(0, 0, bmp.Width, bmp.Height);

    bmp.Canvas.BeginScene;
    bmp.Canvas.DrawBitmap(FBackground, src, trg, 1);
    bmp.Canvas.EndScene;

//    if not FPosition.Empty then begin
//      Offset := Abs((FMap.Left - Position.Left) / (FMap.Right - FMap.Left));
//      p.Left := Trunc(bmp.Width * Offset);
//      Offset := Abs((FMap.Top - Position.Top) / (FMap.Bottom - FMap.Top));
//      p.Top := Trunc(bmp.Height * Offset);
//      trg := RectF(p.Left - 3, p.Top - 3, p.Left + 3, p.Top + 3);
//
//      bmp.Canvas.BeginScene;
//      bmp.Canvas.Stroke.Kind := TBrushKind.Solid;
//      bmp.Canvas.Stroke.Thickness := 5.0;
//      bmp.Canvas.Stroke.Color := PointColor;
//      bmp.Canvas.DrawEllipse(trg, 1);
//      bmp.Canvas.EndScene;
//    end;

    DoMapChange(bmp);
  finally
    bmp.Free;
  end;
end;

procedure TMapWrapper.ZoomIn;
begin
  if FZoom < 180 then begin
    Inc(FZoom, 20);
    DrawPoint(Position);
  end;
end;

procedure TMapWrapper.ZoomOut;
begin
  if FZoom < 60 then
    Exit;

  Dec(FZoom, 20);
  DrawPoint(Position);
end;

procedure TMapWrapper.Start;
begin
  if not TDirectory.Exists(FDirectory) then
    raise Exception.Create('The specified directory name is invalid. "' + Directory + '"');

  DeleteAllScreenshots;

  if FChangeMonitor <> nil then begin
    FChangeMonitor.Terminate;
    FChangeMonitor.Free;
  end;

  FChangeMonitor := TChangeMonitor.Create(FDirectory);
  FChangeMonitor.OnChange := OnFileChange;
  FChangeMonitor.Start;
end;

procedure TMapWrapper.Stop;
begin
  if FChangeMonitor <> nil then
    FChangeMonitor.Terminate;
end;

procedure TMapWrapper.Refresh;
begin
  DrawPoint(Position);
end;

end.
