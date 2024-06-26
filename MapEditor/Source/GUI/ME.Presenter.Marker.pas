unit ME.Presenter.Marker;

interface

uses
  System.SysUtils, System.Variants, System.Classes, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditMarkerPresenter = class(TEditFormPresenter<TMarker>)
  private
  protected
    procedure InternalSave; override;
    procedure Cancel; override;
  public
  end;

  TDelMarkerPresenter = class(TDelFormPresenter<TMarker>)
  protected
    function GetDelMessage: string; override;
    procedure InternalDelete; override;
  end;

implementation

uses
  ME.DB.Utils;

{ TEditMarkerPresenter }

procedure TEditMarkerPresenter.InternalSave;
begin
//  if not IsNullID(Instance.MapID) then begin
//    MarkerService.Save(Instance);
//  end;
end;

procedure TEditMarkerPresenter.Cancel;
begin
  inherited;

end;

{ TDelMarkerPresenter }

function TDelMarkerPresenter.GetDelMessage: string;
begin
  Result := 'Удалить маркер "' + Instance.Name + '"?';
end;

procedure TDelMarkerPresenter.InternalDelete;
begin
//  MarkerService.Remove(Instance);
end;

end.
