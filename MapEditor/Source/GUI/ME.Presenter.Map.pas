unit ME.Presenter.Map;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter, Map.Data.Types;

type
  TEditMapPresenter = class(TEditFormPresenter<TMap>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelMapPresenter = class(TDelFormPresenter<TMap>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  ME.Service.Map;

{ TEditMapPresenter }

procedure TEditMapPresenter.InternalSave;
begin
  inherited;

//  MapService.Save(Instance);
end;

procedure TEditMapPresenter.Cancel;
begin
  inherited;

end;

{ TDelMapPresenter }

function TDelMapPresenter.GetDelMessage: string;
begin
//  Result := 'Удалить карту "' + Instance.Name + '"?';
end;

procedure TDelMapPresenter.InternalDelete;
begin
//  MapService.Remove(Instance);
end;

end.

