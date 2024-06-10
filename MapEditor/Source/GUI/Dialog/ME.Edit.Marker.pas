﻿
unit ME.Edit.Marker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, System.Actions, FMX.ActnList, FMX.Controls.Presentation,
  ME.DB.Marker, FMX.Edit, FMX.ListBox, FMX.EditBox, FMX.NumberBox,
  ME.Edit.Form.Presenter, ME.DB.Map, FMX.Layouts, System.ImageList, FMX.ImgList,
  FMX.Platform;

type
  TedMarker = class(TEditForm, IEditDialog<TMarker>)
    edMarkerName: TEdit;
    edPositionX: TNumberBox;
    edPositionY: TNumberBox;
    edKindName: TComboBox;
    laMarkerName: TLabel;
    laKindName: TLabel;
    PositionLayout: TLayout;
    laTopPoint: TLabel;
    Layout2: TLayout;
    laMapWidth: TLabel;
    laMapHeight: TLabel;
    Layout3: TLayout;
    Layout1: TLayout;
    Layout4: TLayout;
    HorizontalLayout: TLayout;
    edLeft: TSpeedButton;
    buRight: TSpeedButton;
    VerticalLayout: TLayout;
    buTop: TSpeedButton;
    buBottom: TSpeedButton;
    ImageList24: TImageList;
    edIncrement: TNumberBox;
    buGenerate: TButton;
    laScreenShotName: TLabel;
    procedure edLeftClick(Sender: TObject);
    procedure buRightClick(Sender: TObject);
    procedure buTopClick(Sender: TObject);
    procedure buBottomClick(Sender: TObject);
    procedure buGenerateClick(Sender: TObject);
  private
    FMap: TMap;
    FMarker: TMarker;

    function GetMarkerName: string;
    procedure SetMarkerName(const Value: string);
    function GetMarkerKind: TMarkerKind;
    procedure SetMarkerKind(const Value: TMarkerKind);
    function GetPositionX: Integer;
    procedure SetPositionX(const Value: Integer);
    function GetPositionY: Integer;
    procedure SetPositionY(const Value: Integer);
    procedure SetMap(const Value: TMap);
    function GetIncrement: Integer;
    procedure SetIncrement(const Value: Integer);
  protected
    function GetTitle(const Value: TMarker): string; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetInstance(const Value: TMarker);
    procedure PostValues(const Value: TMarker);

    property Map: TMap read FMap write SetMap;
    property MarkerName: string read GetMarkerName write SetMarkerName;
    property MarkerKind: TMarkerKind read GetMarkerKind write SetMarkerKind;
    property PositionX: Integer read GetPositionX write SetPositionX;
    property PositionY: Integer read GetPositionY write SetPositionY;
    property Increment: Integer read GetIncrement write SetIncrement;
  end;

implementation

{$R *.fmx}

{ TedMarker }

constructor TedMarker.Create(AOwner: TComponent);
var
  Kind: TMarkerKind;
begin
  inherited;

  FMap := nil;
  edKindName.Clear;
  for Kind := TMarkerKind.PMCExtraction to TMarkerKind.CoopExtraction do
    edKindName.Items.Add(TMarker.KindToStr(Kind));

  laScreenShotName.Visible := False;
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

procedure TedMarker.SetMap(const Value: TMap);
begin
  FMap := Value;

  if Map = nil then
    Exit;

  laMapWidth.Text := 'Ширина карты: (' + IntToStr(Map.Left) + ', ' + IntToStr(Map.Right) + ')';
  laMapHeight.Text := 'Высота карты: (' + IntToStr(Map.Top) + ', ' + IntToStr(Map.Bottom) + ')';
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

function TedMarker.GetIncrement: Integer;
begin
  Result := Trunc(edIncrement.Value);
end;

procedure TedMarker.SetIncrement(const Value: Integer);
begin
  edIncrement.Value := Value;
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

procedure TedMarker.edLeftClick(Sender: TObject);
begin
  if Map.Left < Map.Right then
    PositionX := PositionX - Increment
  else
    PositionX := PositionX + Increment;
end;

procedure TedMarker.buRightClick(Sender: TObject);
begin
  if Map.Left < Map.Right then
    PositionX := PositionX + Increment
  else
    PositionX := PositionX - Increment;
end;

procedure TedMarker.buTopClick(Sender: TObject);
begin
  if Map.Top < Map.Bottom then
    PositionY := PositionY - Increment
  else
    PositionY := PositionY + Increment;
end;

procedure TedMarker.buBottomClick(Sender: TObject);
begin
  if Map.Top < Map.Bottom then
    PositionY := PositionY + Increment
  else
    PositionY := PositionY - Increment;
end;

procedure TedMarker.buGenerateClick(Sender: TObject);
const
//  FileNameFmt = '2024-02-20[21-57]_X.x, 0.0, Y.y_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FileNameFmt = '%s_%d.0, 0.0, %d.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
var
  x, y: Integer;
  FileName: string;
  clp: IFMXClipboardService;
begin
  x := Trunc(edPositionX.Value);
  y := Trunc(edPositionY.Value);
  FileName := Format(FileNameFmt, [FormatDateTime('yyyy-mm-dd[hh-nn]', Now), x, y]);
  laScreenShotName.Text := FileName;
  laScreenShotName.Visible := True;

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService) then begin
    clp := IFMXClipboardService(TPlatformServices.Current.GetPlatformService(IFMXClipboardService));
    clp.SetClipboard(FileName);
  end;
end;

end.
