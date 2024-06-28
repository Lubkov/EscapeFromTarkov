unit ME.Del.Form.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.UITypes, FMX.Controls,
  FMX.Forms, ME.Dialog.Presenter;

type
  TDelFormPresenter<T> = class(TDialogPresenter)
  private
    FInstance: T;
  protected
    procedure SetInstance(const Value: T); virtual;
    procedure InternalDelete; virtual; abstract;
    function GetDelMessage: string; virtual; abstract;
  public
    constructor Create(Dialog: IMessageDialog; Instance: T); reintroduce; overload; virtual;

    function Delete: Boolean;

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TDelFormPresenter<T> }

constructor TDelFormPresenter<T>.Create(Dialog: IMessageDialog; Instance: T);
begin
  inherited Create(Dialog);

  Self.Instance := Instance;
end;

procedure TDelFormPresenter<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

function TDelFormPresenter<T>.Delete: Boolean;
//var
//  ErrorText: string;
begin
  IMessageDialog(FEditDialog).SetMessage(GetDelMessage);
   Result := FEditDialog.ShowModal = mrOK;
  if not Result then begin
//    Cancel;
    Exit;
  end;

//  if not Validate(ErrorText) then
//  begin
//    if Assigned(OnError) then
//      OnError(ErrorText);
//
//    FEditDialog.SetModalResult(mrNone);
//    Exit;
//  end;

  InternalDelete;
end;

end.
