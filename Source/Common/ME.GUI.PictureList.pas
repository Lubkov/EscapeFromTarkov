unit ME.GUI.PictureList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Generics.Collections, ME.GUI.PictureItem, FMX.Objects;

type
  TChangedItemEvent = procedure (ItemIndex: Integer) of object;

  TPictureList = class(TFrame)
    MainContainer: TGridLayout;
    Background: TRectangle;
  private
    FItems: TObjectList<TPictureItemItem>;
    FSelectedIndex: Integer;
    FItemColor: TAlphaColor;
    FFocusedColor: TAlphaColor;
    FSelectedColor: TAlphaColor;
    FHideFocus: Boolean;
    FHideSelect: Boolean;
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(const Title: string; const Bitmap: TBitmap); overload;
    procedure Add(const Bitmap: TBitmap); overload;
    procedure Clear;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPictureItemItem read GetPreviewIconItem;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property ItemHeight: Single read GetItemHeight write SetItemHeight;
    property ItemWidth: Single read GetIItemWidth write SetItemWidth;
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor;
    property ItemColor: TAlphaColor read FItemColor write FItemColor;
    property FocusedColor: TAlphaColor read FFocusedColor write FFocusedColor;
    property SelectedColor: TAlphaColor read FSelectedColor write FSelectedColor;
    property HideFocus: Boolean read FHideFocus write FHideFocus;
    property HideSelect: Boolean read FHideSelect write FHideSelect;
    property OnChangeItem: TChangedItemEvent read FOnChangeItem write FOnChangeItem;
  end;

implementation

{$R *.fmx}

{ TPreviewIconList }

constructor TPictureList.Create(AOwner: TComponent);
begin
  inherited;

  FItems := TObjectList<TPictureItemItem>.Create;
  ItemHeight := 64;
  ItemWidth := 64;
  BackgroundColor := $FF252525;
  ItemColor := $FF252525;
  FocusedColor := $FF514ee6; //$FF383838;
  SelectedColor := $FF0020E0;
  FHideFocus := False;
  FHideSelect := False;

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
  Result := MainContainer.ItemHeight;
end;

procedure TPictureList.SetItemHeight(const Value: Single);
begin
  MainContainer.ItemHeight := Value;
  Self.Height := Value + 2;
  MainContainer.Height := Value + 2;
end;

function TPictureList.GetIItemWidth: Single;
begin
  Result := MainContainer.ItemWidth;
end;

procedure TPictureList.SetItemWidth(const Value: Single);
begin
  MainContainer.ItemWidth := Value;
end;

function TPictureList.GetBackgroundColor: TAlphaColor;
begin
  Result := Background.Fill.Color;
end;

procedure TPictureList.SetBackgroundColor(const Value: TAlphaColor);
begin
  Background.Fill.Color := Value;
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
    Item.IsSelected := (Item.Tag = Value) and not FHideSelect;
end;

procedure TPictureList.Add(const Title: string; const Bitmap: TBitmap);
var
  Item: TPictureItemItem;
begin
  Item := TPictureItemItem.Create(Self);
  try
    Item.Parent := MainContainer;
    Item.Position.X := Item.Width * Count;
    Item.Align := TAlignLayout.Left;
    Item.Margins.Top := 1;
    Item.Margins.Left := 5;
    Item.Margins.Bottom := 1;
    Item.Name := 'PreviewIconItem' + IntToStr(Count + 1);
    Item.Cursor := crHandPoint;
    Item.Title := Title;
    Item.Picture := Bitmap;
    Item.BackgroundColor := ItemColor;
    Item.FocusedColor := FocusedColor;
    Item.SelectedColor := SelectedColor;
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

procedure TPictureList.PreviewIconItemClick(Sender: TObject);
begin
  SelectedIndex := TPictureItemItem(Sender).Tag;
  if Assigned(FOnChangeItem) then
    FOnChangeItem(SelectedIndex);
end;

end.
