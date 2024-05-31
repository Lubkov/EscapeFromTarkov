unit ME.Frame.Extraction;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, ME.DB.Entity, ME.DB.Map, ME.DB.Marker;

type
  TfrExtraction = class(TFrame)
    ActionList1: TActionList;
    acAddExtraction: TAction;
    acEditExtraction: TAction;
    acDeleteExtraction: TAction;
    ImageList1: TImageList;
    paTopPanel: TPanel;
    edAddMap: TSpeedButton;
    edEditMap: TSpeedButton;
    edDeleteMap: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    Column1: TColumn;
    StringColumn1: TStringColumn;
    IntegerColumn1: TIntegerColumn;
    StringColumn2: TStringColumn;
    IntegerColumn2: TIntegerColumn;

    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure acAddExtractionExecute(Sender: TObject);
    procedure acEditExtractionExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acDeleteExtractionExecute(Sender: TObject);
  private
    FMap: TMap;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMarker;
    function InternalExtractionEdit(const Marker: TMarker): Boolean;
    procedure ExtractionEdit(const Index: Integer);
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Map: TMap);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMarker read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

uses
  ME.Service.Marker, ME.Presenter.Extraction, ME.Edit.Extraction, ME.Dialog.Message;

{$R *.fmx}

constructor TfrExtraction.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TfrExtraction.Destroy;
begin

  inherited;
end;

function TfrExtraction.GetCount: Integer;
begin
  Result := FMap.Tags.Count;
end;

function TfrExtraction.GetItem(Index: Integer): TMarker;
begin
  Result := FMap.Tags[Index];
end;

function TfrExtraction.InternalExtractionEdit(const Marker: TMarker): Boolean;
var
  Presenter: TEditExtractionPresenter;
  Dialog: TedExtraction;
begin
  Dialog := TedExtraction.Create(Self);
  try
    Presenter := TEditExtractionPresenter.Create(Dialog, Marker);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrExtraction.ExtractionEdit(const Index: Integer);
var
  Marker: TMarker;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Marker := Items[Index];
  Grid.BeginUpdate;
  try
    InternalExtractionEdit(Marker);
  finally
    Grid.EndUpdate;
  end;
end;

function TfrExtraction.GetFocusedIndex: Integer;
begin
  if (FMap = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TfrExtraction.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex <> Value then
    FFocusedIndex := Value;
end;

procedure TfrExtraction.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnKeyIdx = 0;
  ColumnNameIdx = 1;
  ColumnKindIdx = 2;
  ColumnLeftIdx = 3;
  ColumnTopIdx = 4;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnKeyIdx:
      Value := VarToStr(Items[ARow].ID);
    ColumnNameIdx:
      Value := VarToStr(Items[ARow].Name);
    ColumnKindIdx:
      Value := TMarker.KindToStr(Items[ARow].Kind);
    ColumnLeftIdx:
      Value := Items[ARow].Left;
    ColumnTopIdx:
      Value := Items[ARow].Top;
  end;
end;

procedure TfrExtraction.Init(const Map: TMap);
begin
  FMap := Map;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then
    Grid.Selected := 0;
end;

procedure TfrExtraction.acAddExtractionExecute(Sender: TObject);
var
  Marker: TMarker;
  Res: Boolean;
begin
  Res := False;
  Marker := TMarker.Create;
  try
    Marker.MapID := FMap.ID;

    Res := InternalExtractionEdit(Marker);
    if Res then begin
      FMap.Tags.Add(Marker);

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

procedure TfrExtraction.acEditExtractionExecute(Sender: TObject);
begin
  ExtractionEdit(Grid.Selected);
end;

procedure TfrExtraction.acDeleteExtractionExecute(Sender: TObject);
var
  Marker: TMarker;
  Presenter: TDelExtractionPresenter;
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
      Presenter := TDelExtractionPresenter.Create(Dialog, Marker);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FMap.Tags.Delete(Grid.Selected);
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

procedure TfrExtraction.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  ExtractionEdit(Row);
end;

procedure TfrExtraction.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddExtraction.Enabled := FMap <> nil;
  acEditExtraction.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
  acDeleteExtraction.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
end;

end.
