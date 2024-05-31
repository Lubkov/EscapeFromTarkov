﻿unit ME.Edit.Quest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Controls.Presentation, FMX.Edit,
  ME.Edit.Form, ME.Edit.Form.Presenter, ME.DB.Quest, ME.Frame.Point;

type
  TedQuest = class(TEditForm, IEditDialog<TQuest>)
    edQuestName: TEdit;
    paTop: TPanel;
    paMain: TPanel;
  private
    FQuest: TQuest;
    FPointList: TfrPointList;

    function GetQuestName: string;
    procedure SetQuestName(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetInstance(const Value: TQuest);
    procedure PostValues(const Value: TQuest);

    property QuestName: string read GetQuestName write SetQuestName;
  end;

implementation

{$R *.fmx}

{ TedQuest }

constructor TedQuest.Create(AOwner: TComponent);
begin
  inherited;

  FQuest := nil;
  FPointList := TfrPointList.Create(Self);
  FPointList.Parent := paMain;
  FPointList.Align := TAlignLayout.Client;
end;

destructor TedQuest.Destroy;
begin

  inherited;
end;

function TedQuest.GetQuestName: string;
begin
  Result := edQuestName.Text;
end;

procedure TedQuest.SetQuestName(const Value: string);
begin
  edQuestName.Text := Value;
end;

procedure TedQuest.SetInstance(const Value: TQuest);
begin
  FQuest := Value;

  if FQuest.IsNewInstance then
    Caption := 'Добавление нового квеста'
  else
    Caption := '#' + VarToStr(FQuest.ID) + ' Редактирование квеста';

  QuestName := FQuest.Name;
  FPointList.Init(FQuest);
end;

procedure TedQuest.PostValues(const Value: TQuest);
begin
  Value.Name := QuestName;
end;

end.
