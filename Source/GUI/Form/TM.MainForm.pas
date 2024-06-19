unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList,
  TM.Map.Wrapper, TM.Frame.Location, TM.Frame.MarkerFilter,
  Map.Data.Types, Map.Data.Classes;

type
  TMainForm = class(TForm)
    MainStyleBook: TStyleBook;
    MapBackground: TImage;
    ImageList32: TImageList;
    MapControlLayout: TLayout;
    buFullScreen: TSpeedButton;
    buZoomIn: TSpeedButton;
    buZoomOut: TSpeedButton;
    buCentreMap: TSpeedButton;
    buMapFilters: TSpeedButton;
    MainActionList: TActionList;
    acFullScreen: TAction;
    MapTagImages: TImageList;
    acZoomIn: TAction;
    acZoomOut: TAction;
    MainContainer: TScrollBox;
    acChoiceLocation: TAction;
    acCentreMap: TAction;
    acMarkerFilterOpen: TAction;
    buChoiceLocation: TSpeedButton;
    LocationPanel: TPanel;
    MarkerFilterPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure acZoomInExecute(Sender: TObject);
    procedure acZoomOutExecute(Sender: TObject);
    procedure acChoiceLocationExecute(Sender: TObject);
    procedure MapBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure MapBackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure MapBackgroundMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure acCentreMapExecute(Sender: TObject);
    procedure acMarkerFilterOpenExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MapBackgroundDblClick(Sender: TObject);
  private
    FFormWrapper: TFormWrapper;
    FMapWrapper: TMapWrapper;
    FLocationGrid: TLocationGrid;
    FMousePosition: TMousePosition;
    FMarkerFilterList: TMarkerFilterList;

    procedure SetFullScreenMode(const Value: Boolean);
    procedure OnMapChange(Bitmap: TBitmap);
    procedure OnLocationChanged(const Value: PMap);
    procedure MarkerFilterListOnClose(Sender: TObject);
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  App.Constants, App.Service, Map.Data.Service;

{$R *.fmx}

// поместить Image с картой в контейнер и двигать контейнер, а не Image с картой
// Изменять размер контейнер, карта всегда под размеры контейнера
// добавлять в конейнер маркеры, Image с картинкой маркера, что позволить выполнять клик по маркеру

procedure TMainForm.FormCreate(Sender: TObject);
const
  BackgroundColor = $FF0F0F0F;
begin
  AppService.LoadParams;
  AppService.LoadDataFromJSON;

  Self.Caption := '["Escape of Tarkov" position tracking]';
  Self.Fill.Color := BackgroundColor;
  Self.Fill.Kind := TBrushKind.Solid;

  LocationPanel.Visible := False;
  MarkerFilterPanel.Visible := False;

  FFormWrapper := TFormWrapper.Create(Self);
  FMapWrapper := TMapWrapper.Create(AppParams.SreenshotPath);
  FMapWrapper.TrackLocation := AppParams.TrackLocation;
  FMapWrapper.Images := MapTagImages;
  FMapWrapper.OnMapChange := OnMapChange;

  FMarkerFilterList := TMarkerFilterList.Create(Self);
  FMarkerFilterList.Parent := MarkerFilterPanel;
  FMarkerFilterList.Align := TAlignLayout.Client;
  FMarkerFilterList.Init(FMapWrapper.MarkerFilter);
  FMarkerFilterList.OnClose := MarkerFilterListOnClose;

  FLocationGrid := TLocationGrid.Create(Self);
  FLocationGrid.Parent := LocationPanel;
  FLocationGrid.Align := TAlignLayout.Client;
  FLocationGrid.Init;
  FLocationGrid.OnLocationChanged := OnLocationChanged;

//
//  FMousePosition := TMousePosition.Create(0, 0);

//------------------------------------------------------------------------------
//  AppService.LoadParams;
//  AppService.Connect;
//
//  LocationPanel.Visible := False;
//  MarkerFilterPanel.Visible := False;
//
//  FFormWrapper := TFormWrapper.Create(Self);
//  FMapWrapper := TMapWrapper.Create(AppParams.SreenshotPath);
//  FMapWrapper.TrackLocation := AppParams.TrackLocation;
//  FMapWrapper.Images := MapTagImages;
//  FMapWrapper.OnMapChange := OnMapChange;
//
//  FMarkerFilterList := TMarkerFilterList.Create(Self);
//  FMarkerFilterList.Parent := MarkerFilterPanel;
//  FMarkerFilterList.Align := TAlignLayout.Client;
//  FMarkerFilterList.Init(FMapWrapper.MarkerFilter);
//  FMarkerFilterList.OnClose := MarkerFilterListOnClose;
//
//  FLocationGrid := TLocationGrid.Create(Self);
//  FLocationGrid.Parent := LocationPanel;
//  FLocationGrid.Align := TAlignLayout.Client;
//  FLocationGrid.Init;
//  FLocationGrid.OnLocationChanged := OnLocationChanged;
//
//  FMousePosition := TMousePosition.Create(0, 0);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFormWrapper.Free;
  FMapWrapper.Free;
  FreeAndNil(FLocationGrid);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  case Key of
    vkEscape:
      if LocationPanel.Visible then
        LocationPanel.Visible := False
      else
      if MarkerFilterPanel.Visible then
        MarkerFilterPanel.Visible := False
      else
        SetFullScreenMode(False);
    vkF11:
      SetFullScreenMode(True);
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  LocationPanel.Visible := False;
  MarkerFilterPanel.Visible := False;
