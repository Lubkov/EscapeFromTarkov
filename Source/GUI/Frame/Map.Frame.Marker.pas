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
    FOnClose: TNotifyEvent;
    FItems: TList<TImage>;

    procedure AddItem(const Index: Integer; const Name: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Marker: TMarker; const QuestName: string; Trader: TTrader);

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
      Item.Width := 64;
      Item.Height := 64;
      Item.Position.Y := Item.Height * Index;
      item.Align := TAlignLayout.Top;
      Item.Margins.Bottom := 5;
    finally
      FItems.Add(Item);
    end;
  end;

  DataSertvice.LoadItemImage(Name, Item.Bitmap);
  Item.Visible := True;
end;

procedure TMarkerDescript.Init(const Marker: TMarker; const QuestName: string; Trader: TTrader);
var
  Bitmap: TBitmap;
  i: Integer;
  ItemName: string;
begin
  laQuestName.Text := QuestName;
  laDescription.Text := Marker.Name;
  Bitmap := TraderImageList.Bitmap(TSizeF.Create(64, 64), Ord(Trader));
  TraderImage.Bitmap.Assign(Bitmap);
  DataSertvice.LoadMarkerImage(Marker.Image, MarkerImage.Bitmap);

  for i := 0 to FItems.Count - 1 do
    FItems[i].Visible := False;

  for i := 0 to Marker.Items.Count - 1 do
    AddItem(i, Marker.Items[i]);
end;

procedure TMarkerDescript.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.
