unit ME.Presenter.QuestPart;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditQuestPartPresenter = class(TEditFormPresenter<TMarker>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelQuestPartPresenter = class(TDelFormPresenter<TMarker>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  ME.DB.Utils;

{ TEditQuestPartPresenter }

procedure TEditQuestPartPresenter.InternalSave;
begin
//  if not (IsNullID(Instance.MapID) or IsNullID(Instance.QuestID)) then
//    MarkerService.Save(Instance);
end;

procedure TEditQuestPartPresenter.Cancel;
begin
  inherited;

end;

{ TDelQuestPartPresenter }

function TDelQuestPartPresenter.GetDelMessage: string;
begin
  Result := 'Удалить подзадачу квеста?';
end;

procedure TDelQuestPartPresenter.InternalDelete;
begin
//  MarkerService.Remove(Instance);
end;

end.
