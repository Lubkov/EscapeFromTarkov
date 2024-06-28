unit ME.Presenter.QuestItem;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Del.Form.Presenter, Map.Data.Types;

type
  TDelQuestItemPresenter = class(TDelFormPresenter<TQuestItem>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  Map.Data.Service;

{ TDelQuestItemPresenter }

function TDelQuestItemPresenter.GetDelMessage: string;
begin
  Result := 'Удалить изображение предмета задания?';
end;

procedure TDelQuestItemPresenter.InternalDelete;
begin
  DataSertvice.DeleteImage(Instance);
end;

end.
