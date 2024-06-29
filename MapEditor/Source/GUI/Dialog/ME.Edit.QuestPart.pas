unit ME.Edit.QuestPart;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Marker, System.Actions, FMX.ActnList, FMX.ListBox, FMX.EditBox,
  FMX.NumberBox, FMX.Edit, FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FMX.Layouts, Map.Data.Types, FMX.TabControl, ME.Frame.QuestItem;

type
  TedQuestPart = class(TedMarker)
    tabQuestItems: TTabItem;
  private
    FQuestItemsGrid: TQuestItemsGrid;
  protected
    function GetTitle(const Value: TMarker): string; override;
    procedure InternalSetInstance(const Value: TMarker); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TedQuestPart }

constructor TedQuestPart.Create(AOwner: TComponent);
begin
  inherited;

  FQuestItemsGrid := TQuestItemsGrid.Create(Self);
  FQuestItemsGrid.Name := 'QuestItemsGrid';
  FQuestItemsGrid.Parent := tabQuestItems;
  FQuestItemsGrid.Align := TAlignLayout.Client;

  MarkerKind := TMarkerKind.Quest;
  edKindName.Visible := False;
end;

function TedQuestPart.GetTitle(const Value: TMarker): string;
begin
  if Value.IsNewInstance then
    Result := 'Добавление новой подзадачи квеста'
  else
    Result := 'Редактирование подзадачи квеста';
end;

procedure TedQuestPart.InternalSetInstance(const Value: TMarker);
begin
  inherited;

  FQuestItemsGrid.Init(Marker);
end;

end.
