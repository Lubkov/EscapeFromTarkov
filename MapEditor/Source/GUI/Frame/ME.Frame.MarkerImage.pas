unit ME.Frame.MarkerImage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.Actions, FMX.ActnList, System.ImageList,
  FMX.ImgList, FMX.Grid, FMX.ScrollBox, FMX.Objects, FMX.Controls.Presentation,
  Map.Data.Types;

type
  TMarkerImagesGrid = class(TFrame)
    paTopPanel: TPanel;
    edAddMarkerImage: TSpeedButton;
    edEditMarkerImage: TSpeedButton;
    edDeleteMarkerImage: TSpeedButton;
    laTitle: TLabel;
    paPicture: TPanel;
    imMarkerPicture: TImage;
    Grid: TGrid;
    CaptionColumn: TStringColumn;
    ImageList1: TImageList;
    ActionList1: TActionList;
    acAddMarkerImage: TAction;
    acEditMarkerImage: TAction;
    acDeleteMarkerImage: TAction;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSelChanged(Sender: TObject);
  private
    FMarker: TMarker;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetMarkerImage(Index: Integer): TMarkerImage;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Marker: TMarker);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMarkerImage read GetMarkerImage;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

uses
  Map.Data.Service;

{$R *.fmx}

{ TMarkerImagesGrid }

constructor TMarkerImagesGrid.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TMarkerImagesGrid.Destroy;
begin

  inherited;
end;

procedure TMarkerImagesGrid.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnCaptionIdx = 0;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnCaptionIdx:
      Value := Items[ARow].Caption;
  end;
end;

procedure TMarkerImagesGrid.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

function TMarkerImagesGrid.GetCount: Integer;
begin
  if FMarker <> nil then
    Result := FMarker.Images.Count
  else
    Result := 0;
end;

function TMarkerImagesGrid.GetMarkerImage(Index: Integer): TMarkerImage;
begin
  Result := FMarker.Images[Index];
end;

function TMarkerImagesGrid.GetFocusedIndex: Integer;
begin
  if (FMarker = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TMarkerImagesGrid.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex = Value then
    Exit;

  FFocusedIndex := Value;
  if FocusedIndex >= 0 then
    DataSertvice.LoadImage(Items[FocusedIndex], imMarkerPicture.Bitmap)
  else
    imMarkerPicture.Bitmap.Assign(nil);
end;

procedure TMarkerImagesGrid.Init(const Marker: TMarker);
begin
  FMarker := Marker;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then begin
    Grid.Selected := -1;
    Grid.Selected := 0;
  end
  else
    imMarkerPicture.Bitmap.Assign(nil);
end;

end.
