unit ME.Presenter.Resource;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditResourcePresenter = class(TEditFormPresenter<TResource>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelResourcePresenter = class(TDelFormPresenter<TResource>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  Map.Data.Service;

{ TEditResourcePresenter }

procedure TEditResourcePresenter.InternalSave;
begin
  inherited;

  if Instance.IsNewInstance then
    Instance.GenerateNewID;
end;

procedure TEditResourcePresenter.Cancel;
begin
  inherited;

end;

{ TDelResourcePresenter }

function TDelResourcePresenter.GetDelMessage: string;
begin
  Result := 'Удалить скриншот маркера?';
end;

procedure TDelResourcePresenter.InternalDelete;
begin
  DataSertvice.DeleteImage(Instance);
end;

end.

