unit Map.Frame.InteractiveMap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Objects, FMX.Layouts, TM.Form.Wrapper, FMX.Controls.Presentation,
  System.ImageList, FMX.ImgList, TM.Map.Wrapper, ME.MarkerFilter, Map.Data.Types,
  Map.Frame.Marker;

type
  TInteractiveMap = class(TFrame)
    MainContainer2: TScrollBox;
    Background: TImage;
    MainContainer: TLayout;
    MapTagImages: TImageList;
    PositionImage: TImage;
    MarkerPanel: TPanel;

    procedure BackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure BackgroundMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BackgroundDblClick(Sender: TObject);
    procedure BackgroundMouseLeave(Sender: TObject);
  private
    FMapWrapper: TMapWrapper;
    FMousePosition: TMousePosition;
    FItems: TList<TImage>;
    FMarkerDescript: TMarkerDescript;
    FOnDoubleClick: TNotifyEvent;
    FOnMouseDown: TNotifyEvent;

  {$IFDEF DEBUG}
    FTestData: array of string;
    FTestIndex: Integer;
  {$ENDIF}

    function GetBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
    procedure OnMapChange(Bitmap: TBitmap);
    function GetMarkerFilter: TMarkerFilter;
    function GetMap: TMap;
    procedure SetMap(const Value: TMap);

    procedure Clear;
    procedure AddMarker(const Marker: TMarker; const Title: string; Trader: TTrader);
    procedure AddPosition(const Position: TPoint);
    procedure OnMarkerClick(Sender: TObject);
    procedure OnMarkerDescriptionClose(Sender: TObject);
    function GetMarkerInfoVisible: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Center;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure SetMouseDown(const Value: Boolean);
    procedure HideMarkerInfo;

  {$IFDEF DEBUG}
    procedure TestPosition;
  {$ENDIF}

    property Map: TMap read GetMap write SetMap;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property MarkerFilter: TMarkerFilter read GetMarkerFilter;
    property MarkerInfoVisible: Boolean read GetMarkerInfoVisible;
    property OnDoubleClick: TNotifyEvent read FOnDoubleClick write FOnDoubleClick;
    property OnMouseDown: TNotifyEvent read FOnMouseDown write FOnMouseDown;
  end;

implementation

uses
  App.Constants;

{$R *.fmx}

{ TInteractiveMap }

constructor TInteractiveMap.Create(AOwner: TComponent);
begin
  inherited;

  Background.Position.X := 0;
  Background.Position.Y := 0;
  FOnDoubleClick := nil;
  FOnMouseDown := nil;

  FMapWrapper := TMapWrapper.Create(AppParams.SreenshotPath);
  FMapWrapper.TrackLocation := AppParams.TrackLocation;
  FMapWrapper.Images := MapTagImages;
  FMapWrapper.OnMapChange := OnMapChange;

  FMarkerDescript := TMarkerDescript.Create(Self);
  FMarkerDescript.Parent := MarkerPanel;
  FMarkerDescript.Align := TAlignLayout.Client;
  FMarkerDescript.OnClose := OnMarkerDescriptionClose;

  FItems := TList<TImage>.Create;

  PositionImage.Visible := False;
  MarkerPanel.Visible := False;
  MarkerPanel.Height := 400;
  MarkerPanel.Width := 560;

{$IFDEF DEBUG}
  SetLength(FTestData, 8);
  FTestData[0] := '2024-07-06[22-01]_0.0, 0.0, 0.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FTestData[1] := '2024-07-05[13-20]_234.2, -9.3, -6.7_0.0, 0.8, 0.0, -0.6_15.40 (0).png';
  FTestData[2] := '2024-07-05[13-22]_186.7, -3.4, 20.5_-0.1, 0.8, -0.1, -0.6_15.62 (0).png';
  FTestData[3] := '2024-07-05[13-23]_88.8, -5.5, -14.1_0.1, -0.7, 0.1, 0.8_15.79 (0).png';
  FTestData[4] := '2024-07-05[13-26]_-13.2, 19.9, 203.3_0.0, -1.0, 0.1, 0.3_16.07 (0).png';
  FTestData[5] := '2024-07-08[21-18]_0.0, 0.0, -100.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FTestData[6] := '2024-07-08[21-19]_0.0, 0.0, 100.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FTestData[7] := '2024-07-08[21-19]_100.0, 0.0, 0.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';

  FTestIndex := -1;
{$ENDIF}
end;

destructor TInteractiveMap.Destroy;
begin
  FOnDoubleClick := nil;
  FOnMouseDown := nil;
  FMapWrapper.Free;

  Clear;
  FItems.Free;

  inherited;
end;

function TInteractiveMap.GetBitmap: TBitmap;
begin
  Result := Background.Bitmap;
end;

