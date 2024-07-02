unit Map.Frame.Marker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.ImageList,
  FMX.ImgList, Map.Data.Types, FMX.ListBox, System.Rtti, ME.GUI.PictureList;

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
    MarkerStyleBook: TStyleBook;
    PreviewLayout: TLayout;

    procedure buCloseClick(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ListBoxItem2Click(Sender: TObject);
  private
    [Weak] FMarker: TMarker;
    FMaxHeight: Single;
    FMaxWidth: Single;
    FOnClose: TNotifyEvent;
    FItems: TList<TImage>;
    FCurrentImageIndex: Integer;
    FPictureList: TPictureList;

    procedure AddItem(const Index: Integer; const QuestItem: TQuestItem);
    procedure ShowResource(const Index: Integer);
    procedure ChangedPreviewIcon(ItemIndex: Integer);

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
// #70A700 - focused color
// ##4E7500 - selected color
begin
  inherited;

  FMarker := nil;
  FOnClose := nil;
  laQuestName.TextSettings.FontColor := $FFFFFFFF;
  laDescription.TextSettings.FontColor := $FFFFFFFF;
  FItems := TList<TImage>.Create;
  FItems.Add(Item1Image);

  FPictureList := TPictureList.Create(Self);
  FPictureList.Parent := PreviewLayout;
  FPictureList.Align := TAlignLayout.Client;
  FPictureList.ItemHeight := 52;
  FPictureList.ItemWidth := 85;
  FPictureList.OnChangeItem := ChangedPreviewIcon;
end;

destructor TMarkerDescript.Destroy;
begin
  FOnClose := nil;
  FMarker := nil;
  FItems.Free;

  inherited;
end;

procedure TMarkerDescript.AddItem(const Index: Integer; const QuestItem: TQuestItem);
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

  DataSertvice.LoadImage(QuestItem, Item.Bitmap);
  Item.Visible := True;
end;

procedure TMarkerDescript.ShowResource(const Index: Integer);
var
  Image: TResource;
begin
  if FCurrentImageIndex = Index then
    Exit;

  FCurrentImageIndex := Index;

  if FMarker.Images.Count > Index then begin
    Image := FMarker.Images[Index];

    DataSertvice.LoadImage(Image, MarkerImage.Bitmap);
    laDescription.Text := Image.Description;
  end
  else begin
    MarkerImage.Bitmap.Assign(nil);
    laDescription.Text := '';
  end;
end;

procedure TMarkerDescript.ChangedPreviewIcon(ItemIndex: Integer);
begin
  ShowResource(ItemIndex);
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
  Resource: TResource;
begin
  FMarker := Marker;
  FCurrentImageIndex := -1;
  laQuestName.Text := ' вест: "' + QuestName + '"';
  Bitmap := TraderImageList.Bitmap(TSizeF.Create(64, 64), Ord(Trader));
  TraderImage.Bitmap.Assign(Bitmap);
  ShowResource(0);

  FPictureList.Clear;
  if Marker.Images.Count > 1 then
    for Resource in Marker.Images do
    begin
      if Resource.Picture.IsEmpty then
        DataSertvice.LoadImage(Resource, Resource.Picture);

      FPictureList.Add(Resource.Picture);
    end;

  if Marker.Images.Count > 1 then
    FPictureList.SelectedIndex := 0;

  PreviewLayout.Visible := Marker.Images.Count > 1;

  FMaxHeight := TitleLayout.Height + TitleLayout.Margins.Top;
  FMaxHeight := FMaxHeight + ImageHeight + MainLayout.Margins.Top + MainLayout.Margins.Bottom;
  FMaxHeight := FMaxHeight + laDescription.Height + laDescription.Margins.Top;
  FMaxWidth := ImageWidth + MainLayout.Margins.Left + MainLayout.Margins.Right;

  if PreviewLayout.Visible then
    FMaxHeight := FMaxHeight + PreviewLayout.Height + PreviewLayout.Margins.Top + PreviewLayout.Margins.Bottom;

  for i := 0 to FItems.Count - 1 do
    FItems[i].Visible := False;

  for i := 0 to Marker.Items.Count - 1 do
    AddItem(i, Marker.Items[i]);

  ArrangeItems;
end;

procedure TMarkerDescript.ListBox1ItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  ShowMessage('ListBox1ItemClick');
end;

procedure TMarkerDescript.ListBoxItem2Click(Sender: TObject);
begin
  ShowMessage('ListBoxItem2Click');
end;

procedure TMarkerDescript.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.
