unit ME.Edit.Form.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.UITypes, FMX.Controls,
  FMX.Forms, ME.Dialog.Presenter;

type
  IEditDialog<T> = interface(ICLDialog)
    ['{7B740715-319C-4285-84FE-D16EF81F7B40}']

    procedure SetInstance(const Value: T);
    procedure PostValues(const Value: T);
  end;

  TEditFormPresenter<T> = class(TDialogPresenter)
  private
    FInstance: T;
//    FParams: array of TVarRec;
  protected
    procedure SetInstance(const Value: T); virtual;
    procedure PostValues; virtual;
    procedure InternalSave; virtual; abstract;
    procedure Cancel; virtual; abstract;
    function Validate(var vMessage: string): Boolean; virtual;
  public
    constructor Create(Dialog: IEditDialog<T>; Instance: T); reintroduce; overload; virtual;

    function Edit: Boolean;
//    procedure SetParams(const Params: array of const);

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TEditFormPresenter<T> }

constructor TEditFormPresenter<T>.Create(Dialog: IEditDialog<T>; Instance: T);
begin
  inherited Create(Dialog);

  Self.Instance := Instance;
end;

procedure TEditFormPresenter<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
  IEditDialog<T>(FEditDialog).SetInstance(Value);
end;

procedure TEditFormPresenter<T>.PostValues;
begin
  IEditDialog<T>(FEditDialog).PostValues(FInstance);
end;

function TEditFormPresenter<T>.Validate(var vMessage: string): Boolean;
begin
  Result := True;
  vMessage := '';
end;

function TEditFormPresenter<T>.Edit: Boolean;
var
  ErrorText: string;
begin
  Result := ShowModal;
  if not Result then begin
    Cancel;
    Exit;
  end;

  if not Validate(ErrorText) then
  begin
    if Assigned(OnError) then
      OnError(ErrorText);

    FEditDialog.SetModalResult(mrNone);
    Exit;
  end;

  PostValues;
  InternalSave;
end;

end.