procedure TInteractiveMap.SetBitmap(const Value: TBitmap);
begin
  Background.Width := Value.Width;
  Background.Height := Value.Height;
  Background.Bitmap.Assign(nil);
  Background.Bitmap.Assign(Value);
  Background.Visible := not Value.IsEmpty;
end;

procedure TInteractiveMap.OnMapChange(Bitmap: TBitmap);
var
  Marker: TMarker;
  Quest: TQuest;
  i: Integer;
begin
//{$IFNDEF DEBUG}
//  Logger.Lines.Add('OnMapChange');
//{$ENDIF}

  Self.Bitmap := Bitmap;

  Clear;
  for Marker in Map.Markers do
    if MarkerFilter.IsGropupEnable(Marker.Kind) then
      AddMarker(Marker, Marker.Caption, TTrader.None);

  for i := 0 to Map.Quests.Count - 1 do begin
    Quest := Map.Quests[i];

    if MarkerFilter.IsQuestEnable(i) then
      for Marker in Quest.Markers do
        AddMarker(Marker, Quest.Caption, Quest.Trader);
  end;

  AddPosition(FMapWrapper.Position);
end;

function TInteractiveMap.GetMarkerFilter: TMarkerFilter;
begin
  Result := FMapWrapper.MarkerFilter;
end;

function TInteractiveMap.GetMarkerInfoVisible: Boolean;
begin
  Result := MarkerPanel.Visible;
end;

function TInteractiveMap.GetMap: TMap;
begin
  Result := FMapWrapper.Map;
end;

procedure TInteractiveMap.SetMap(const Value: TMap);
begin
  if (Value = nil) or (FMapWrapper.Map = Value) then
    Exit;

  FMapWrapper.LoadMap(Value);
  FMapWrapper.Start;
end;

procedure TInteractiveMap.Clear;
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

procedure TInteractiveMap.AddMarker(const Marker: TMarker; const Title: string; Trader: TTrader);
const
  MarkerHeight = 32;
  MarkerWidth = 32;
var
  Item: TImage;
  Offset: Double;
  Left, Top: Integer;
begin
  Offset := Abs((Map.Top - Marker.Top) / (Map.Bottom - Map.Top));
  Top := Trunc(Bitmap.Height * Offset) - MarkerHeight div 2;
  Offset := Abs((Map.Left - Marker.Left) / (Map.Right - Map.Left));
  Left := Trunc(Bitmap.Width * Offset) - MarkerWidth div 2;

  Item := TImage.Create(Self);
  try
    Item.Height := MarkerHeight;
    Item.Width := MarkerWidth;
    Item.Parent := Background;
    Item.Position.X := Left;
    Item.Position.Y := Top;
    Item.Bitmap.Assign(MapTagImages.Bitmap(TSizeF.Create(32, 32), Ord(Marker.Kind)));
    Item.Hint := Title;
    Item.ShowHint := Trim(Title) <> '';
    Item.OnClick := OnMarkerClick;
    Item.TagObject := Marker;
    Item.Tag := Ord(Trader);

    if (Marker.Images.Count > 0) and (Trim(Marker.Images[0].Description) <> '') then
      Item.Cursor := crHandPoint
    else
      Item.Cursor := crDefault;
  finally
    FItems.Add(Item);
  end;
end;

procedure TInteractiveMap.AddPosition(const Position: TPoint);
const
  MarkerHeight = 16;
  MarkerWidth = 16;
  Angle = 3.66519; // 0.523599; //0.523599;  0.268
var
  Offset: Double;
  Left: Single;
  Top: Single;
  x, y: Single;
begin
// ��������� ���������� ������ ������� �������
// x(0) = 600, y(0) = 520
// x(100) = 406, y(0) = 572)

//  Position.Left := Trunc(Position.Left * cos(0.268) + Position.Top * sin(0.268));
//  Position.Top := (-1) * Trunc(Position.Left * sin(0.268) + Position.Top * cos(0.268));

//  x := Position.Left;
//  y := Position.Top;
//  x := (-1) * Trunc(x * cos(Angle) - y * sin(Angle));
//  y := (-1) * Trunc(x * sin(Angle) + y * cos(Angle));
//  y := (-1) * y;
//  x := (-1) * x;
//  y := (-1) * y;
//  Left := 402 - Position.Left * (Bitmap.Width / 627);
//  Top := 380 + Position.Top * (Bitmap.Height / 639);

//  Left := 402 - Position.Left * 1.85;
//  Top := 380 + Position.Top * 1.4;
  // 426, 664
  // -13, 203
  // 1.85 1.4

//  Left := Left - MarkerWidth div 2;
//  Top := Top - MarkerHeight div 2;
//  Offset := Abs((Map.Top - y) / (Map.Bottom - Map.Top));
//  Top := Trunc(Bitmap.Height * Offset) - MarkerHeight div 2;
//  Offset := Abs((Map.Left - x) / (Map.Right - Map.Left));
//  Left := Trunc(Bitmap.Width * Offset) - MarkerWidth div 2;

