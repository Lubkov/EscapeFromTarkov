unit ME.Frame.MarkerItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation,
  Map.Data.Types;

type
  TfrQuestItemsGrid = class(TFrame)
    paTopPanel: TPanel;
    edAddQuestItem: TSpeedButton;
    edDeleteQuestItem: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    NameColumn: TStringColumn;
    ActionList1: TActionList;
    acAddQuestItem: TAction;
    acDeleteQuestItem: TAction;
    ImageList1: TImageList;
    PictureColumn: TGlyphColumn;

    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
  private
    FMarker: TMarker;

    function GetCount: Integer;
    function GetItemImage(Index: Integer): TItemImage;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Init(const Marker: TMarker);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TItemImage read GetItemImage;
  end;

implementation

uses
  Map.Data.Service;

{$R *.fmx}

{ TfrQuestItemsGrid }

constructor TfrQuestItemsGrid.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

function TfrQuestItemsGrid.GetCount: Integer;
begin
  Result := FMarker.Items.Count;
end;

function TfrQuestItemsGrid.GetItemImage(Index: Integer): TItemImage;
begin
  Result := FMarker.Items[Index];
end;

procedure TfrQuestItemsGrid.Init(const Marker: TMarker);
begin
  FMarker := Marker;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then
    Grid.Selected := 0;
end;

procedure TfrQuestItemsGrid.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnPictureIdx = 0;
  ColumnNameIdx = 1;

begin
  if Count <= ARow then
    Exit;

  case ACol of
//    ColumnPictureIdx:
//      Value := Items[ARow].Caption;
// DataSertvice
    ColumnNameIdx:
      Value := Items[ARow].ID;
  end;
end;

end.
