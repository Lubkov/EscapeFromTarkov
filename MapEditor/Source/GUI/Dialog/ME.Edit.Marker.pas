unit ME.Edit.Marker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, System.Actions, FMX.ActnList, FMX.Controls.Presentation,
  ME.DB.Marker, FMX.Edit, FMX.ListBox, FMX.EditBox, FMX.NumberBox,
  ME.Edit.Form.Presenter;

type
  TedMarker = class(TEditForm, IEditDialog<TMarker>)
    edMarkerName: TEdit;
    edPositionX: TNumberBox;
    edPositionY: TNumberBox;
    laTopPoint: TLabel;
    edKindName: TComboBox;
  private
    FMarker: TMarker;

    function GetMarkerName: string;
    procedure SetMarkerName(const Value: string);
    function GetMarkerKind: TMarkerKind;
    procedure SetMarkerKind(const Value: TMarkerKind);
    function GetPositionX: Integer;
    procedure SetPositionX(const Value: Integer);
    function GetPositionY: Integer;
    procedure SetPositionY(const Value: Integer);
  protected
    function GetTitle(const Value: TMarker): string; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetInstance(const Value: TMarker);
    procedure PostValues(const Value: TMarker);

    property MarkerName: string read GetMarkerName write SetMarkerName;
    property MarkerKind: TMarkerKind read GetMarkerKind write SetMarkerKind;
    property PositionX: Integer read GetPositionX write SetPositionX;
    property PositionY: Integer read GetPositionY write SetPositionY;
  end;

implementation

{$R *.fmx}

{ TedMarker }

constructor TedMarker.Create(AOwner: TComponent);
var
  Kind: TMarkerKind;
begin
  inherited;

  edKindName.Clear;
  for Kind := tkPMCExtraction to tkCoopExtraction do
    edKindName.Items.Add(TMarker.KindToStr(Kind));
end;

destructor TedMarker.Destroy;
begin

  inherited;
end;

function TedMarker.GetMarkerName: string;
begin
  Result := edMarkerName.Text;
end;

procedure TedMarker.SetMarkerName(const Value: string);
begin
  edMarkerName.Text := Value;
end;

function TedMarker.GetMarkerKind: TMarkerKind;
begin
  Result := TMarkerKind(edKindName.ItemIndex);
end;

procedure TedMarker.SetMarkerKind(const Value: TMarkerKind);
begin
  edKindName.ItemIndex := Ord(Value);
end;

function TedMarker.GetPositionX: Integer;
begin
  Result := Trunc(edPositionX.Value);
end;

procedure TedMarker.SetPositionX(const Value: Integer);
begin
  edPositionX.Value := Value;
end;

function TedMarker.GetPositionY: Integer;
begin
  Result := Trunc(edPositionY.Value);
end;

procedure TedMarker.SetPositionY(const Value: Integer);
begin
  edPositionY.Value := Value;
end;

function TedMarker.GetTitle(const Value: TMarker): string;
begin
  if Value.IsNewInstance then
    Result := 'Добавление нового выхода с карты'
  else
    Result := '#' + VarToStr(Value.ID) + ' Редактирование выхода с карты';
end;

procedure TedMarker.SetInstance(const Value: TMarker);
begin
  FMarker := Value;

  Caption := GetTitle(Value);
  MarkerName := FMarker.Name;
  MarkerKind := FMarker.Kind;
  PositionX := FMarker.Left;
  PositionY := FMarker.Top;
end;

procedure TedMarker.PostValues(const Value: TMarker);
begin
  Value.Name := MarkerName;
  Value.Kind := MarkerKind;
  Value.Left := PositionX;
  Value.Top := PositionY;
end;

end.
