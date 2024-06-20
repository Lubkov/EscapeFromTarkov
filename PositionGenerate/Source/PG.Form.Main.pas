unit PG.Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Data.DB, MemDS, DBAccess, Uni,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.ListBox, Datasnap.DBClient, FMX.Objects,
  FMX.Clipboard, FMX.Platform, FMX.Layouts, System.ImageList, FMX.ImgList;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    edMapName: TComboBox;
    buGenerate: TButton;
    Label1: TLabel;
    edMapLeft: TNumberBox;
    edMapRight: TNumberBox;
    Label2: TLabel;
    edMapTop: TNumberBox;
    edMapBottom: TNumberBox;
    Line1: TLine;
    laScreenShotName: TLabel;
    ImageList24: TImageList;
    Layout1: TLayout;
    Layout2: TLayout;
    PositionLayout: TLayout;
    Label3: TLabel;
    Layout4: TLayout;
    edPositionX: TNumberBox;
    edPositionY: TNumberBox;
    Layout5: TLayout;
    Layout6: TLayout;
    buTop: TSpeedButton;
    buBottom: TSpeedButton;
    Layout7: TLayout;
    edLeft: TSpeedButton;
    buRight: TSpeedButton;
    edIncrement: TComboBox;
    Button1: TButton;
    laKindName: TLabel;
    edKindName: TComboBox;
    procedure buGenerateClick(Sender: TObject);
    procedure edLeftClick(Sender: TObject);
    procedure edMapNameChange(Sender: TObject);
    procedure buRightClick(Sender: TObject);
    procedure buTopClick(Sender: TObject);
    procedure buBottomClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure Init;
    function GetMapBottom: Integer;
    function GetMapLeft: Integer;
    function GetMapRight: Integer;
    function GetMapTop: Integer;
    function GetIncrement: Integer;
    function GetPositionX: Integer;
    function GetPositionY: Integer;
    procedure SetPositionX(const Value: Integer);
    procedure SetPositionY(const Value: Integer);
    procedure SaveToClipboard(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property MapLeft: Integer read GetMapLeft;
    property MapTop: Integer read GetMapTop;
    property MapRight: Integer read GetMapRight;
    property MapBottom: Integer read GetMapBottom;
    property PositionX: Integer read GetPositionX write SetPositionX;
    property PositionY: Integer read GetPositionY write SetPositionY;
    property Increment: Integer read GetIncrement;
  end;

var
  MainForm: TMainForm;

implementation

uses
  PG.Service;

{$R *.fmx}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Init;
  laScreenShotName.Visible := False;
end;

destructor TMainForm.Destroy;
begin

  inherited;
end;

function TMainForm.GetMapLeft: Integer;
begin
  if edMapName.ItemIndex >= 0 then
    Result := PositionService.Items[edMapName.ItemIndex].Left
  else
    Result := 9999;
end;

function TMainForm.GetMapTop: Integer;
begin
  if edMapName.ItemIndex >= 0 then
    Result := PositionService.Items[edMapName.ItemIndex].Top
  else
    Result := -9999;
end;

function TMainForm.GetMapRight: Integer;
begin
  if edMapName.ItemIndex >= 0 then
    Result := PositionService.Items[edMapName.ItemIndex].Right
  else
    Result := -9999;
end;

function TMainForm.GetMapBottom: Integer;
begin
  if edMapName.ItemIndex >= 0 then
    Result := PositionService.Items[edMapName.ItemIndex].Bottom
  else
    Result := 9999;
end;

function TMainForm.GetPositionX: Integer;
begin
  Result := Trunc(edPositionX.Value);
end;

procedure TMainForm.SetPositionX(const Value: Integer);
begin
  edPositionX.Value := Value;
end;

function TMainForm.GetPositionY: Integer;
begin
  Result := Trunc(edPositionY.Value);
end;

procedure TMainForm.SetPositionY(const Value: Integer);
begin
  edPositionY.Value := Value;
end;

function TMainForm.GetIncrement: Integer;
begin
  Result := StrToInt(edIncrement.Items[edIncrement.ItemIndex]);
end;

procedure TMainForm.edLeftClick(Sender: TObject);
begin
  if MapLeft < MapRight then
    PositionX := PositionX - Increment
  else
    PositionX := PositionX + Increment;
end;

procedure TMainForm.buRightClick(Sender: TObject);
begin
  if MapLeft < MapRight then
    PositionX := PositionX + Increment
  else
    PositionX := PositionX - Increment;
end;

procedure TMainForm.buTopClick(Sender: TObject);
begin
  if MapTop < MapBottom then
    PositionY := PositionY - Increment
  else
    PositionY := PositionY + Increment;
end;

procedure TMainForm.buBottomClick(Sender: TObject);
begin
  if MapTop < MapBottom then
    PositionY := PositionY + Increment
  else
    PositionY := PositionY - Increment;
end;

procedure TMainForm.Init;
var
  i: Integer;
  Kind: TMarkerKind;
begin
  PositionService.LoadParams;
  PositionService.LoadDataFromJSON;

  for i := 0 to PositionService.Count - 1 do
    edMapName.Items.Add(PositionService.Items[i].Name);

  for Kind := Low(TMarkerKind) to High(TMarkerKind) do
    edKindName.Items.Add(PositionService.KindToStr(Kind));

  edKindName.ItemIndex := 0;
end;

procedure TMainForm.edMapNameChange(Sender: TObject);
begin
  edMapLeft.Value := MapLeft;
  edMapTop.Value := MapTop;
  edMapRight.Value := MapRight;
  edMapBottom.Value := MapBottom;

//  laMapWidth.Text := 'Ширина карты: (' + IntToStr(MapLeft) + ', ' + IntToStr(MapRight) + ')';
//  laMapHeight.Text := 'Высота карты: (' + IntToStr(MapTop) + ', ' + IntToStr(MapBottom) + ')';

  if MapLeft < MapRight then begin
    edPositionX.Min := MapLeft;
    edPositionX.Max := MapRight;
  end
  else begin
    edPositionX.Min := MapRight;
    edPositionX.Max := MapLeft;
  end;
end;

procedure TMainForm.SaveToClipboard(const Value: string);
var
  clp: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService) then begin
    clp := IFMXClipboardService(TPlatformServices.Current.GetPlatformService(IFMXClipboardService));
    clp.SetClipboard(Value);
  end;
