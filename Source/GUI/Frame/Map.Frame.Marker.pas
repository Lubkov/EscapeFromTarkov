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
  private
    [Weak] FMarker: TMarker;
    FMaxHeight: Single;
    FMaxWidth: Single;
    FOnClose: TNotifyEvent;
    FCurrentImageIndex: Integer;
    FItemIconList: TPictureList;
    FPictureIconList: TPictureList;

    procedure ShowResource(const Index: Integer);
    procedure ChangedPreviewIcon(ItemIndex: Integer);
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

  FPictureIconList := TPictureList.Create(Self);
  FPictureIconList.Name := 'PictureIconList';
  FPictureIconList.Parent := PreviewLayout;
  FPictureIconList.Align := TAlignLayout.Client;
  FPictureIconList.ListDirection := TListDirection.Horizontal;
  FPictureIconList.ItemHeight := 52;
  FPictureIconList.ItemWidth := 85;
  FPictureIconList.OnChangeItem := ChangedPreviewIcon;

  FItemIconList := TPictureList.Create(Self);
  FItemIconList.Name := 'PictureList';
  FItemIconList.Parent := ItemsLayout;
  FItemIconList.Align := TAlignLayout.Client;
  FItemIconList.ListDirection := TListDirection.Vertical;
  FItemIconList.Stretch := True;
  FItemIconList.HideFocus := True;
  FItemIconList.HideSelect := True;
end;

destructor TMarkerDescript.Destroy;
begin
  FOnClose := nil;
  FMarker := nil;

  inherited;
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

procedure TMarkerDescript.Init(const Marker: TMarker; const QuestName: string; Trader: TTrader);
const
  ImageHeight = 360;
  ImageWidth = 640;
var
  Bitmap: TBitmap;
  Resource: TResource;
  QuestItem: TQuestItem;
begin
  FMarker := Marker;
  FCurrentImageIndex := -1;
  laQuestName.Text := ' вест: "' + QuestName + '"';
  Bitmap := TraderImageList.Bitmap(TSizeF.Create(64, 64), Ord(Trader));
  TraderImage.Bitmap.Assign(Bitmap);
  ShowResource(0);

  FPictureIconList.Clear;
  if Marker.Images.Count > 1 then
    for Resource in Marker.Images do begin
      if Resource.Picture.IsEmpty then
        DataSertvice.LoadImage(Resource, Resource.Picture);

      FPictureIconList.Add(Resource.Picture);
    end;

  if Marker.Images.Count > 1 then
    FPictureIconList.SelectedIndex := 0;

  PreviewLayout.Visible := Marker.Images.Count > 1;

  FMaxHeight := TitleLayout.Height + TitleLayout.Margins.Top;
  FMaxHeight := FMaxHeight + ImageHeight + MainLayout.Margins.Top + MainLayout.Margins.Bottom;
  FMaxHeight := FMaxHeight + laDescription.Height + laDescription.Margins.Top;
  FMaxWidth := ImageWidth + MainLayout.Margins.Left + MainLayout.Margins.Right;

  if PreviewLayout.Visible then
    FMaxHeight := FMaxHeight + PreviewLayout.Height + PreviewLayout.Margins.Top + PreviewLayout.Margins.Bottom;

  FItemIconList.Clear;
  for QuestItem in Marker.Items do begin
    if QuestItem.Picture.IsEmpty then
      DataSertvice.LoadImage(QuestItem, QuestItem.Picture);

    FItemIconList.Add(QuestItem.Picture);
  end;

//  for i := 0 to FItems.Count - 1 do
//    FItems[i].Visible := False;
//
//  for i := 0 to Marker.Items.Count - 1 do
//    AddItem(i, Marker.Items[i]);
//
//  ArrangeItems;
end;

procedure TMarkerDescript.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.
