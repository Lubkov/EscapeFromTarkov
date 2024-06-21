unit Map.Frame.Marker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.ImageList,
  FMX.ImgList;

type
  TMarkerDescript = class(TFrame)
    TitleLayout: TLayout;
    TraderImage: TImage;
    laQuestName: TLabel;
    laDescription: TLabel;
    Image1: TImage;
    Layout2: TLayout;
    Image2: TImage;
    MainLayout: TLayout;
    buClose: TSpeedButton;
    Layout1: TLayout;
    ImageList24: TImageList;
    procedure buCloseClick(Sender: TObject);
  private
    FOnClose: TNotifyEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

implementation

{$R *.fmx}

{ TMarkerDescript }

constructor TMarkerDescript.Create(AOwner: TComponent);
begin
  inherited;

  FOnClose := nil;
  laQuestName.TextSettings.FontColor := $FFFFFFFF;
  laDescription.TextSettings.FontColor := $FFFFFFFF;
end;

destructor TMarkerDescript.Destroy;
begin
  FOnClose := nil;

  inherited;
end;

procedure TMarkerDescript.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.