end;

procedure TMainForm.acFullScreenExecute(Sender: TObject);
begin
  SetFullScreenMode(not FFormWrapper.FullScreen);
end;

procedure TMainForm.SetFullScreenMode(const Value: Boolean);
begin
  FFormWrapper.FullScreen := Value;
//  MapControlLayout.Visible := not FFormWrapper.FullScreen;
//  FormResize(Self);
end;

procedure TMainForm.OnMapChange(Bitmap: TBitmap);
begin
//{$IFNDEF DEBUG}
//  Logger.Lines.Add('OnMapChange');
//{$ENDIF}
  MapBackground.Width := Bitmap.Width;
  MapBackground.Height := Bitmap.Height;
  MapBackground.Bitmap.Assign(nil);
  MapBackground.Bitmap.Assign(Bitmap);
end;

procedure TMainForm.OnLocationChanged(const Value: PMap);
begin
  LocationPanel.Visible := False;

  if (Value = nil) or (FMapWrapper.Map = Value) then
    Exit;

//  if Value.Layers.Count = 0 then begin
//    MapService.LoadLayers(Value, True);
//    MapService.LoadMarkers(Value);
//    MapService.LoadQuests(Value);
//  end;

  FMapWrapper.LoadMap(Value);
  FMapWrapper.Start;
end;

procedure TMainForm.MarkerFilterListOnClose(Sender: TObject);
begin
  MarkerFilterPanel.Visible := False;
end;

procedure TMainForm.acZoomInExecute(Sender: TObject);
begin
  FMapWrapper.ZoomIn;
end;

procedure TMainForm.acZoomOutExecute(Sender: TObject);
begin
  FMapWrapper.ZoomOut;
end;

procedure TMainForm.acChoiceLocationExecute(Sender: TObject);
var
  Height: Single;
  Width: Single;
  OffsetX: Single;
begin
  MarkerFilterPanel.Visible := False;

  OffsetX := MapControlLayout.Position.X + MapControlLayout.Width;
  Height := Self.ClientHeight;
  Width := Self.ClientWidth - OffsetX - 40;

  if Width < FLocationGrid.MaxWidth then
    LocationPanel.Width := Width
  else
    LocationPanel.Width := FLocationGrid.MaxWidth;

  if Height < FLocationGrid.MaxHeight then
    LocationPanel.Height := Height
  else
    LocationPanel.Height := FLocationGrid.MaxHeight;

  LocationPanel.Position.X := (Width / 2) - (LocationPanel.Width / 2) + OffsetX + 20;
  LocationPanel.Position.Y := (Height / 2) - (LocationPanel.Height / 2);
  LocationPanel.Visible := not LocationPanel.Visible;
end;

procedure TMainForm.MapBackgroundDblClick(Sender: TObject);
begin
  SetFullScreenMode(not FFormWrapper.FullScreen);
end;

procedure TMainForm.MapBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  LocationPanel.Visible := False;
  MarkerFilterPanel.Visible := False;

  FMousePosition.Down := True;
  FMousePosition.X := X;
  FMousePosition.Y := Y;
end;

procedure TMainForm.MapBackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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
    MapBackground.Position.X := MapBackground.Position.X + DeltaX;
    MapBackground.Position.Y := MapBackground.Position.Y + DeltaY;

    FMousePosition.X := X - DeltaX;
    FMousePosition.Y := Y - DeltaY;
  end;
end;

procedure TMainForm.MapBackgroundMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMousePosition.Down := False;
end;

procedure TMainForm.acCentreMapExecute(Sender: TObject);
begin
//  MainContainer.Scene.DisableUpdating;
//  try
    MapBackground.Position.X := (MainContainer.Width - MapBackground.Width) / 2;
    MapBackground.Position.Y := (MainContainer.Height - MapBackground.Height) / 2;
//  finally
//    MainContainer.Scene.EnableUpdating;
//  end;
end;

procedure TMainForm.acMarkerFilterOpenExecute(Sender: TObject);
var
  Height: Single;
begin
  LocationPanel.Visible := False;

  MarkerFilterPanel.Position.X := MapControlLayout.Position.X + MapControlLayout.Width + 10;
  MarkerFilterPanel.Position.Y := MapControlLayout.Position.Y;
  MarkerFilterPanel.Height := 550;
  MarkerFilterPanel.Width := 340;

  Height :=  Self.ClientHeight - MarkerFilterPanel.Position.Y - 20;
  if Height < FMarkerFilterList.MaxHeight then
    MarkerFilterPanel.Height := Height
  else
    MarkerFilterPanel.Height := FMarkerFilterList.MaxHeight;

  MarkerFilterPanel.Visible := not MarkerFilterPanel.Visible;
end;

end.
