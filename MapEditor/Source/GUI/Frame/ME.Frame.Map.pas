unit ME.Frame.Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  FMX.Controls.Presentation, FMX.Styles.Objects, FMX.Objects, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Layouts,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox,  System.Actions,
  FMX.ActnList, Map.Data.Types;

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
    NameColumn: TColumn;
    ActionList1: TActionList;
    acAddMap: TAction;
    acEditMap: TAction;
    acDeleteMap: TAction;
    ImageList2: TImageList;
    PictureColumn: TImageColumn;
    LeftColumn: TIntegerColumn;
    CaptionColumn: TStringColumn;
    TopColumn: TIntegerColumn;
    RightColumn: TIntegerColumn;
    BottomColumn: TIntegerColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure acAddMapExecute(Sender: TObject);
    procedure acEditMapExecute(Sender: TObject);
    procedure acDeleteMapExecute(Sender: TObject);
    procedure GridSelChanged(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    FIcons: TObjectList<TBitmap>;
    FOnChange: TOnChangeEvent;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMap;
    function InternalMapEdit(const Map: TMap): Boolean;
    procedure MapEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMap read GetItem;
    property OnChange: TOnChangeEvent read FOnChange write FOnChange;
  end;

implementation

uses
  App.Constants, Map.Data.Service, ME.Presenter.Map, ME.Edit.Map;

{$R *.fmx}

{ TfrMap }

constructor TfrMap.Create(AOwner: TComponent);
begin
  inherited;

  FIcons := TObjectList<TBitmap>.Create;
  Grid.RowCount := 0;
  FOnChange := nil;
end;

destructor TfrMap.Destroy;
begin
  FOnChange := nil;
  FIcons.Free;

  inherited;
end;

function TfrMap.GetCount: Integer;
begin
  Result := DataSertvice.Count;
end;

function TfrMap.GetItem(Index: Integer): TMap;
begin
  Result := DataSertvice.Items[Index];
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
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Grid.BeginUpdate;
  try
    InternalMapEdit(Items[Index]);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrMap.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnNameIdx = 0;
  ColumnCaptionIdx = 1;
  ColumnLeftIdx = 2;
  ColumnTopIdx = 3;
  ColumnRightIdx = 4;
  ColumnBottomIdx = 5;
  ColumnImageIdx = 6;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnNameIdx:
      Value := Items[ARow].Name;
    ColumnCaptionIdx:
      Value := Items[ARow].Caption;
    ColumnLeftIdx:
      Value := Items[ARow].Left;
    ColumnTopIdx:
      Value := Items[ARow].Top;
    ColumnRightIdx:
      Value := Items[ARow].Right;
    ColumnBottomIdx:
      Value := Items[ARow].Bottom;
    ColumnImageIdx:
      Value := FIcons[ARow];
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

procedure TfrMap.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddMap.Enabled := False;
  acEditMap.Enabled := (Grid.Selected >= 0) and (Count > 0);
  acDeleteMap.Enabled := False;
end;

procedure TfrMap.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  MapEdit(Row);
end;

procedure TfrMap.Init;
var
  i: Integer;
  bmp: TBitmap;
begin
  for i := 0 to Count - 1 do begin
    bmp := TBitmap.Create;
    try
      DataSertvice.LoadMapIcon(Items[i].Name, bmp);
    finally
      FIcons.Add(bmp);
    end;
  end;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then
    Grid.Selected := 0;
end;

procedure TfrMap.acAddMapExecute(Sender: TObject);
//var
//  Map: TMap;
//  Res: Boolean;
begin
//  Res := False;
//  Map := TMap.Create;
//  try
//    Res := InternalMapEdit(Map);
//    if Res then begin
//      FItems.Add(Map);
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
//      Map.Free;
//  end;
end;

procedure TfrMap.acEditMapExecute(Sender: TObject);
begin
  MapEdit(Grid.Selected);
end;

procedure TfrMap.acDeleteMapExecute(Sender: TObject);
//var
//  Map: TMap;
//  Presenter: TDelMapPresenter;
//  Dialog: TedMessage;
//  Res: Boolean;
begin
//  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
//    Exit;
//
//  Res := False;
//  Map := Items[Grid.Selected];
//  try
//    Dialog := TedMessage.Create(Self);
//    try
//      Presenter := TDelMapPresenter.Create(Dialog, Map);
//      try
//        Res := Presenter.Delete;
//        if Res then begin
//          Grid.BeginUpdate;
//          try
//            FItems.Delete(Grid.Selected);
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
//      Map.Free;
//  end;
end;

end.
