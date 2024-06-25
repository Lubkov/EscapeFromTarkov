unit TM.Frame.MarkerFilter;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, System.ImageList, FMX.ImgList,
  FMX.ListBox, Map.Data.Types, ME.MarkerFilter;

type
  TMarkerFilterList = class(TFrame)
    ImageList24: TImageList;
    laExtractionGroup: TLabel;
    buPMCExtraction: TSpeedButton;
    buScavExtraction: TSpeedButton;
    buCoopExtraction: TSpeedButton;
    StyleBook: TStyleBook;
    paPMCExtraction: TLayout;
    paScavExtraction: TLayout;
    paCoopExtraction: TLayout;
    QuestGrid: TGridLayout;
    laQuestGroup: TLabel;
    QuestContainer: TVertScrollBox;
    buClose: TSpeedButton;
    procedure buCloseClick(Sender: TObject);
  private
    FMarkerFilter: TMarkerFilter;
    FMap: TMap;
    FQuests: TList<TSpeedButton>;
    FMaxHeight: Integer;
    FOnClose: TNotifyEvent;

    procedure ClearQuests;
    procedure OnMapChanged(Value: TMap);
    procedure OnExtractionButtonClick(Sender: TObject);
    procedure OnQuestButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const MarkerFilter: TMarkerFilter);

    property MaxHeight: Integer read FMaxHeight;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

implementation

{$R *.fmx}

constructor TMarkerFilterList.Create(AOwner: TComponent);
begin
  inherited;

  // PMCExtraction
  buPMCExtraction.Tag := Ord(TMarkerKind.PMCExtraction);
  buPMCExtraction.OnClick := OnExtractionButtonClick;
  // ScavExtraction
  buScavExtraction.Tag := Ord(TMarkerKind.ScavExtraction);
  buScavExtraction.OnClick := OnExtractionButtonClick;
  // CoopExtraction
  buCoopExtraction.Tag := Ord(TMarkerKind.CoopExtraction);
  buCoopExtraction.OnClick := OnExtractionButtonClick;

  FQuests := TList<TSpeedButton>.Create;

  laExtractionGroup.FontColor := $FFFFFFFF;
  laQuestGroup.FontColor := $FFFFFFFF;

  FMaxHeight := 0;
  FOnClose := nil;
end;

destructor TMarkerFilterList.Destroy;
begin
  FOnClose := nil;

  ClearQuests;
  FQuests.Free;

  inherited;
end;

procedure TMarkerFilterList.ClearQuests;
var
  Items: TSpeedButton;
begin
  for Items in FQuests do
    Items.Free;

  FQuests.Clear;
end;

procedure TMarkerFilterList.Init(const MarkerFilter: TMarkerFilter);
begin
  FMarkerFilter := MarkerFilter;
  FMarkerFilter.OnMapChanged := OnMapChanged;
end;

procedure TMarkerFilterList.OnMapChanged(Value: TMap);
var
  Idx: Integer;
  Quest: TQuest;
  Item: TSpeedButton;
  Marker: TMarker;
  PMCCount: Integer;
  ScavCount: Integer;
  CoopCount: Integer;
begin
  FMap := Value;
  if FMap = nil then begin
    ClearQuests;
    Exit;
  end;

  PMCCount := 0;
  ScavCount := 0;
  CoopCount := 0;
  for Marker in FMap.Markers do
    case Marker.Kind of
      TMarkerKind.PMCExtraction:
        Inc(PMCCount);
      TMarkerKind.ScavExtraction:
        Inc(ScavCount);
      TMarkerKind.CoopExtraction:
        Inc(CoopCount);
    end;

  buPMCExtraction.Text := TMarker.KindToStr(TMarkerKind.PMCExtraction) + ' (' + PMCCount.ToString + ')';
  buScavExtraction.Text := TMarker.KindToStr(TMarkerKind.ScavExtraction) + ' (' + ScavCount.ToString + ')';
  buCoopExtraction.Text := TMarker.KindToStr(TMarkerKind.CoopExtraction) + ' (' + CoopCount.ToString + ')';

  QuestGrid.BeginUpdate;
  try
    ClearQuests;
  finally
    QuestGrid.EndUpdate;
  end;

  QuestGrid.BeginUpdate;
  try
    for Idx := 0 to FMap.Quests.Count - 1 do begin
      Quest := FMap.Quests[Idx];

      Item := TSpeedButton.Create(Self);
      try
        Item.Tag := Idx;
        Item.Parent := QuestGrid;
        Item.Cursor := crHandPoint;
        Item.Text := Quest.Caption + ' (' + IntToStr(Quest.Markers.Count) + ')';
        Item.StaysPressed := True;
        Item.StyleLookup := 'FilterItemStyle';
        Item.TextSettings.HorzAlign := TTextAlign.Leading;
        Item.OnClick := OnQuestButtonClick;
      finally
        FQuests.Add(Item);
      end;
    end;

    QuestGrid.Position.X := 0;
    QuestGrid.Position.Y := 0;
    QuestGrid.Width := QuestContainer.Width;
    QuestGrid.Height := QuestGrid.ItemHeight * FMap.Quests.Count;
  finally
    QuestGrid.EndUpdate;
  end;

  FMaxHeight := Trunc(QuestContainer.Position.Y + QuestGrid.Height) + 10;
  Self.Height := MaxHeight;
end;

procedure TMarkerFilterList.OnExtractionButtonClick(Sender: TObject);
var
  Item: TSpeedButton;
begin
  Item := TSpeedButton(Sender);

  if Item.IsPressed then
    FMarkerFilter.EnableGroup(TMarkerKind(Item.Tag))
  else
    FMarkerFilter.DisableGroup(TMarkerKind(Item.Tag));
end;

procedure TMarkerFilterList.OnQuestButtonClick(Sender: TObject);
var
  Item: TSpeedButton;
begin
  Item := TSpeedButton(Sender);

  if Item.IsPressed then
    FMarkerFilter.EnableQuest(Item.Tag)
  else
    FMarkerFilter.DisablQuest(Item.Tag);
end;

procedure TMarkerFilterList.buCloseClick(Sender: TObject);
begin
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.



