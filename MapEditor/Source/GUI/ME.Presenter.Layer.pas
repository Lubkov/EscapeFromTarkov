unit ME.Presenter.Layer;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditLayerPresenter = class(TEditFormPresenter<TLayer>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelLayerPresenter = class(TDelFormPresenter<TLayer>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  Map.Data.Service;

{ TEditLayerPresenter }

procedure TEditLayerPresenter.InternalSave;
begin
  inherited;

end;

procedure TEditLayerPresenter.Cancel;
begin
  inherited;

end;

{ TDelLayerPresenter }

function TDelLayerPresenter.GetDelMessage: string;
begin
  Result := 'Удалить уровень карты?';
end;

procedure TDelLayerPresenter.InternalDelete;
begin
  DataService.DeleteImage(Instance);
end;

end.

