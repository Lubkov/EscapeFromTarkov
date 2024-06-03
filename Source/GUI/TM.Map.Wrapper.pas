unit TM.Map.Wrapper;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Winapi.Windows, Winapi.GDIPAPI,
  Winapi.GDIPOBJ, FMX.Graphics, FMX.ImgList,
  ME.DB.Point, ME.DB.Map, ME.DB.Layer, TM.FilesMonitor, App.Constants
  {, ResUIWrapper, SimpleLogger};

type
  TOnMapChangeEvent = procedure (Bitmap: TBitmap) of object;

  TMapWrapper = class
  private
    FDirectory: string;
    FTrackLocation: Boolean;
    FMap: TMap;
    FBackground: TBitmap;
    FChangeMonitor: TChangeMonitor;
    FOnMapChange: TOnMapChangeEvent;
    FPoint: TPoint;
    FZoom: Integer;
    FImages: TImageList;

    procedure DoMapChange(Bitmap: TBitmap);
    procedure OnFileChange(Sender: TObject);
    procedure DrawMapTags(Bitmap: TBitmap);
  public
    constructor Create(const Directory: string); virtual;
    destructor Destroy; override;

    function GetScreenshotName: string;
    procedure DeleteAllScreenshots;
    procedure LoadMap(const Map: TMap);

    function ExtractPoint(const FileName: string): TPoint;
    procedure DrawPoint(const Value: TPoint);
    procedure ZoomIn;
    procedure ZoomOut;

    procedure Start;
    procedure Stop;
    procedure Refresh;

    property Map: TMap read FMap;
    property Directory: string read FDirectory;
    property TrackLocation: Boolean read FTrackLocation write FTrackLocation;
    property Images: TImageList read FImages write FImages;
    property OnMapChange: TOnMapChangeEvent read FOnMapChange write FOnMapChange;
  end;

implementation

{ TMapWrapper }

constructor TMapWrapper.Create(const Directory: string);
begin
  inherited Create;

  FDirectory := Directory;
  FPoint := nil;
  FTrackLocation := True;
  FOnMapChange := nil;
  FChangeMonitor := nil;
  FBackground := TBitmap.Create;
//  FBackground.PixelFormat := pf32bit;
  FZoom := 100;
end;

destructor TMapWrapper.Destroy;
begin
  FChangeMonitor.Free;
  FOnMapChange := nil;
  FBackground.Free;

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

procedure TMapWrapper.DrawMapTags(Bitmap: TBitmap);

  procedure DrawTag(ico: TBitmap; const Caption: string; Position: TPoint);
  var
    Offset: Double;
  begin
    Offset := Abs((FMap.Left - Position.X) / (FMap.Bottom - FMap.Left));
    Position.X := Trunc(Bitmap.Width * Offset);
    Offset := Abs((FMap.Top - Position.Y) / (FMap.Bottom - FMap.Top));
    Position.Y := Trunc(Bitmap.Height * Offset);

//    Bitmap.Canvas.Draw(Position.X - 16, Position.Y - 16, ico);
//
//    if Trim(Caption) <> '' then begin
//      Bitmap.Canvas.Brush.Color := $00060606;
//      Bitmap.Canvas.Font.Name := 'Tahoma';
//      Bitmap.Canvas.Font.Color := clGreen;
//      Bitmap.Canvas.Font.Style := [fsBold];
//      Bitmap.Canvas.Font.Height := 18;
//      Bitmap.Canvas.TextOut(Position.X + 15, Position.Y - 10, Caption);
//    end;
  end;

const
  PMCExtractionIndex = 0;
  ScavExtractionIndex = 1;
  ShredExtractionIndex = 2;
  QuestPartIndex = 3;
