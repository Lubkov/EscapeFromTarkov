unit ME.GUI.PictureList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Generics.Collections, ME.GUI.PictureItem, FMX.Objects;

type
  TListDirection = (Vertical, Horizontal);
  TChangedItemEvent = procedure (ItemIndex: Integer) of object;

  TPictureList = class(TFrame)
    Background: TRectangle;
    MainContainer: TLayout;
    procedure MainContainerResize(Sender: TObject);
  private
    FItems: TObjectList<TPictureItemItem>;
    FListDirection: TListDirection;
    FItemHeight: Single;
    FItemWidth: Single;
    FSelectedIndex: Integer;
    FItemColor: TAlphaColor;
    FFocusedColor: TAlphaColor;
    FSelectedColor: TAlphaColor;
    FHideFocus: Boolean;
    FHideSelect: Boolean;
    FStretch: Boolean;
    FDelimerWidth: Integer;
    FStrokeThickness: Integer;
    FOnChangeItem: TChangedItemEvent;

    procedure PreviewIconItemClick(Sender: TObject);
    function GetCount: Integer;
    function GetPreviewIconItem(Index: Integer): TPictureItemItem;
    procedure SetSelectedIndex(const Value: Integer);
    function GetIItemWidth: Single;
    function GetItemHeight: Single;
    procedure SetItemHeight(const Value: Single);
    procedure SetItemWidth(const Value: Single);
    function GetBackgroundColor: TAlphaColor;
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetListDirection(const Value: TListDirection);
    procedure SetItemMargins(const Item: TPictureItemItem);
    procedure SetItemSize(const Item: TPictureItemItem);
    function GetStrokeThickness: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(const Title: string; const Bitmap: TBitmap); overload;
    procedure Add(const Bitmap: TBitmap); overload;
    procedure Clear;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPictureItemItem read GetPreviewIconItem;
    property ListDirection: TListDirection read FListDirection write SetListDirection;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property ItemHeight: Single read GetItemHeight write SetItemHeight;
    property ItemWidth: Single read GetIItemWidth write SetItemWidth;
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor;
    property ItemColor: TAlphaColor read FItemColor write FItemColor;
    property FocusedColor: TAlphaColor read FFocusedColor write FFocusedColor;
    property SelectedColor: TAlphaColor read FSelectedColor write FSelectedColor;
    property HideFocus: Boolean read FHideFocus write FHideFocus;
    property HideSelect: Boolean read FHideSelect write FHideSelect;
    property Stretch: Boolean read FStretch write FStretch;
    property DelimerWidth: Integer read FDelimerWidth write FDelimerWidth;
    property StrokeThickness: Integer read GetStrokeThickness write FStrokeThickness;
    property OnChangeItem: TChangedItemEvent read FOnChangeItem write FOnChangeItem;
  end;

implementation

{$R *.fmx}

{ TPreviewIconList }

constructor TPictureList.Create(AOwner: TComponent);
begin
  inherited;

  FItems := TObjectList<TPictureItemItem>.Create;
  FListDirection := TListDirection.Horizontal;
  ItemHeight := 64;
  ItemWidth := 64;
  BackgroundColor := $FF252525;
  ItemColor := $FF252525;
  FocusedColor := $FF514ee6; //$FF383838;
  SelectedColor := $FF0020E0;
  FHideFocus := False;
  FHideSelect := False;
  FStretch := False;
  FStrokeThickness := 2;
  FDelimerWidth := 5;

  FOnChangeItem := nil;
end;

destructor TPictureList.Destroy;
begin
  FOnChangeItem := nil;
  FItems.Free;

  inherited;
end;

function TPictureList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPictureList.GetItemHeight: Single;
begin
  Result := FItemHeight; //MainContainer.ItemHeight;
end;

procedure TPictureList.SetItemHeight(const Value: Single);
begin
  //MainContainer.ItemHeight := Value;
  FItemHeight := Value;

  case ListDirection of
    TListDirection.Vertical: begin
      Self.Width := Value + StrokeThickness;
      MainContainer.Width := Value + StrokeThickness;
    end;
    TListDirection.Horizontal: begin
      Self.Height := Value + StrokeThickness;
      MainContainer.Height := Value + StrokeThickness;
    end;
  end;
end;

function TPictureList.GetIItemWidth: Single;
begin
  Result := FItemWidth; // MainContainer.ItemWidth;
end;

procedure TPictureList.SetItemWidth(const Value: Single);
begin
//  MainContainer.ItemWidth := Value;
  FItemWidth := Value;
end;

procedure TPictureList.SetListDirection(const Value: TListDirection);
begin
  if FListDirection = Value then
    Exit;

  FListDirection := Value;
  case FListDirection of
    TListDirection.Vertical:
      MainContainer.Align := TAlignLayout.Left;
    TListDirection.Horizontal:
      MainContainer.Align := TAlignLayout.Top;
  end;
