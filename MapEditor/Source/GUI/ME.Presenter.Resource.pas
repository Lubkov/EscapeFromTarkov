unit ME.Presenter.Resource;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.IOUtils, FMX.Controls,
  ME.Edit.Form.Presenter, ME.Del.Form.Presenter,
  Map.Data.Types;

type
  TEditResourcePresenter = class(TEditFormPresenter<TResource>)
  private
  protected
    procedure SetInstance(const Value: TResource); override;
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
  App.Constants, Map.Data.Service;

{ TEditResourcePresenter }

procedure TEditResourcePresenter.InternalSave;
const
  QuestItemsFolder = 'Items';
var
  Folder: string;
  FileName: string;
begin
  inherited;

  if Instance.IsNewInstance then
    Instance.GenerateNewID;

  if Instance.Changed then begin
    Folder := TPath.Combine(AppParams.DataPath, QuestItemsFolder);
    if CompareText(Folder, TPath.GetDirectoryName(Instance.FileName)) = 0 then begin
      FileName := TPath.GetFileNameWithoutExtension(Instance.FileName);
      Instance.ID := FileName;
      Instance.Changed := False;
    end
    else
      DataService.SaveImage(Instance, Instance.Picture);
  end;
end;

procedure TEditResourcePresenter.SetInstance(const Value: TResource);
begin
  if not Value.IsNewInstance and Value.Picture.IsEmpty then
    DataService.LoadImage(Value, Value.Picture);

  inherited;
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
//  DataService.DeleteImage(Instance);
end;

end.

