unit ME.Frame.Quest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation,
  ME.DB.Entity, ME.DB.Map, ME.DB.Quest;

type
  TfrQuest = class(TFrame)
    paTopPanel: TPanel;
    edAddQuest: TSpeedButton;
    edEditQuest: TSpeedButton;
    edDeleteQuest: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    Column1: TColumn;
    StringColumn1: TStringColumn;
    ActionList1: TActionList;
    acAddQuest: TAction;
    acEditQuest: TAction;
    acDeleteQuest: TAction;
    ImageList1: TImageList;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure acAddQuestExecute(Sender: TObject);
    procedure acEditQuestExecute(Sender: TObject);
    procedure acDeleteQuestExecute(Sender: TObject);
  private
    FMap: TMap;
    FFocusedIndex: Integer;

    function GetCount: Integer;
    function GetItem(Index: Integer): TQuest;
    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalQuestEdit(const Quest: TQuest): Boolean;
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
  ME.Presenter.Quest, ME.Edit.Quest;

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
end;

procedure TfrQuest.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  ColumnKeyIdx = 0;
  ColumnNameIdx = 1;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    ColumnKeyIdx:
      Value := VarToStr(Items[ARow].ID);
    ColumnNameIdx:
      Value := VarToStr(Items[ARow].Name);
  end;
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
    Quest.MapID := FMap.ID;

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
//
end;

procedure TfrQuest.acDeleteQuestExecute(Sender: TObject);
begin
//
end;

end.
