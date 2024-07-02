unit ME.GUI.PictureItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TPictureItemItem = class(TFrame)
    Image: TImage;
    Background: TRectangle;
    laTitle: TLabel;
    FocusedRectangle: TRectangle;
    procedure FrameMouseEnter(Sender: TObject);
    procedure FrameMouseLeave(Sender: TObject);
  private
    FFocused: Boolean;
    FSelected: Boolean;
    FFocusedColor: TAlphaColor;
    FSelectedColor: TAlphaColor;

    procedure SetSelected(const Value: Boolean);
    procedure SetFocused(const Value: Boolean);
    function GetPicture: TBitmap;
    procedure SetPicture(const Value: TBitmap);
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetTextSettings: TTextSettings;
    procedure SetTextSettings(const Value: TTextSettings);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    function GetBackgroundColor: TAlphaColor;
  public
    constructor Create(AOwner: TComponent); override;

    property IsFocused: Boolean read FFocused write SetFocused;
    property IsSelected: Boolean read FSelected write SetSelected;

    procedure Refresh;

    property Picture: TBitmap read GetPicture write SetPicture;
    property Title: string read GetTitle write SetTitle;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor;
    property FocusedColor: TAlphaColor read FFocusedColor write FFocusedColor;
    property SelectedColor: TAlphaColor read FSelectedColor write FSelectedColor;
  end;

implementation

{$R *.fmx}

constructor TPictureItemItem.Create(AOwner: TComponent);
begin
  inherited;

  FFocused := False;
  FSelected := False;
  FocusedRectangle.Visible := False;
end;

function TPictureItemItem.GetPicture: TBitmap;
begin
  Result := Image.Bitmap;
end;

procedure TPictureItemItem.SetPicture(const Value: TBitmap);
begin
  Image.Bitmap.Assign(Value);
end;

function TPictureItemItem.GetTitle: string;
begin
  Result := laTitle.Text;
end;

procedure TPictureItemItem.SetTitle(const Value: string);
begin
  laTitle.Text := Value;
  laTitle.Visible := Value <> '';
end;

function TPictureItemItem.GetTextSettings: TTextSettings;
begin
  Result := laTitle.TextSettings;
end;

procedure TPictureItemItem.SetTextSettings(const Value: TTextSettings);
begin
  laTitle.TextSettings.Assign(Value);
end;

function TPictureItemItem.GetBackgroundColor: TAlphaColor;
begin
  Result := Background.Fill.Color;
end;

procedure TPictureItemItem.SetBackgroundColor(const Value: TAlphaColor);
begin
  Background.Fill.Color := Value;
end;

procedure TPictureItemItem.FrameMouseEnter(Sender: TObject);
begin
  IsFocused := True;
end;

procedure TPictureItemItem.FrameMouseLeave(Sender: TObject);
begin
  IsFocused := False;
end;

procedure TPictureItemItem.SetFocused(const Value: Boolean);
begin
  FFocused := Value;
  FocusedRectangle.Visible := Value;
  Refresh;
end;

procedure TPictureItemItem.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
  Refresh;
end;

procedure TPictureItemItem.Refresh;
begin
  if IsSelected then begin
    Background.Stroke.Color := SelectedColor;
    Background.Stroke.Thickness := 2;
  end
  else
  if IsFocused then begin
    Background.Stroke.Color := FocusedColor;
    Background.Stroke.Thickness := 1;
  end
  else
    Background.Stroke.Color := BackgroundColor;
end;

end.