//var
//  Tag: TMapTag;
//  i: Integer;
//  p: TPoint;
//  png: TPngImage;
begin
//  png := TPngImage.Create;
//  try
//    TResIUWrapper.LoadPNGImage('scav_extraction_map_tag_32', png);
//
//    if tagScavExtraction in MapFilter then
//      for Tag in FMap.ScavExtraction do
//        DrawTag(png, Tag.Caption, Tag.Position);
//  finally
//    png.Free;
//  end;
//
//  png := TPngImage.Create;
//  try
//    TResIUWrapper.LoadPNGImage('pmc_extraction_map_tag_32', png);
//
//    if tagPMCExtraction in MapFilter then
//      for Tag in FMap.PMCExtraction do
//        DrawTag(png, Tag.Caption, Tag.Position);
//  finally
//    png.Free;
//  end;
//
//  png := TPngImage.Create;
//  try
//    TResIUWrapper.LoadPNGImage('shared_extraction_map_tag_32', png);
//
//    if tagSharedExtraction in MapFilter then
//      for Tag in FMap.SharedExtraction do
//        DrawTag(png, Tag.Caption, Tag.Position);
//  finally
//    png.Free;
//  end;
//
//  // draw question tags
//  png := TPngImage.Create;
//  try
//    TResIUWrapper.LoadPNGImage('quest_map_tag_32', png);
//
//    for i := 0 to Length(QuestFilter) - 1 do
//      if QuestFilter[i] then
//        for p in Map.Quests[i].Parts do
//          DrawTag(png, '', p);
//  finally
//    png.Free;
//  end;
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

procedure TMapWrapper.LoadMap(const Map: TMap);
var
  Layer: TLayer;
begin
  FMap := Map;
  FPoint := nil;
  FZoom := 100;

  Layer := FMap.MainLayer;
  if Layer <> nil then
    FBackground.Assign(Layer.Picture)
  else
    FBackground.Assign(nil);

  DrawPoint(FPoint);
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
    Result.X := Round(StrToFloat(Str));

    Str := Trim(List[2]);
    k := Pos('_', Str);
    Str := Copy(Str, 1, k - 1);
    if FormatSettings.DecimalSeparator = ',' then
      Str := StringReplace(Str, '.', ',', [rfReplaceAll]);
    Result.Y := Round(StrToFloat(Str));
  finally
    List.Free;
  end;
end;

procedure TMapWrapper.DrawPoint(const Value: TPoint);
const
  PointColor = $0053FF53;
var
  bmp: TBitmap;
  p: TPoint;
  Offset: Double;
begin
  FPoint := Value;

  bmp := TBitmap.Create;
  try
//    bmp.PixelFormat := TPixelFormat.pf32bit;
//    bmp.Assign(FBackground);
    bmp.Height := Trunc(FBackground.Height * (FZoom / 100));
    bmp.Width := Trunc(FBackground.Width * (FZoom / 100));
//    bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), FBackground);

    DrawMapTags(bmp);

    if Value <> nil then begin
      Offset := Abs((FMap.Left - Value.X) / (FMap.Right - FMap.Left));
      p.X := Trunc(bmp.Width * Offset);
      Offset := Abs((FMap.Top - Value.Y) / (FMap.Bottom - FMap.Top));
      p.Y := Trunc(bmp.Height * Offset);

//      bmp.Canvas.Pen.Color := PointColor;
//      bmp.Canvas.Pen.Width := 1;
//      bmp.Canvas.Brush.Color := PointColor;
//      bmp.Canvas.Ellipse(p.X - 5, p.Y - 5, p.X + 5, p.y + 5);
    end;

    DoMapChange(bmp);
  finally
    bmp.Free;
  end;
end;

procedure TMapWrapper.ZoomIn;
begin
  if FZoom < 180 then begin
    Inc(FZoom, 20);
    DrawPoint(FPoint);
  end;
end;

procedure TMapWrapper.ZoomOut;
begin
  if FZoom < 60 then
    Exit;

  Dec(FZoom, 20);
  DrawPoint(FPoint);
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
  DrawPoint(FPoint);
end;

end.
