unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList,
  ME.DB.Entity, ME.DB.Map, TM.Map.Wrapper;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure buMapFiltersClick(Sender: TObject);
    procedure acZoomInExecute(Sender: TObject);
    procedure acZoomOutExecute(Sender: TObject);
    procedure buCentreMapClick(Sender: TObject);
  private
    FFormWrapper: TFormWrapper;
    FMapWrapper: TMapWrapper;
    FMap: TMap;  // for debug

    procedure SetFullScreenMode(const Value: Boolean);
    procedure OnMapChange(Bitmap: TBitmap);
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

  FMap := TMap.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFormWrapper.Free;
  FMapWrapper.Free;
  FMap.Free;
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
  MapControlLayout.Visible := not FFormWrapper.FullScreen;
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

procedure TMainForm.buCentreMapClick(Sender: TObject);
begin
  FMap.Free;
  FMap := TMap.Create;
  MapService.GetAt(1, FMap);
  MapService.LoadLayers(FMap, True);
  FMapWrapper.LoadMap(FMap);
end;

procedure TMainForm.buMapFiltersClick(Sender: TObject);
begin
  FMap.Free;
  FMap := TMap.Create;
  MapService.GetAt(2, FMap);
  MapService.LoadLayers(FMap, True);
  FMapWrapper.LoadMap(FMap);
end;

procedure TMainForm.acZoomInExecute(Sender: TObject);
begin
  FMapWrapper.ZoomIn;
end;

procedure TMainForm.acZoomOutExecute(Sender: TObject);
begin
  FMapWrapper.ZoomOut;
end;

end.