end;

function TPictureList.GetBackgroundColor: TAlphaColor;
begin
  Result := Background.Fill.Color;
end;

procedure TPictureList.SetBackgroundColor(const Value: TAlphaColor);
begin
  Background.Fill.Color := Value;
end;

procedure TPictureList.SetItemMargins(const Item: TPictureItemItem);
begin
  case FListDirection of
    TListDirection.Vertical: begin
      if Count > 0 then
        Item.Margins.Top := DelimerWidth
      else
        Item.Margins.Top := 0;

      Item.Margins.Left := StrokeThickness;
      Item.Margins.Bottom := 0;
      Item.Margins.Right := StrokeThickness;
    end;
    TListDirection.Horizontal: begin
      if Count > 0 then
        Item.Margins.Left := DelimerWidth
      else
        Item.Margins.Left := 0;

      Item.Margins.Top := StrokeThickness;
      Item.Margins.Bottom := StrokeThickness;
      Item.Margins.Right := 0;
    end;
  end;
end;

procedure TPictureList.SetItemSize(const Item: TPictureItemItem);
begin
  case FListDirection of
    TListDirection.Vertical: begin
      if Stretch then begin
        Item.Width := MainContainer.Width - StrokeThickness * 2;

        Height := Item.Width * (Item.Picture.Height / Item.Picture.Width) + StrokeThickness * 2;
        if Item.Picture.Height < Height then
          Item.Height := Item.Picture.Height + StrokeThickness * 2
        else
          Item.Height := Height;
      end
      else begin
        Item.Width := ItemWidth;
        Item.Height := ItemHeight;
      end;
    end;
    TListDirection.Horizontal: begin
      if Stretch then begin
        Item.Height := MainContainer.Height - StrokeThickness * 2;

        Width := Item.Height * (Item.Picture.Width / Item.Picture.Height) + StrokeThickness * 2;
        if Item.Picture.Width < Width then
          Item.Width := Item.Picture.Width + StrokeThickness * 2
        else
          Item.Width := Width;
      end
      else begin
        Item.Width := ItemWidth;
        Item.Height := ItemHeight;
      end;
    end;
  end;
end;

function TPictureList.GetPreviewIconItem(Index: Integer): TPictureItemItem;
begin
  Result := FItems[Index];
end;

procedure TPictureList.SetSelectedIndex(const Value: Integer);
var
  Item: TPictureItemItem;
begin
  if Count = 0 then begin
    FSelectedIndex := -1;
    Exit;
  end
  else
    FSelectedIndex := Value;

  for Item in FItems do
    Item.IsSelected := (Item.Tag = Value);
end;

function TPictureList.GetStrokeThickness: Integer;
begin
  if HideFocus and HideSelect then
    Result := 0
  else
    Result := FStrokeThickness;
end;

procedure TPictureList.Add(const Title: string; const Bitmap: TBitmap);
var
  Item: TPictureItemItem;
begin
  Item := TPictureItemItem.Create(Self);
  try
    Item.Parent := MainContainer;
    Item.Name := 'PreviewIconItem' + IntToStr(Count + 1);
    Item.Position.X := Item.Width * Count;
    Item.Title := Title;
    Item.Picture := Bitmap;
    Item.HideFocus := HideFocus;
    Item.HideSelect := HideSelect;
    Item.Stretch := Stretch;
    Item.BackgroundColor := ItemColor;
    Item.FocusedColor := FocusedColor;
    Item.SelectedColor := SelectedColor;
    Item.StrokeThickness := StrokeThickness;

    SetItemMargins(Item);
    SetItemSize(Item);
    case FListDirection of
      TListDirection.Vertical:
        Item.Align := TAlignLayout.Top;
      TListDirection.Horizontal:
        Item.Align := TAlignLayout.Left;
    end;

    if HideSelect then
      Item.Cursor := crDefault
    else
      Item.Cursor := crHandPoint;

    Item.OnClick := PreviewIconItemClick;
  finally
    Item.Tag := FItems.Add(Item);
  end;
end;

procedure TPictureList.Add(const Bitmap: TBitmap);
begin
  Add('', Bitmap);
end;

procedure TPictureList.Clear;
begin
  FItems.Clear;
end;

procedure TPictureList.MainContainerResize(Sender: TObject);
begin
  if MainContainer.Height > Height then
    MainContainer.Height := Height;

  if MainContainer.Width > Width then
    MainContainer.Width := Width;
end;

procedure TPictureList.PreviewIconItemClick(Sender: TObject);
begin
  SelectedIndex := TPictureItemItem(Sender).Tag;
  if Assigned(FOnChangeItem) then
    FOnChangeItem(SelectedIndex);
end;

end.
