unit ME.Frame.Extraction;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, ME.DB.Entity, ME.LocalMap, ME.MapTag;

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
    FLocalMap: TLocalMap;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMapTag;
    function InternalExtractionEdit(const MapTag: TMapTag): Boolean;
    procedure ExtractionEdit(const Index: Integer);
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const LocalMap: TLocalMap);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMapTag read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

uses
  ME.MapTagService, ME.Presenter.Extraction, ME.Edit.Extraction, ME.Dialog.Message;

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
  Result := FLocalMap.Tags.Count;
end;

function TfrExtraction.GetItem(Index: Integer): TMapTag;
begin
  Result := FLocalMap.Tags[Index];
end;

function TfrExtraction.InternalExtractionEdit(const MapTag: TMapTag): Boolean;
var
  Presenter: TEditExtractionPresenter;
  Dialog: TedExtraction;
begin
  Dialog := TedExtraction.Create(Self);
  try
    Presenter := TEditExtractionPresenter.Create(Dialog, MapTag);
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
  MapTag: TMapTag;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  MapTag := Items[Index];
  Grid.BeginUpdate;
  try
    InternalExtractionEdit(MapTag);
  finally
    Grid.EndUpdate;
  end;
end;

function TfrExtraction.GetFocusedIndex: Integer;
begin
  if (FLocalMap = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
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
      Value := TMapTag.KindToStr(Items[ARow].Kind);
    ColumnLeftIdx:
      Value := Items[ARow].Left;
    ColumnTopIdx:
      Value := Items[ARow].Top;
  end;
end;

procedure TfrExtraction.Init(const LocalMap: TLocalMap);
begin
  FLocalMap := LocalMap;

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
  MapTag: TMapTag;
  Res: Boolean;
begin
  Res := False;
  MapTag := TMapTag.Create;
  try
    MapTag.MapID := FLocalMap.ID;

    Res := InternalExtractionEdit(MapTag);
    if Res then begin
      FLocalMap.Tags.Add(MapTag);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      MapTag.Free;
  end;
end;

procedure TfrExtraction.acEditExtractionExecute(Sender: TObject);
begin
  ExtractionEdit(Grid.Selected);
end;

procedure TfrExtraction.acDeleteExtractionExecute(Sender: TObject);
var
  MapTag: TMapTag;
  Presenter: TDelExtractionPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Res := False;
  MapTag := Items[Grid.Selected];
  try
    Dialog := TedMessage.Create(Self);
    try
      Presenter := TDelExtractionPresenter.Create(Dialog, MapTag);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FLocalMap.Tags.Delete(Grid.Selected);
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
      MapTag.Free;
  end;
end;

procedure TfrExtraction.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  ExtractionEdit(Row);
end;

procedure TfrExtraction.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddExtraction.Enabled := FLocalMap <> nil;
  acEditExtraction.Enabled := (FLocalMap <> nil) and (FocusedIndex >= 0);
  acDeleteExtraction.Enabled := (FLocalMap <> nil) and (FocusedIndex >= 0);
end;

end.
