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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure acZoomInExecute(Sender: TObject);
    procedure acZoomOutExecute(Sender: TObject);
    procedure acChoiceLocationExecute(Sender: TObject);
  private
    FFormWrapper: TFormWrapper;
    FMapWrapper: TMapWrapper;
    FLocationForm: TLocationForm;

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

end.
