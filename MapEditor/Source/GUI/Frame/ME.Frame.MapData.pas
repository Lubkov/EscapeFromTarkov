unit ME.Frame.MapData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Controls.Presentation,
  FMX.TabControl, FMX.Layouts,
  ME.DB.Map, Map.Data.Types, ME.Frame.Marker, ME.Frame.Quest, ME.Frame.Layer, ME.Frame.QuestPart;

type
  TfrMapData = class(TFrame)
    MainContainer: TTabControl;
    tabLayer: TTabItem;
    tabExtractions: TTabItem;
    tabQuests: TTabItem;
    QuestPartsLayout: TLayout;
    Splitter1: TSplitter;
    QuestLayout: TLayout;
  private
    FMap: TDBMap;
    FLayerList: TfrLayerList;
    FMarkerGrid: TfrMarkerGrid;
    FQuestList: TfrQuest;
    FQuestPartGrid: TfrQuestPartGrid;

    procedure OnQuestChanged(const QuestID: Variant);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const MapID: Variant);
    procedure Clear;
  end;

implementation

uses
  ME.DB.Utils, ME.Service.Map;

{$R *.fmx}

{ TfrMapData }

constructor TfrMapData.Create(AOwner: TComponent);
begin
  inherited;

  FMap := TDBMap.Create;

  FLayerList := TfrLayerList.Create(Self);
  FLayerList.Parent := tabLayer;
  FLayerList.Align := TAlignLayout.Client;

  FMarkerGrid := TfrMarkerGrid.Create(Self);
  FMarkerGrid.Parent := tabExtractions;
  FMarkerGrid.Align := TAlignLayout.Client;

  FQuestList := TfrQuest.Create(Self);
  FQuestList.Parent := QuestLayout;
  FQuestList.Align := TAlignLayout.Client;
  FQuestList.OnQuestChanged := OnQuestChanged;

  FQuestPartGrid := TfrQuestPartGrid.Create(Self);
  FQuestPartGrid.Parent := QuestPartsLayout;
  FQuestPartGrid.Align := TAlignLayout.Client;

  MainContainer.TabIndex := tabLayer.Index;
end;

destructor TfrMapData.Destroy;
begin
  FMap.Free;

  inherited;
end;

procedure TfrMapData.OnQuestChanged(const QuestID: Variant);
begin
  FQuestPartGrid.Init(FMap.ID, QuestID);
end;

procedure TfrMapData.Init(const MapID: Variant);
begin
  if FMap.ID = MapID then
    Exit;

  // TODO: Clear map instance
  FMap.Free;
  FMap := TDBMap.Create;

  if not IsNullID(MapID) then begin
    MapService.GetAt(MapID, FMap);

    FLayerList.Init(MapID);
    FMarkerGrid.Init(MapID);
    FQuestList.Init(MapID);
  end
  else
    Clear;
end;

procedure TfrMapData.Clear;
begin

end;

end.
