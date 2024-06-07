unit TM.Frame.MarkerFilter;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.ImageList, FMX.ImgList, FMX.ListBox,
  ME.DB.Map, ME.DB.Marker, ME.DB.Quest, ME.MarkerFilter;

type
  TMarkerFilterPanel = class(TFrame)
    ImageList24: TImageList;
    Label1: TLabel;
    buPMCExtraction: TSpeedButton;
    buScavExtraction: TSpeedButton;
    buCoopExtraction: TSpeedButton;
    buClose: TButton;
    StyleBook: TStyleBook;
    MainContainer: TPanel;
    QuestList: TListBox;
    procedure buCloseClick(Sender: TObject);
    procedure QuestListChangeCheck(Sender: TObject);
  private
    FMarkerFilter: TMarkerFilter;
    FMap: TMap;

    procedure OnMapChanged(Sender: TObject);
    procedure OnExtractionButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

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

procedure TMarkerFilterPanel.QuestListChangeCheck(Sender: TObject);
var
  Item: TListBoxItem;
begin
  Item := TListBoxItem(Sender);
  if Item.IsChecked then
    FMarkerFilter.EnableQuest(Item.Index)
  else
    FMarkerFilter.DisablQuest(Item.Index);
end;

procedure TMarkerFilterPanel.OnMapChanged(Sender: TObject);
var
  Quest: TQuest;
begin
  FMap := TMap(Sender);

  QuestList.BeginUpdate;
  try
    QuestList.Items.Clear;

    if FMap <> nil then
      for Quest in FMap.Quests do
        QuestList.Items.AddObject(Quest.Name + ' (' + IntToStr(Quest.Markers.Count) + ')', Quest);
  finally
    QuestList.EndUpdate;
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

end.



