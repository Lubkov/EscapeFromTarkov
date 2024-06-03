unit TM.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  TM.Form.Wrapper, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  System.ImageList, FMX.ImgList, FMX.Objects, System.Actions, FMX.ActnList;

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
    ActionList1: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FFormWrapper: TFormWrapper;
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

end.
