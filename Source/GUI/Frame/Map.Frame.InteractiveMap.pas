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

    function GetBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
    procedure OnMapChange(Bitmap: TBitmap);
    function GetMarkerFilter: TMarkerFilter;
    function GetMap: TMap;
    procedure SetMap(const Value: TMap);

    procedure Clear;
    procedure AddMarker(const Marker: TMarker; const Title: string);
    procedure AddPosition(const Position: TPoint);
    procedure OnMarkerClick(Sender: TObject);
    procedure OnMarkerDescriptionClose(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Center;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure SetMouseDown(const Value: Boolean);

    property Map: TMap read GetMap write SetMap;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property MarkerFilter: TMarkerFilter read GetMarkerFilter;
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
      AddMarker(Marker, Marker.Name);

  for i := 0 to Map.Quests.Count - 1 do begin
    Quest := Map.Quests[i];

    if MarkerFilter.IsQuestEnable(i) then
      for Marker in Quest.Markers do
        AddMarker(Marker, Quest.Name);
  end;

  AddPosition(FMapWrapper.Position);
end;

function TInteractiveMap.GetMarkerFilter: TMarkerFilter;
begin
  Result := FMapWrapper.MarkerFilter;
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

procedure TInteractiveMap.AddMarker(const Marker: TMarker; const Title: string);
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
    Item.Cursor := crHandPoint;
    Item.Bitmap.Assign(MapTagImages.Bitmap(TSizeF.Create(32, 32), Ord(Marker.Kind)));
    Item.Hint := Title;
    Item.ShowHint := Trim(Title) <> '';
    Item.OnClick := OnMarkerClick;
  finally
    FItems.Add(Item);
  end;
end;

procedure TInteractiveMap.AddPosition(const Position: TPoint);
const
  MarkerHeight = 16;
  MarkerWidth = 16;
var
  Offset: Double;
begin
  Offset := Abs((Map.Top - Position.Top) / (Map.Bottom - Map.Top));
  Top := Trunc(Bitmap.Height * Offset) - MarkerHeight div 2;
  Offset := Abs((Map.Left - Position.Left) / (Map.Right - Map.Left));
  Left := Trunc(Bitmap.Width * Offset) - MarkerWidth div 2;

  PositionImage.Position.X := Left;
  PositionImage.Position.Y := Top;
  PositionImage.Visible := not Position.Empty;
  PositionImage.BringToFront;
end;

procedure TInteractiveMap.OnMarkerClick(Sender: TObject);
begin
  MarkerPanel.Visible := True;
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
