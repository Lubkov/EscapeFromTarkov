unit ME.Frame.QuestItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
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
    PictureColumn: TImageColumn;
    OpenDialog: TOpenDialog;

    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure acDeleteQuestItemExecute(Sender: TObject);
    procedure acAddQuestItemExecute(Sender: TObject);
  private
    FMarker: TMarker;
    FIcons: TObjectList<TBitmap>;

    function GetCount: Integer;
    function GetItemImage(Index: Integer): TQuestItem;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Marker: TMarker);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TQuestItem read GetItemImage;
  end;

implementation

uses
  Map.Data.Service, ME.Presenter.QuestItem, ME.Dialog.Message;

{$R *.fmx}

{ TfrQuestItemsGrid }

constructor TfrQuestItemsGrid.Create(AOwner: TComponent);
begin
  inherited;

  FIcons := TObjectList<TBitmap>.Create;
  Grid.RowCount := 0;
end;

destructor TfrQuestItemsGrid.Destroy;
begin
  FIcons.Destroy;

  inherited;
end;

function TfrQuestItemsGrid.GetCount: Integer;
begin
  Result := FMarker.Items.Count;
end;

function TfrQuestItemsGrid.GetItemImage(Index: Integer): TQuestItem;
begin
  Result := FMarker.Items[Index];
end;

procedure TfrQuestItemsGrid.Init(const Marker: TMarker);
var
  i: Integer;
  bmp: TBitmap;
begin
  FMarker := Marker;

  for i := 0 to Count - 1 do begin
    bmp := TBitmap.Create;
    try
      DataSertvice.LoadImage(Items[i], bmp);
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

procedure TfrQuestItemsGrid.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnPictureIdx = 0;
  ColumnNameIdx = 1;

begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnPictureIdx:
      Value := FIcons[ARow];
    ColumnNameIdx:
      Value := Items[ARow].ID;
  end;
end;

procedure TfrQuestItemsGrid.acAddQuestItemExecute(Sender: TObject);
var
  QuestItem: TQuestItem;
  id: TGUID;
  bmp: TBitmap;
begin
  if not OpenDialog.Execute then
    Exit;

  QuestItem := TQuestItem.Create;
  try
    CreateGUID(id);
    QuestItem.ID := GUIDToString(id);

    bmp := TBitmap.Create;
    try
      bmp.LoadFromFile(OpenDialog.FileName);

      DataSertvice.SaveImage(QuestItem, bmp);
    finally
      FIcons.Add(bmp);
    end;
  finally
    FMarker.Items.Add(QuestItem);
  end;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrQuestItemsGrid.acDeleteQuestItemExecute(Sender: TObject);
var
  QuestItem: TQuestItem;
  Presenter: TDelQuestItemPresenter;
  Dialog: TedMessage;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  QuestItem := Items[Grid.Selected];

  Dialog := TedMessage.Create(Self);
  try
    Presenter := TDelQuestItemPresenter.Create(Dialog, QuestItem);
    try
      if Presenter.Delete then begin
        Grid.BeginUpdate;
        try
          FMarker.Items.Delete(Grid.Selected);
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
end;

end.
