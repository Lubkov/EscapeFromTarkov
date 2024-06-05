unit ME.Frame.Point;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation,
  ME.DB.Quest, ME.DB.Point;

type
  TfrPointList = class(TFrame)
    paTopPanel: TPanel;
    edAddPoint: TSpeedButton;
    edEditPoint: TSpeedButton;
    edDeletePoint: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    ActionList1: TActionList;
    acAddPoint: TAction;
    acEditPoint: TAction;
    acDeletePoint: TAction;
    ImageList1: TImageList;
    IntegerColumn1: TIntegerColumn;
    IntegerColumn2: TIntegerColumn;
    IDColumn: TIntegerColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridSelChanged(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acAddPointExecute(Sender: TObject);
    procedure acEditPointExecute(Sender: TObject);
    procedure acDeletePointExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
  private
    FQuest: TQuest;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TPoint;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalPointEdit(const Point: TPoint): Boolean;
    procedure PointEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Quest: TQuest);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPoint read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

{$R *.fmx}

uses
  ME.Edit.Point, ME.Presenter.Point, ME.Dialog.Message;

{ TfrPointList }

constructor TfrPointList.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TfrPointList.Destroy;
begin

  inherited;
end;

function TfrPointList.GetCount: Integer;
begin
//  if FQuest <> nil then
//    Result := FQuest.Parts.Count
//  else
//    Result := 0;
end;

function TfrPointList.GetItem(Index: Integer): TPoint;
begin
//  Result := FQuest.Parts[Index];
end;

function TfrPointList.GetFocusedIndex: Integer;
begin
  if (FQuest = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TfrPointList.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex <> Value then
    FFocusedIndex := Value;
end;

function TfrPointList.InternalPointEdit(const Point: TPoint): Boolean;
var
  Presenter: TEditPointPresenter;
  Dialog: TedPoint;
begin
  Dialog := TedPoint.Create(Self);
  try
    Presenter := TEditPointPresenter.Create(Dialog, Point);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrPointList.PointEdit(const Index: Integer);
var
  Point: TPoint;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Point := Items[Index];
  Grid.BeginUpdate;
  try
    InternalPointEdit(Point);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrPointList.Init(const Quest: TQuest);
begin
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

procedure TfrPointList.GridGetValue(Sender: TObject; const ACol, ARow: Integer;  var Value: TValue);
const
  ColumnKeyIdx = 0;
  ColumnLeftIdx = 1;
  ColumnTopIdx = 2;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnKeyIdx:
      Value := VarToStr(Items[ARow].ID);
    ColumnLeftIdx:
      Value := Items[ARow].X;
    ColumnTopIdx:
      Value := Items[ARow].Y;
  end;
end;

procedure TfrPointList.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

procedure TfrPointList.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddPoint.Enabled := FQuest <> nil;
  acEditPoint.Enabled := (FQuest <> nil) and (FocusedIndex >= 0);
  acDeletePoint.Enabled := (FQuest <> nil) and (FocusedIndex >= 0);
end;

procedure TfrPointList.acAddPointExecute(Sender: TObject);
var
  Point: TPoint;
  Res: Boolean;
begin
//  Res := False;
//  Point := TPoint.Create;
//  try
//    Point.QuestID := FQuest.ID;
//
//    Res := InternalPointEdit(Point);
//    if Res then begin
//      FQuest.Parts.Add(Point);
//
//      Grid.BeginUpdate;
//      try
//        Grid.RowCount := Count;
//      finally
//        Grid.EndUpdate;
//      end;
//    end;
//  finally
//    if not Res then
//      Point.Free;
//  end;
end;

procedure TfrPointList.acEditPointExecute(Sender: TObject);
begin
  PointEdit(Grid.Selected);
end;

procedure TfrPointList.acDeletePointExecute(Sender: TObject);
var
  Point: TPoint;
  Presenter: TDelPointPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
//  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
//    Exit;
//
//  Res := False;
//  Point := Items[Grid.Selected];
//  try
//    Dialog := TedMessage.Create(Self);
//    try
//      Presenter := TDelPointPresenter.Create(Dialog, Point);
//      try
//        Res := Presenter.Delete;
//        if Res then begin
//          Grid.BeginUpdate;
//          try
//            FQuest.Parts.Delete(Grid.Selected);
//            Grid.RowCount := Count;
//          finally
//            Grid.EndUpdate;
//          end;
//        end;
//      finally
//        Presenter.Free;
//      end;
//    finally
//      Dialog.Free;
//    end;
//  finally
//    if Res then
//      Point.Free;
//  end;
end;

procedure TfrPointList.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  PointEdit(Row);
end;

end.
