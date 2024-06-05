unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList,
  ME.DB.Entity, ME.DB.Map, TM.Map.Wrapper, TM.Form.Location;

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
    ToolBarPanel: TPanel;
    buChoiceLocation: TSpeedButton;
    acChoiceLocation: TAction;
    acCentreMap: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure acZoomInExecute(Sender: TObject);
    procedure acZoomOutExecute(Sender: TObject);
    procedure acChoiceLocationExecute(Sender: TObject);
    procedure MapBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure MapBackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure MapBackgroundMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure acCentreMapExecute(Sender: TObject);
  private
    FFormWrapper: TFormWrapper;
    FMapWrapper: TMapWrapper;
    FLocationForm: TLocationForm;
    FMousePosition: TMousePosition;

    procedure SetFullScreenMode(const Value: Boolean);
    procedure OnMapChange(Bitmap: TBitmap);
    procedure OnLocationChanged(const Value: TMap);
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  App.Service, ME.Service.Map;

{$R *.fmx}

// поместить Image с картой в контейнер и двигать контейнер, а не Image с картой
// Изменять размер контейнер, карта всегда под размеры контейнера
// добавлять на в конейнер маркеры, Image с картинкой маркера, что позволить выполнять ключ по маркеру

procedure TMainForm.FormCreate(Sender: TObject);
const
  BackgroundColor = $FF0F0F0F;
begin
  Self.Fill.Color := BackgroundColor;
  Self.Fill.Kind := TBrushKind.Solid;

  FFormWrapper := TFormWrapper.Create(Self);
  FMapWrapper := TMapWrapper.Create('');
  FMapWrapper.TrackLocation := True; // AppParams.TrackLocation;
  FMapWrapper.Images := MapTagImages;
  FMapWrapper.OnMapChange := OnMapChange;

  AppService.Connect;

  FLocationForm := TLocationForm.Create(Self);
  FLocationForm.Init;
  FLocationForm.OnLocationChanged := OnLocationChanged;

  FMousePosition := TMousePosition.Create(0, 0);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFormWrapper.Free;
  FMapWrapper.Free;
  FreeAndNil(FLocationForm);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  case Key of
    vkEscape:
      SetFullScreenMode(False);
    vkF11:
      SetFullScreenMode(True);
  end;
end;

procedure TMainForm.acFullScreenExecute(Sender: TObject);
begin
  SetFullScreenMode(not FFormWrapper.FullScreen);
end;

procedure TMainForm.SetFullScreenMode(const Value: Boolean);
begin
  FFormWrapper.FullScreen := Value;
  ToolBarPanel.Visible := not FFormWrapper.FullScreen;
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

procedure TMainForm.OnLocationChanged(const Value: TMap);
begin
  if FMapWrapper.Map = Value then
    Exit;

  if Value.Layers.Count = 0 then begin
    MapService.LoadLayers(Value, True);
    MapService.LoadMarkers(Value);
    MapService.LoadQuests(Value);
  end;

  FMapWrapper.LoadMap(Value);
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
begin
  FLocationForm.Show;
end;

procedure TMainForm.MapBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
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

{$IFNDEF DEBUG}
  Label1.Caption := Sender.ClassName + '.Position: (' + IntToStr(X) + ', ' + IntToStr(Y) + ')';
  Label2.Caption := 'Image: (' + IntToStr(imLocalMap.Left) + ', ' + IntToStr(imLocalMap.Top) + ')';
{$ENDIF}

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

end.
