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
    FHideFocus: Boolean;
    FSelected: Boolean;
    FHideSelect: Boolean;
    FFocusedColor: TAlphaColor;
    FSelectedColor: TAlphaColor;
    FStretch: Boolean;
    FStrokeThickness: Integer;

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
    procedure SetHideFocus(const Value: Boolean);
    procedure SetHideSelect(const Value: Boolean);
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
    property HideFocus: Boolean read FHideFocus write SetHideFocus;
    property HideSelect: Boolean read FHideSelect write SetHideSelect;
    property Stretch: Boolean read FStretch write FStretch;
    property StrokeThickness: Integer read FStrokeThickness write FStrokeThickness;
  end;

implementation

{$R *.fmx}

constructor TPictureItemItem.Create(AOwner: TComponent);
begin
  inherited;

  FFocused := False;
  FSelected := False;
  FocusedRectangle.Visible := False;
  FStretch := False;
  StrokeThickness := 2;
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
  FocusedRectangle.Visible := Value and not HideFocus;
  Refresh;
end;

procedure TPictureItemItem.SetHideFocus(const Value: Boolean);
begin
  FHideFocus := Value;
  Refresh;
end;

procedure TPictureItemItem.SetHideSelect(const Value: Boolean);
begin
  FHideSelect := Value;
  Refresh;
end;

procedure TPictureItemItem.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
  Refresh;
end;

procedure TPictureItemItem.Refresh;
begin
  if StrokeThickness > 0 then
    Image.Margins :=  TBounds.Create(TRectF.Create(StrokeThickness, StrokeThickness, StrokeThickness, StrokeThickness))
  else
    Image.Margins := TBounds.Create(TRectF.Create(0, 0, 0, 0));

  if IsSelected and not HideSelect then begin
    Background.Stroke.Color := SelectedColor;
    Background.Stroke.Thickness := StrokeThickness;
  end
  else
  if IsFocused and not HideFocus then begin
    Background.Stroke.Color := FocusedColor;
    Background.Stroke.Thickness := StrokeThickness div 2;
  end
  else
    Background.Stroke.Color := BackgroundColor;
end;

end.
