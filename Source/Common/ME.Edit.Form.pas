unit ME.Edit.Form;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Actions, FMX.ActnList,
  ME.Dialog.Presenter;

type
  TEditForm = class(TForm, ICLDialog)
    ActionList1: TActionList;
    acSuccess: TAction;
    acCancel: TAction;
    paBottom: TPanel;
    buSuccess: TButton;
    buCancel: TButton;
    paButtons: TPanel;

    procedure acSuccessExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
  private
  public
    function GetModalResult: TModalResult;
    procedure SetModalResult(Value: TModalResult);
  end;

implementation

{$R *.fmx}

procedure TEditForm.acSuccessExecute(Sender: TObject);
begin
// For action enabled
end;

procedure TEditForm.acCancelExecute(Sender: TObject);
begin
  Close;
end;

function TEditForm.GetModalResult: TModalResult;
begin
  Result := ModalResult;
end;

procedure TEditForm.SetModalResult(Value: TModalResult);
begin
  ModalResult := Value;
end;

end.