//  Left := Trunc(Left * cos(Angle) - Top * sin(Angle));
//  Top := Trunc(Left * sin(Angle) + Top * cos(Angle));

  Offset := Abs((Map.Top - Position.Top) / (Map.Bottom - Map.Top));
  Top := Trunc(Bitmap.Height * Offset) - MarkerHeight div 2;
  Offset := Abs((Map.Left - Position.Left) / (Map.Right - Map.Left));
  Left := Trunc(Bitmap.Width * Offset) - MarkerWidth div 2;

//  Left := Trunc(Left * cos(0.268) + Top * sin(0.268));
//  Top := (-1) * Trunc(Left * sin(0.268) + Top * cos(0.268));

//  Left := Trunc(Left * cos(0.268) - Top * sin(0.268));
//  Top := Trunc(Left * sin(0.268) + Top * cos(0.268));

  PositionImage.Position.X := Left;
  PositionImage.Position.Y := Top;
  PositionImage.Visible := not Position.Empty;
  PositionImage.BringToFront;
end;

procedure TInteractiveMap.OnMarkerClick(Sender: TObject);
var
  Item: TImage;
  Marker: TMarker;
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self);

  Item := TImage(Sender);
  Marker := TMarker(Item.TagObject);
  if (Marker.Images.Count > 0) and (Trim(Marker.Images[0].Description) <> '') then begin
    FMarkerDescript.Init(Marker, Item.Hint, TTrader(Item.Tag));

    MarkerPanel.Height := FMarkerDescript.MaxHeight;
    MarkerPanel.Width := FMarkerDescript.MaxWidth;
    MarkerPanel.Position.X := (MainContainer.Width - MarkerPanel.Width) / 2;
    MarkerPanel.Position.Y := (MainContainer.Height - MarkerPanel.Height) / 2;
    MarkerPanel.Visible := True;
  end;
end;

procedure TInteractiveMap.OnMarkerDescriptionClose(Sender: TObject);
begin
  MarkerPanel.Visible := False;
end;

procedure TInteractiveMap.SetMouseDown(const Value: Boolean);
begin
  FMousePosition.Down := Value;
  if Value then
    Background.Cursor := crSizeAll
  else
    Background.Cursor := crDefault;
end;

procedure TInteractiveMap.HideMarkerInfo;
begin
  MarkerPanel.Visible := False;
end;

{$IFDEF DEBUG}
procedure TInteractiveMap.TestPosition;
var
  p: TPoint;
begin
  Inc(FTestIndex);
  if FTestIndex >= Length(FTestData) then
    FTestIndex := 0;

  p := FMapWrapper.ExtractPoint(FTestData[FTestIndex]);
  FMapWrapper.DrawPoint(p);
end;
{$ENDIF}

procedure TInteractiveMap.BackgroundDblClick(Sender: TObject);
begin
  SetMouseDown(False);

  if Assigned(FOnDoubleClick) then
    FOnDoubleClick(Self);
end;

procedure TInteractiveMap.BackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  SetMouseDown(True);
  FMousePosition.X := X;
  FMousePosition.Y := Y;
  MarkerPanel.Visible := False;

  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self);
end;

procedure TInteractiveMap.BackgroundMouseLeave(Sender: TObject);
begin
  SetMouseDown(False);
end;

procedure TInteractiveMap.BackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
const
  Offset = 5;
var
  DeltaX, DeltaY: Single;
begin
  if not FMousePosition.Down then
    Exit;

//{$IFNDEF DEBUG}
//  Label1.Caption := Sender.ClassName + '.Position: (' + IntToStr(X) + ', ' + IntToStr(Y) + ')';
//  Label2.Caption := 'Image: (' + IntToStr(imLocalMap.Left) + ', ' + IntToStr(imLocalMap.Top) + ')';
//{$ENDIF}

  DeltaX := X - FMousePosition.X;
  DeltaY := Y - FMousePosition.Y;

  if (Abs(DeltaX) > Offset) or (Abs(DeltaY) > Offset) then begin
    Background.Position.X := Background.Position.X + DeltaX;
    Background.Position.Y := Background.Position.Y + DeltaY;

    FMousePosition.X := X - DeltaX;
    FMousePosition.Y := Y - DeltaY;
  end;
end;

procedure TInteractiveMap.BackgroundMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  SetMouseDown(False);
end;

procedure TInteractiveMap.Center;
begin
  Background.Position.X := (MainContainer.Width - Background.Width) / 2;
  Background.Position.Y := (MainContainer.Height - Background.Height) / 2;
end;

procedure TInteractiveMap.ZoomIn;
begin
  FMapWrapper.ZoomIn;
end;

procedure TInteractiveMap.ZoomOut;
begin
  FMapWrapper.ZoomOut;
end;

end.
