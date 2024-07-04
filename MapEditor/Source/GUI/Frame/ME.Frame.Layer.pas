unit ME.Frame.Layer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FMX.Objects, System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox,
  Map.Data.Types;

type
  TfrLayerList = class(TFrame)
    ImageList1: TImageList;
    paTopPanel: TPanel;
    edAddLayer: TSpeedButton;
    edEditLayer: TSpeedButton;
    edDeleteLayer: TSpeedButton;
    laTitle: TLabel;
    ActionList1: TActionList;
    acAddLayer: TAction;
    acEditLayer: TAction;
    acDeleteLayer: TAction;
    paPicture: TPanel;
    imMapPicture: TImage;
    Grid: TGrid;
    LevelColumn: TIntegerColumn;
    CaptionColumn: TStringColumn;

    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSelChanged(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acAddLayerExecute(Sender: TObject);
    procedure acEditLayerExecute(Sender: TObject);
    procedure acDeleteLayerExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
  private
    FMap: TMap;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TLayer;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalLayerEdit(const Layer: TLayer): Boolean;
    procedure LayerEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Map: TMap);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TLayer read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

{$R *.fmx}

uses
  ME.DB.Utils, ME.Dialog.Presenter, ME.Presenter.Layer, ME.Edit.Layer,
  ME.Dialog.Message, Map.Data.Service;

{ TfrLayerList }

constructor TfrLayerList.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TfrLayerList.Destroy;
begin

  inherited;
end;

procedure TfrLayerList.Init(const Map: TMap);
begin
  FMap := Map;

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
    imMapPicture.Bitmap.Assign(nil);
end;

function TfrLayerList.GetCount: Integer;
begin
  if FMap <> nil then
    Result := FMap.Layers.Count
  else
    Result := 0;
end;

function TfrLayerList.GetItem(Index: Integer): TLayer;
begin
  Result := FMap.Layers[Index];
end;

function TfrLayerList.GetFocusedIndex: Integer;
begin
  if (FMap = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TfrLayerList.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex = Value then
    Exit;

  FFocusedIndex := Value;
  if FocusedIndex >= 0 then
    DataService.LoadImage(Items[FocusedIndex], imMapPicture.Bitmap)
  else
    imMapPicture.Bitmap.Assign(nil);
end;

function TfrLayerList.InternalLayerEdit(const Layer: TLayer): Boolean;
var
  Presenter: TEditLayerPresenter;
  Dialog: TedLayer;
begin
  Dialog := TedLayer.Create(Self);
  try
    Presenter := TEditLayerPresenter.Create(Dialog, Layer);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrLayerList.LayerEdit(const Index: Integer);
var
  Layer: TLayer;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Layer := Items[Index];
  Grid.BeginUpdate;
  try
    InternalLayerEdit(Layer);
//    imMapPicture.Bitmap.Assign(Layer.Picture);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrLayerList.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnLevelIdx = 0;
  ColumnCaptionIdx = 1;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnLevelIdx:
      Value := Items[ARow].Level;
    ColumnCaptionIdx:
      Value := Items[ARow].Caption;
  end;
end;

procedure TfrLayerList.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

procedure TfrLayerList.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddLayer.Enabled := FMap <> nil;
  acEditLayer.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
  acDeleteLayer.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
end;

procedure TfrLayerList.acAddLayerExecute(Sender: TObject);
var
  Layer: TLayer;
  Res: Boolean;
begin
  Res := False;
  Layer := TLayer.Create;
  try
    Res := InternalLayerEdit(Layer);
    if Res then begin
      FMap.Layers.Add(Layer);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      Layer.Free;
  end;
end;

procedure TfrLayerList.acEditLayerExecute(Sender: TObject);
begin
  LayerEdit(Grid.Selected);
end;

procedure TfrLayerList.acDeleteLayerExecute(Sender: TObject);
var
  Layer: TLayer;
  Presenter: TDelLayerPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Res := False;
  Layer := Items[Grid.Selected];
  try
    Dialog := TedMessage.Create(Self);
    try
      Presenter := TDelLayerPresenter.Create(Dialog, Layer);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FMap.Layers.Delete(Grid.Selected);
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
      Layer.Free;
  end;
end;

procedure TfrLayerList.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  LayerEdit(Row);
end;

end.
