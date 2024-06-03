unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList,
  TM.Map.Wrapper;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acFullScreenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    FFormWrapper: TFormWrapper;

    procedure SetFullScreenMode(const Value: Boolean);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
const
  BackgroundColor = $FF0F0F0F;
begin
  Self.Fill.Color := BackgroundColor;
  Self.Fill.Kind := TBrushKind.Solid;

  FFormWrapper := TFormWrapper.Create(Self);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FFormWrapper.Free;
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

end.
