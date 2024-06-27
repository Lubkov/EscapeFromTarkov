unit ME.Frame.Quest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation,
  Map.Data.Types;

type
  TfrQuest = class(TFrame)
    paTopPanel: TPanel;
    edAddQuest: TSpeedButton;
    edEditQuest: TSpeedButton;
    edDeleteQuest: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    ActionList1: TActionList;
    acAddQuest: TAction;
    acEditQuest: TAction;
    acDeleteQuest: TAction;
    ImageList1: TImageList;
    NameColumn: TStringColumn;
    TraderColumn: TStringColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acAddQuestExecute(Sender: TObject);
    procedure acEditQuestExecute(Sender: TObject);
    procedure acDeleteQuestExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure GridSelChanged(Sender: TObject);
  private
    FMap: TMap;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TQuest;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalQuestEdit(const Quest: TQuest): Boolean;
    procedure QuestEdit(const Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Map: TMap);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TQuest read GetItem;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

{$R *.fmx}

uses
  ME.Presenter.Quest, ME.Edit.Quest, ME.Dialog.Message;

{ TfrQuest }

constructor TfrQuest.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TfrQuest.Destroy;
begin

  inherited;
end;

function TfrQuest.GetCount: Integer;
begin
  Result := FMap.Quests.Count;
end;

function TfrQuest.GetItem(Index: Integer): TQuest;
begin
  Result := FMap.Quests[Index];
end;

function TfrQuest.GetFocusedIndex: Integer;
begin
  if (FMap = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TfrQuest.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex <> Value then
    FFocusedIndex := Value;
end;

function TfrQuest.InternalQuestEdit(const Quest: TQuest): Boolean;
var
  Presenter: TEditQuestPresenter;
  Dialog: TedQuest;
begin
  Dialog := TedQuest.Create(Self);
  try
    Dialog.Map := FMap;

    Presenter := TEditQuestPresenter.Create(Dialog, Quest);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrQuest.QuestEdit(const Index: Integer);
var
  Quest: TQuest;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Quest := Items[Index];
  Grid.BeginUpdate;
  try
    InternalQuestEdit(Quest);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfrQuest.Init(const Map: TMap);
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

  NameColumn.Width := Grid.Width - TraderColumn.Width - 25;
end;

procedure TfrQuest.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnNameIdx = 0;
  ColumnTraderIdx = 1;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnNameIdx:
      Value := Items[ARow].Caption;
    ColumnTraderIdx:
      Value := TQuest.TraderToStr(Items[ARow].Trader);
  end;
end;

procedure TfrQuest.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

procedure TfrQuest.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  acAddQuest.Enabled := FMap <> nil;
  acEditQuest.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
  acDeleteQuest.Enabled := (FMap <> nil) and (FocusedIndex >= 0);
end;

procedure TfrQuest.acAddQuestExecute(Sender: TObject);
var
  Quest: TQuest;
  Res: Boolean;
begin
  Res := False;
  Quest := TQuest.Create;
  try
    Res := InternalQuestEdit(Quest);
    if Res then begin
      FMap.Quests.Add(Quest);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      Quest.Free;
  end;
end;

procedure TfrQuest.acEditQuestExecute(Sender: TObject);
begin
  QuestEdit(Grid.Selected);
end;

procedure TfrQuest.acDeleteQuestExecute(Sender: TObject);
var
  Quest: TQuest;
  Presenter: TDelQuestPresenter;
  Dialog: TedMessage;
  Res: Boolean;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Res := False;
  Quest := Items[Grid.Selected];
  try
    Dialog := TedMessage.Create(Self);
    try
      Presenter := TDelQuestPresenter.Create(Dialog, Quest);
      try
        Res := Presenter.Delete;
        if Res then begin
          Grid.BeginUpdate;
          try
            FMap.Quests.Delete(Grid.Selected);
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
      Quest.Free;
  end;
end;

procedure TfrQuest.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  QuestEdit(Row);
end;

end.
