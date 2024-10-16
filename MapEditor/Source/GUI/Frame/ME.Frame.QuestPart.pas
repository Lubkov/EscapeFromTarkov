unit ME.Frame.QuestPart;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation,
  Map.Data.Types;

type
  TfrQuestPartGrid = class(TFrame)
    paTopPanel: TPanel;
    edAddMarker: TSpeedButton;
    edEditMarker: TSpeedButton;
    edDeleteMarker: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    ActionList1: TActionList;
    acAddMarker: TAction;
    acEditMarker: TAction;
    acDeleteMarker: TAction;
    ImageList1: TImageList;
    LeftColumn: TIntegerColumn;
    RightColumn: TIntegerColumn;
    DescriptionColumn: TStringColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSelChanged(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acAddMarkerExecute(Sender: TObject);
    procedure acEditMarkerExecute(Sender: TObject);
    procedure acDeleteMarkerExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
  private
    FMap: TMap;
    FQuest: TQuest;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMarker;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalMarkerEdit(const Point: TMarker): Boolean;
    procedure MarkerEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Map: TMap; const Quest: TQuest);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMarker read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

{$R *.fmx}

uses
  ME.Edit.QuestPart, ME.Presenter.QuestPart, ME.Dialog.Message;

{ frQuestPartGrid }

constructor TfrQuestPartGrid.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TfrQuestPartGrid.Destroy;
begin

  inherited;
end;

function TfrQuestPartGrid.GetCount: Integer;
begin
  if FQuest <> nil then
    Result := FQuest.Markers.Count
  else
    Result := 0;
end;

function TfrQuestPartGrid.GetItem(Index: Integer): TMarker;
begin
  Result := FQuest.Markers[Index];
end;

function TfrQuestPartGrid.GetFocusedIndex: Integer;
begin
  if (FQuest = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TfrQuestPartGrid.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex <> Value then
    FFocusedIndex := Value;
end;

function TfrQuestPartGrid.InternalMarkerEdit(const Point: TMarker): Boolean;
var
  Presenter: TEditQuestPartPresenter;
  Dialog: TedQuestPart;
begin
  Dialog := TedQuestPart.Create(Self);
  try
    Dialog.Map := FMap;

    Presenter := TEditQuestPartPresenter.Create(Dialog, Point);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrQuestPartGrid.MarkerEdit(const Index: Integer);
var
  Marker: TMarker;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Marker := Items[Index];
  Grid.BeginUpdate;
  try
    InternalMarkerEdit(Marker);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrQuestPartGrid.Init(const Map: TMap; const Quest: TQuest);
begin
  FMap := Map;
  FQuest := Quest;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then begin
    Grid.Selected := -1;
    Grid.Selected := 0;
  end;
end;

procedure TfrQuestPartGrid.GridGetValue(Sender: TObject; const ACol, ARow: Integer;  var Value: TValue);
const
  ColumnLeftIdx = 0;
  ColumnTopIdx = 1;
  ColumnDescriptionIdx = 2;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnLeftIdx:
      Value := Items[ARow].Left;
    ColumnTopIdx:
      Value := Items[ARow].Top;
    ColumnDescriptionIdx:
      Value := Items[ARow].Caption;
  end;
end;

procedure TfrQuestPartGrid.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

procedure TfrQuestPartGrid.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddMarker.Enabled := FQuest <> nil;
  acEditMarker.Enabled := (FQuest <> nil) and (FocusedIndex >= 0);
  acDeleteMarker.Enabled := (FQuest <> nil) and (FocusedIndex >= 0);
end;

procedure TfrQuestPartGrid.acAddMarkerExecute(Sender: TObject);
var
  Marker: TMarker;
  Res: Boolean;
begin
  Res := False;
  Marker := TMarker.Create;
  try
    Marker.Kind := TMarkerKind.Quest;

    Res := InternalMarkerEdit(Marker);
    if Res then begin
      FQuest.Markers.Add(Marker);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      Marker.Free;
  end;
end;

procedure TfrQuestPartGrid.acEditMarkerExecute(Sender: TObject);
begin
  MarkerEdit(Grid.Selected);
end;

procedure TfrQuestPartGrid.acDeleteMarkerExecute(Sender: TObject);
var
  Marker: TMarker;
  Presenter: TDelQuestPartPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Res := False;
  Marker := Items[Grid.Selected];
  try
    Dialog := TedMessage.Create(Self);
    try
      Presenter := TDelQuestPartPresenter.Create(Dialog, Marker);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FQuest.Markers.Delete(Grid.Selected);
            Grid.RowCount := Count;
          finally
            Grid.EndUpdate;
          end;
        end;
      finally
        Presenter.Free;
      end;
    finally
      Dialog.Free;
    end;
  finally
    if Res then
      Marker.Free;
  end;
end;

procedure TfrQuestPartGrid.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  MarkerEdit(Row);
end;

end.
