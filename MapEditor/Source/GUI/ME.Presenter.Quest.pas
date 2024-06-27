unit ME.Presenter.Quest;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditQuestPresenter = class(TEditFormPresenter<TQuest>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelQuestPresenter = class(TDelFormPresenter<TQuest>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  ME.DB.Utils;

{ TEditQuestPresenter }

procedure TEditQuestPresenter.InternalSave;
begin
  inherited;

//  if not IsNullID(Instance.MapID) then begin
//    QuestService.Save(Instance);
//  end;
end;

procedure TEditQuestPresenter.Cancel;
begin
  inherited;

end;

{ TDelQuestPresenter }

function TDelQuestPresenter.GetDelMessage: string;
begin
  Result := 'Удалить квест "' + Instance.Caption + '"?';
end;

procedure TDelQuestPresenter.InternalDelete;
begin
//  QuestService.Remove(Instance);
end;

end.
