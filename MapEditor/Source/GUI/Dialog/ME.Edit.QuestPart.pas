unit ME.Edit.QuestPart;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Marker, System.Actions, FMX.ActnList, FMX.ListBox, FMX.EditBox,
  FMX.NumberBox, FMX.Edit, FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FMX.Layouts, Map.Data.Types, FMX.TabControl, ME.Frame.MarkerImage;

type
  TedQuestPart = class(TedMarker)
    tabQuestItems: TTabItem;
  private
    FMarkerImagesGrid: TMarkerImagesGrid;
  protected
    function GetTitle(const Value: TMarker): string; override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetInstance(const Value: TMarker);
  end;

implementation

{$R *.fmx}

{ TedQuestPart }

constructor TedQuestPart.Create(AOwner: TComponent);
begin
  inherited;

  FMarkerImagesGrid := TMarkerImagesGrid.Create(Self);
  FMarkerImagesGrid.Parent := tabMarkerImages;
  FMarkerImagesGrid.Align := TAlignLayout.Client;

  MarkerKind := TMarkerKind.Quest;
  edKindName.Visible := False;
end;

function TedQuestPart.GetTitle(const Value: TMarker): string;
begin
//  if Value.IsNewInstance then
//    Result := 'Добавление новой подзадачи квеста'
//  else
    Result := {'#' + VarToStr(Value.ID) +} ' Редактирование подзадачи квеста';
end;

procedure TedQuestPart.SetInstance(const Value: TMarker);
begin
  FMarkerImagesGrid.Init(Marker);
end;

end.
