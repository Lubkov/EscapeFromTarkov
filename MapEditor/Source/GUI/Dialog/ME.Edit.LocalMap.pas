unit ME.Edit.LocalMap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, FMX.EditBox, FMX.NumberBox, FMX.Edit, System.Actions,
  FMX.Controls.Presentation, FMX.ActnList,
  ME.LocalMap, ME.Dialog.Presenter, ME.Edit.Form.Presenter;

type
  TedLocalMap = class(TEditForm, IEditDialog<TLocalMap>)
    edMapName: TEdit;
    edLeft: TNumberBox;
    edTop: TNumberBox;
    edBottom: TNumberBox;
    edRight: TNumberBox;
  private
    FLocalMap: TLocalMap;

    function GetMapName: string;
    procedure SetMapName(const Value: string);
    function GetMapLeft: Integer;
    procedure SetMapLeft(const Value: Integer);
    function GetMapTop: Integer;
    procedure SetMapTop(const Value: Integer);
    function GetMapRight: Integer;
    procedure SetMapRight(const Value: Integer);
    function GetMapBottom: Integer;
    procedure SetMapBottom(const Value: Integer);
  public
    procedure SetInstance(const Value: TLocalMap);
    procedure PostValues(const Value: TLocalMap);

    property MapName: string read GetMapName write SetMapName;
    property MapLeft: Integer read GetMapLeft write SetMapLeft;
    property MapTop: Integer read GetMapTop write SetMapTop;
    property MapRight: Integer read GetMapRight write SetMapRight;
    property MapBottom: Integer read GetMapBottom write SetMapBottom;
  end;

implementation

{$R *.fmx}

function TedLocalMap.GetMapName: string;
begin
  Result := edMapName.Text;
end;

procedure TedLocalMap.SetMapName(const Value: string);
begin
  edMapName.Text := Value;
end;

function TedLocalMap.GetMapLeft: Integer;
begin
  Result := Trunc(edLeft.Value);
end;

procedure TedLocalMap.SetMapLeft(const Value: Integer);
begin
  edLeft.Value := Value;
end;

function TedLocalMap.GetMapTop: Integer;
begin
  Result := Trunc(edTop.Value);
end;

procedure TedLocalMap.SetMapTop(const Value: Integer);
begin
  edTop.Value := Value;
end;

function TedLocalMap.GetMapRight: Integer;
begin
  Result := Trunc(edRight.Value);
end;

procedure TedLocalMap.SetMapRight(const Value: Integer);
begin
  edRight.Value := Value;
end;

function TedLocalMap.GetMapBottom: Integer;
begin
  Result := Trunc(edBottom.Value);
end;

procedure TedLocalMap.SetMapBottom(const Value: Integer);
begin
  edBottom.Value := Value;
end;

procedure TedLocalMap.SetInstance(const Value: TLocalMap);
begin
  FLocalMap := Value;

  if FLocalMap.IsNewInstance then
    Caption := '�������� ����� �����'
  else
    Caption := '#' + VarToStr(FLocalMap.ID) + '  �������������� ����� "' + FLocalMap.Name + '"';

  MapName := FLocalMap.Name;
  MapLeft := FLocalMap.Left.X;
  MapTop := FLocalMap.Left.Y;
  MapRight := FLocalMap.Right.X;
  MapBottom := FLocalMap.Right.Y;
end;

procedure TedLocalMap.PostValues(const Value: TLocalMap);
begin
  Value.Name := MapName;
  FLocalMap.Left.SetBounds(MapLeft, MapTop);
  FLocalMap.Right.SetBounds(MapRight, MapBottom);
end;

end.
