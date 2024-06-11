unit TM.Frame.MarkerFilter;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, System.ImageList, FMX.ImgList,
  FMX.ListBox, ME.DB.Map, ME.DB.Marker, ME.DB.Quest, ME.MarkerFilter;

type
  TMarkerFilterPanel = class(TFrame)
    ImageList24: TImageList;
    laTitle: TLabel;
    buPMCExtraction: TSpeedButton;
    buScavExtraction: TSpeedButton;
    buCoopExtraction: TSpeedButton;
    buClose: TButton;
    StyleBook: TStyleBook;
    MainContainer: TPanel;
    paPMCExtraction: TLayout;
    paScavExtraction: TLayout;
    paCoopExtraction: TLayout;
    QuestGrid: TGridLayout;
    Label1: TLabel;
    VertScrollBox1: TVertScrollBox;
    procedure buCloseClick(Sender: TObject);
  private
    FMarkerFilter: TMarkerFilter;
    FMap: TMap;
    FQuests: TList<TSpeedButton>;

    procedure ClearQuests;
    procedure OnMapChanged(Sender: TObject);
    procedure OnExtractionButtonClick(Sender: TObject);
    procedure OnQuestButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const MarkerFilter: TMarkerFilter);
  end;

implementation

{$R *.fmx}

constructor TMarkerFilterPanel.Create(AOwner: TComponent);
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
end;

destructor TMarkerFilterPanel.Destroy;
begin
  ClearQuests;
  FQuests.Free;

  inherited;
end;

procedure TMarkerFilterPanel.ClearQuests;
var
  Items: TSpeedButton;
begin
  for Items in FQuests do
    Items.Free;

  FQuests.Clear;
end;

procedure TMarkerFilterPanel.Init(const MarkerFilter: TMarkerFilter);
begin
  FMarkerFilter := MarkerFilter;
  FMarkerFilter.OnMapChanged := OnMapChanged;
end;

procedure TMarkerFilterPanel.buCloseClick(Sender: TObject);
begin
  Self.Visible := False;
end;

procedure TMarkerFilterPanel.OnMapChanged(Sender: TObject);
var
  Idx: Integer;
  Quest: TQuest;
  Item: TSpeedButton;
  Marker: TMarker;
  PMCCount: Integer;
  ScavCount: Integer;
  CoopCount: Integer;
begin
  FMap := TMap(Sender);

  PMCCount := 0;
  ScavCount := 0;
  CoopCount := 0;
  for Marker in FMap.Tags do
    case Marker.Kind of
      TMarkerKind.PMCExtraction:
        Inc(PMCCount);
      TMarkerKind.ScavExtraction:
        Inc(ScavCount);
      TMarkerKind.CoopExtraction:
        Inc(CoopCount);
    end;

  buPMCExtraction.Text := 'Выход ЧВК (' + PMCCount.ToString + ')';
  buScavExtraction.Text := 'Выход дикого (' + ScavCount.ToString + ')';
  buCoopExtraction.Text := 'Совм. выход (' + CoopCount.ToString + ')';

  QuestGrid.BeginUpdate;
  try
    ClearQuests;
  finally
    QuestGrid.EndUpdate;
  end;

  if not Assigned(FMap) then
    Exit;

  QuestGrid.BeginUpdate;
  try
    for Idx := 0 to FMap.Quests.Count - 1 do begin
      Quest := FMap.Quests[Idx];

      Item := TSpeedButton.Create(Self);
      try
        Item.Tag := Idx;
        Item.Parent := QuestGrid;
        Item.Cursor := crHandPoint;
        Item.Text := Quest.Name + ' (' + IntToStr(Quest.Markers.Count) + ')';
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
    QuestGrid.Width := VertScrollBox1.Width;
    QuestGrid.Height := QuestGrid.ItemHeight * FMap.Quests.Count;
  finally
    QuestGrid.EndUpdate;
  end;
end;

procedure TMarkerFilterPanel.OnExtractionButtonClick(Sender: TObject);
var
  Item: TSpeedButton;
begin
  Item := TSpeedButton(Sender);

  if Item.IsPressed then
    FMarkerFilter.EnableGroup(TMarkerKind(Item.Tag))
  else
    FMarkerFilter.DisableGroup(TMarkerKind(Item.Tag));
end;

procedure TMarkerFilterPanel.OnQuestButtonClick(Sender: TObject);
var
  Item: TSpeedButton;
begin
  Item := TSpeedButton(Sender);

  if Item.IsPressed then
    FMarkerFilter.EnableQuest(Item.Tag)
  else
    FMarkerFilter.DisablQuest(Item.Tag);
end;

end.



