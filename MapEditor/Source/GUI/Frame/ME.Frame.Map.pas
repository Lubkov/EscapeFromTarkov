unit ME.Frame.Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, System.ImageList, FMX.ImgList, FMX.Controls.Presentation, FMX.Styles.Objects,
  FMX.Objects, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts, System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox,
  ME.DB.Entity, ME.DB.Map, System.Actions, FMX.ActnList;

type
  TOnChangeEvent = procedure (const Map: TMap) of object;

  TfrMap = class(TFrame)
    paTopPanel: TPanel;
    edAddMap: TSpeedButton;
    ImageList1: TImageList;
    edEditMap: TSpeedButton;
    edDeleteMap: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    Column1: TColumn;
    Column2: TColumn;
    Column4: TColumn;
    Column5: TColumn;
    Column6: TColumn;
    ActionList1: TActionList;
    acAddMap: TAction;
    acEditMap: TAction;
    acDeleteMap: TAction;
    ImageList2: TImageList;
    ImageColumn1: TImageColumn;
    IntegerColumn1: TIntegerColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure acAddMapExecute(Sender: TObject);
    procedure acEditMapExecute(Sender: TObject);
    procedure acDeleteMapExecute(Sender: TObject);
    procedure GridSelChanged(Sender: TObject);
  private
    FItems: TList<TEntity>;
    FOnChange: TOnChangeEvent;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMap;
    function InternalMapEdit(const Map: TMap): Boolean;
    procedure MapEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    procedure Clear;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMap read GetItem;
    property OnChange: TOnChangeEvent read FOnChange write FOnChange;
  end;

implementation

uses
  ME.DB.Utils, ME.Dialog.Presenter, ME.Presenter.Map, ME.Edit.Map, ME.DB.Quest,
  ME.Service.Map, ME.Dialog.Message, ME.Service.Marker, ME.Service.Quest;

{$R *.fmx}

{ TfrMap }

constructor TfrMap.Create(AOwner: TComponent);
begin
  inherited;

  FItems := TList<TEntity>.Create;
  Grid.RowCount := 0;
  FOnChange := nil;
end;

destructor TfrMap.Destroy;
begin
  FOnChange := nil;
  Clear;
  FItems.Free;

  inherited;
end;

function TfrMap.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TfrMap.GetItem(Index: Integer): TMap;
begin
  Result := TMap(FItems[Index]);
end;

function TfrMap.InternalMapEdit(const Map: TMap): Boolean;
var
  Presenter: TEditMapPresenter;
  Dialog: TedMap;
begin
  Dialog := TedMap.Create(Self);
  try
    Presenter := TEditMapPresenter.Create(Dialog, Map);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrMap.MapEdit(const Index: Integer);
var
  Map: TMap;
  Quest: TQuest;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Map := Items[Index];
  if (Map.Layers.Count = 0) and (Map.Tags.Count = 0) and (Map.Quests.Count = 0) then begin
    MapService.LoadLayers(Map, True);
    MarkerService.LoadMarkers(Map.ID, Map.Tags);
    QuestService.LoadQuests(Map.ID, Map.Quests);

    for Quest in Map.Quests do
      QuestService.LoadMarkers(Quest.MapID, Quest.ID, Quest.Markers);
  end;

  Grid.BeginUpdate;
  try
    InternalMapEdit(Map);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrMap.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnKeyIdx = 0;
  ColumnNameIdx = 1;
  ColumnLeftIdx = 2;
  ColumnTopIdx = 3;
  ColumnRightIdx = 4;
  ColumnBottomIdx = 5;
  ColumnImageIdx = 6;
begin
  if FItems.Count <= ARow then
    Exit;

  case ACol of
    ColumnKeyIdx:
      Value := VarToStr(Items[ARow].ID);
    ColumnNameIdx:
      Value := Items[ARow].Name;
    ColumnLeftIdx:
      Value := Items[ARow].Left;
    ColumnTopIdx:
      Value := Items[ARow].Top;
    ColumnRightIdx:
      Value := Items[ARow].Right;
    ColumnBottomIdx:
      Value := Items[ARow].Bottom;
    ColumnImageIdx:
      Value := Items[ARow].Picture;
  end;
end;

procedure TfrMap.GridSelChanged(Sender: TObject);
var
  Item: TMap;
begin
  if not Assigned(FOnChange) then
    Exit;

  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Item := nil
  else
    Item := Items[Grid.Selected];

  FOnChange(Item);
end;

procedure TfrMap.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  MapEdit(Row);
end;

procedure TfrMap.Init;
begin
  MapService.GetAll(FItems);

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then
    Grid.Selected := 0;
end;

procedure TfrMap.Clear;
var
  Item: TEntity;
begin
  for Item in FItems do
    Item.Free;

  FItems.Clear;
end;

procedure TfrMap.acAddMapExecute(Sender: TObject);
var
  Map: TMap;
  Res: Boolean;
begin
  Res := False;
  Map := TMap.Create;
  try
    Res := InternalMapEdit(Map);
    if Res then begin
      FItems.Add(Map);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      Map.Free;
  end;
end;

procedure TfrMap.acEditMapExecute(Sender: TObject);
begin
  MapEdit(Grid.Selected);
end;

procedure TfrMap.acDeleteMapExecute(Sender: TObject);
var
  Map: TMap;
  Presenter: TDelMapPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Res := False;
  Map := Items[Grid.Selected];
  try
    Dialog := TedMessage.Create(Self);
    try
      Presenter := TDelMapPresenter.Create(Dialog, Map);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FItems.Delete(Grid.Selected);
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
      Map.Free;
  end;
end;

end.
