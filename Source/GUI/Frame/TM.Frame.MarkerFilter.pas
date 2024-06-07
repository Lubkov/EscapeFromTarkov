unit TM.Frame.MarkerFilter;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.ImageList, FMX.ImgList, FMX.ListBox,
  ME.DB.Map, ME.DB.Marker, ME.DB.Quest;

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
  private
    FMap: TMap;
    FOnFilterChanged: TNotifyEvent;
    FExtractionFilter: TMarkerKindSet;

    procedure OnExtractionButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    procedure Init(const Map: TMap);

    property OnFilterChanged: TNotifyEvent read FOnFilterChanged write FOnFilterChanged;
    property ExtractionFilter: TMarkerKindSet read FExtractionFilter;
  end;

implementation

{$R *.fmx}

// TMarkerKind = (tkPMCExtraction, tkScavExtraction, tkCoopExtraction, Quest);

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

procedure TMarkerFilterPanel.Init(const Map: TMap);
var
  Quest: TQuest;
begin
  FMap := Map;

  QuestList.BeginUpdate;
  try
    QuestList.Items.Create;

    if FMap <> nil then
      for Quest in FMap.Quests do
        QuestList.Items.AddObject(Quest.Name + ' (' + IntToStr(Quest.Markers.Count) + ')', Quest);
  finally
    QuestList.EndUpdate;
  end;
end;

procedure TMarkerFilterPanel.buCloseClick(Sender: TObject);
begin
  Self.Visible := False;
end;

procedure TMarkerFilterPanel.OnExtractionButtonClick(Sender: TObject);
var
  Item: TSpeedButton;
begin
  Item := TSpeedButton(Sender);

  if Item.IsPressed then
    FExtractionFilter := FExtractionFilter + [TMarkerKind(Item.Tag)]
  else
    FExtractionFilter := FExtractionFilter - [TMarkerKind(Item.Tag)];

  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self);
end;

end.
