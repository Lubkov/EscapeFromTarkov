unit ME.Frame.MapData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Controls.Presentation,
  FMX.TabControl,
  Map.Data.Types, ME.Frame.Marker, ME.Frame.Quest, ME.Frame.Layer;

type
  TfrMapData = class(TFrame)
    MainContainer: TTabControl;
    tabLayer: TTabItem;
    tabExtractions: TTabItem;
    tabQuests: TTabItem;
  private
    FMap: TMap;
    FLayerList: TfrLayerList;
    FMarkerGrid: TfrMarkerGrid;
    FQuestList: TfrQuest;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Init(const Map: TMap);
    procedure Clear;
  end;

implementation

{$R *.fmx}

{ TfrMapData }

constructor TfrMapData.Create(AOwner: TComponent);
begin
  inherited;

  FLayerList := TfrLayerList.Create(Self);
  FLayerList.Parent := tabLayer;
  FLayerList.Align := TAlignLayout.Client;

  FMarkerGrid := TfrMarkerGrid.Create(Self);
  FMarkerGrid.Parent := tabExtractions;
  FMarkerGrid.Align := TAlignLayout.Client;

  FQuestList := TfrQuest.Create(Self);
  FQuestList.Parent := tabQuests;
  FQuestList.Align := TAlignLayout.Client;
end;

procedure TfrMapData.Init(const Map: TMap);
begin
  FMap := Map;

  if Map <> nil then begin
    FLayerList.Init(FMap);
    FMarkerGrid.Init(FMap);
    FQuestList.Init(FMap);
  end
  else
    Clear;
end;

procedure TfrMapData.Clear;
begin

end;

end.
