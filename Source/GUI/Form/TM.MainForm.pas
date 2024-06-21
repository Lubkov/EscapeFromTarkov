unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList,
  TM.Map.Wrapper, TM.Frame.Location, TM.Frame.MarkerFilter,
  Map.Data.Types, Map.Data.Classes, Map.Frame.InteractiveMap;

type
  TMainForm = class(TForm)
    MainStyleBook: TStyleBook;
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
    procedure acCentreMapExecute(Sender: TObject);
    procedure acMarkerFilterOpenExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure buToolButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  private
    FFormWrapper: TFormWrapper;
    FLocationGrid: TLocationGrid;
    FMarkerFilterList: TMarkerFilterList;
    FInteractiveMap: TInteractiveMap;

    procedure SetFullScreenMode(const Value: Boolean);
    procedure OnLocationChanged(const Value: TMap);
    procedure MarkerFilterListOnClose(Sender: TObject);
    procedure OnInteractiveMapDblClick(Sender: TObject);
    procedure OnInteractiveMouseDown(Sender: TObject);
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

  FInteractiveMap := TInteractiveMap.Create(Self);
  FInteractiveMap.Parent := Self;
  FInteractiveMap.Align := TAlignLayout.Contents;
  FInteractiveMap.SendToBack;
  FInteractiveMap.OnDoubleClick := OnInteractiveMapDblClick;
  FInteractiveMap.OnMouseDown := OnInteractiveMouseDown;

  FMarkerFilterList := TMarkerFilterList.Create(Self);
  FMarkerFilterList.Parent := MarkerFilterPanel;
  FMarkerFilterList.Align := TAlignLayout.Client;
  FMarkerFilterList.Init(FInteractiveMap.MarkerFilter);
  FMarkerFilterList.OnClose := MarkerFilterListOnClose;

  FLocationGrid := TLocationGrid.Create(Self);
  FLocationGrid.Parent := LocationPanel;
  FLocationGrid.Align := TAlignLayout.Client;
  FLocationGrid.Init;
  FLocationGrid.OnLocationChanged := OnLocationChanged;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFormWrapper.Free;
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

procedure TMainForm.buToolButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  FInteractiveMap.SetMouseDown(False);
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

procedure TMainForm.OnLocationChanged(const Value: TMap);
begin
  LocationPanel.Visible := False;
  FInteractiveMap.Map := Value;
end;

procedure TMainForm.MarkerFilterListOnClose(Sender: TObject);
begin
  MarkerFilterPanel.Visible := False;
end;

procedure TMainForm.acZoomInExecute(Sender: TObject);
begin
  FInteractiveMap.ZoomIn;
end;

procedure TMainForm.acZoomOutExecute(Sender: TObject);
begin
  FInteractiveMap.ZoomOut;
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

procedure TMainForm.OnInteractiveMapDblClick(Sender: TObject);
begin
  SetFullScreenMode(not FFormWrapper.FullScreen);
end;

procedure TMainForm.OnInteractiveMouseDown(Sender: TObject);
begin
  LocationPanel.Visible := False;
  MarkerFilterPanel.Visible := False;
end;

procedure TMainForm.acCentreMapExecute(Sender: TObject);
begin
  FInteractiveMap.Center;
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
