unit Map.Frame.Marker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.ImageList,
  FMX.ImgList, Map.Data.Types;

type
  TMarkerDescript = class(TFrame)
    TitleLayout: TLayout;
    TraderImage: TImage;
    laQuestName: TLabel;
    laDescription: TLabel;
    MarkerImage: TImage;
    ItemsLayout: TLayout;
    Item1Image: TImage;
    MainLayout: TLayout;
    buClose: TSpeedButton;
    ButtonCloseLayout: TLayout;
    ImageList24: TImageList;
    TraderImageList: TImageList;
    procedure buCloseClick(Sender: TObject);
  private
    [Weak] FMarker: TMarker;
    FMaxHeight: Single;
    FMaxWidth: Single;
    FOnClose: TNotifyEvent;
    FItems: TList<TImage>;

    procedure AddItem(const Index: Integer; const Name: string);
    procedure ArrangeItems;
    procedure ArrangeItemsVertically(ItemHeight, ItemWidth: Integer);
    procedure ArrangeItemsHorizontally(ItemHeight, ItemWidth: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Marker: TMarker; const QuestName: string; Trader: TTrader);

    property MaxHeight: Single read FMaxHeight;
    property MaxWidth: Single read FMaxWidth;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

implementation

uses
  Map.Data.Service;

{$R *.fmx}

{ TMarkerDescript }

constructor TMarkerDescript.Create(AOwner: TComponent);
begin
  inherited;

  FMarker := nil;
  FOnClose := nil;
  laQuestName.TextSettings.FontColor := $FFFFFFFF;
  laDescription.TextSettings.FontColor := $FFFFFFFF;
  FItems := TList<TImage>.Create;
  FItems.Add(Item1Image);
end;

destructor TMarkerDescript.Destroy;
begin
  FOnClose := nil;
  FMarker := nil;
  FItems.Free;

  inherited;
end;

procedure TMarkerDescript.AddItem(const Index: Integer; const Name: string);
var
  Item: TImage;
begin
  if Index < FItems.Count then
    Item := FItems[Index]
  else begin
    Item := TImage.Create(Self);
    try
      Item.Parent := ItemsLayout;
    finally
      FItems.Add(Item);
    end;
  end;

  DataSertvice.LoadItemImage(Name, Item.Bitmap);
  Item.Visible := True;
end;

procedure TMarkerDescript.ArrangeItems;
var
  i: Integer;
  ItemHeight: Integer;
  ItemWidth: Integer;
begin
  ItemHeight := 0;
  ItemWidth := 0;
  for i := 0 to FItems.Count - 1 do
    if FItems[i].Visible then begin
      if FItems[i].Bitmap.Height > ItemHeight then
        ItemHeight := FItems[i].Bitmap.Height;

      if FItems[i].Bitmap.Width > ItemWidth then
        ItemWidth := FItems[i].Bitmap.Width;
    end;

  if ItemWidth > ItemHeight then
    ArrangeItemsHorizontally(ItemHeight, ItemWidth)
  else
    ArrangeItemsVertically(ItemHeight, ItemWidth);
end;

procedure TMarkerDescript.ArrangeItemsVertically(ItemHeight, ItemWidth: Integer);
var
  i: Integer;
  Item: TImage;
begin
  ItemsLayout.Align := TAlignLayout.Right;
  ItemsLayout.Width := ItemWidth;
  ItemsLayout.Margins.Top := 0;
  ItemsLayout.Margins.Left := 5;
  FMaxWidth := FMaxWidth + ItemsLayout.Width + ItemsLayout.Margins.Left;

  for i := 0 to FItems.Count - 1 do begin    
    Item := FItems[i];
    if not Item.Visible then
      Continue;
      
    Item.Height := Item.Bitmap.Height;
    Item.Width := Item.Bitmap.Width;

    Item.Position.X := 0;
    if i > 0 then
      Item.Position.Y := FItems[i - 1].Position.Y + FItems[i - 1].Height + 5
    else
      Item.Position.Y := 0;
  end;
end;

procedure TMarkerDescript.ArrangeItemsHorizontally(ItemHeight, ItemWidth: Integer);
var
  i: Integer;
  Item: TImage;
begin
  ItemsLayout.Align := TAlignLayout.Bottom;
  ItemsLayout.Height := ItemHeight;
  ItemsLayout.Margins.Top := 5;
  ItemsLayout.Margins.Left := 0;
  FMaxHeight := FMaxHeight + ItemsLayout.Height + ItemsLayout.Margins.Top;

  for i := 0 to FItems.Count - 1 do begin
    Item := FItems[i];
    if not Item.Visible then
      Continue;
      
    Item.Height := Item.Bitmap.Height;
    Item.Width := Item.Bitmap.Width;

    Item.Position.Y := 0;
    if i > 0 then
      Item.Position.X := FItems[i - 1].Position.X + FItems[i - 1].Width + 5
    else
      Item.Position.X := 0;
  end;
end;

procedure TMarkerDescript.Init(const Marker: TMarker; const QuestName: string; Trader: TTrader);
const
  ImageHeight = 360;
  ImageWidth = 640;
var
  Bitmap: TBitmap;
  i: Integer;
  Image: TLocationImage;
begin
  laQuestName.Text := QuestName;
//  laDescription.Text := Marker.Name;
  Bitmap := TraderImageList.Bitmap(TSizeF.Create(64, 64), Ord(Trader));
  TraderImage.Bitmap.Assign(Bitmap);

  if Marker.Images.Count > 0 then begin
    Image := Marker.Images[0];

    DataSertvice.LoadMarkerImage(Image.Name, MarkerImage.Bitmap);
    laDescription.Text := Image.Caption;
  end;

  FMaxHeight := TitleLayout.Height + TitleLayout.Margins.Top;
  FMaxHeight := FMaxHeight + ImageHeight + MainLayout.Margins.Top + MainLayout.Margins.Bottom;
  FMaxHeight := FMaxHeight + laDescription.Height + laDescription.Margins.Top;
  FMaxWidth := ImageWidth + MainLayout.Margins.Left + MainLayout.Margins.Right;

  for i := 0 to FItems.Count - 1 do
    FItems[i].Visible := False;

  for i := 0 to Marker.Items.Count - 1 do
    AddItem(i, Marker.Items[i]);

  ArrangeItems;
end;

procedure TMarkerDescript.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.