end;

procedure TMainForm.buGenerateClick(Sender: TObject);
const
//  FileNameFmt = '2024-02-20[21-57]_X.x, 0.0, Y.y_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FileNameFmt = '%s_%d.0, 0.0, %d.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
var
  x, y: Integer;
  FileName: string;
begin
  x := Trunc(edPositionX.Value);
  y := Trunc(edPositionY.Value);
  FileName := Format(FileNameFmt, [FormatDateTime('yyyy-mm-dd[hh-nn]', Now), x, y]);
  laScreenShotName.Text := FileName;
  laScreenShotName.Visible := True;

  SaveToClipboard(FileName);
end;

procedure TMainForm.Button1Click(Sender: TObject);
const
  MarkerItemFmt = '{"name": "%s", "kind": "%s", "left": "%d", "top": "%d"}';
var
  Kind: TMarkerKind;
  MarkerName: string;
  MarkerKind: string;
  Marker: string;
begin
  Kind := TMarkerKind(edKindName.ItemIndex);
  MarkerName := '';
  MarkerKind := TRttiEnumerationType.GetName<TMarkerKind>(Kind);
  Marker := Format(MarkerItemFmt, [MarkerName, MarkerKind, PositionX, PositionY]);

  laScreenShotName.Text := Marker;
  laScreenShotName.Visible := True;
  SaveToClipboard(Marker);
end;

end.
