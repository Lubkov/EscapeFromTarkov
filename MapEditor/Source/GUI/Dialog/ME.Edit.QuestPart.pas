unit ME.Edit.QuestPart;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Marker, System.Actions, FMX.ActnList, FMX.ListBox, FMX.EditBox,
  FMX.NumberBox, FMX.Edit, FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FMX.Layouts, Map.Data.Types;

type
  TedQuestPart = class(TedMarker)
  private
  protected
    function GetTitle(const Value: TMarker): string; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TedQuestPart }

constructor TedQuestPart.Create(AOwner: TComponent);
begin
  inherited;

  MarkerKind := TMarkerKind.Quest;
  edKindName.Visible := False;
//  laTopPoint.Position.Y := 70;
//  edPositionX.Position.Y := 95;
//  edPositionY.Position.Y := 95;
  Self.Height := 325;
end;

function TedQuestPart.GetTitle(const Value: TMarker): string;
begin
//  if Value.IsNewInstance then
//    Result := 'Добавление новой подзадачи квеста'
//  else
    Result := {'#' + VarToStr(Value.ID) +} ' Редактирование подзадачи квеста';
end;

end.
