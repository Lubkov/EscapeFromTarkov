unit ME.Edit.Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, FMX.EditBox, FMX.NumberBox, FMX.Edit, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, ME.DB.Map, ME.Dialog.Presenter, ME.Edit.Form.Presenter,
  ME.Frame.Picture, ME.Frame.Layer, FMX.TabControl, ME.Frame.Marker,
  ME.Frame.Quest;

type
  TedMap = class(TEditForm, IEditDialog<TMap>)
    edMapName: TEdit;
    edLeft: TNumberBox;
    edTop: TNumberBox;
    edBottom: TNumberBox;
    edRight: TNumberBox;
    paPicture: TPanel;
    laMapName: TLabel;
    laTopPoint: TLabel;
    laBottomPoint: TLabel;
    MainContainer: TTabControl;
    tabGeneral: TTabItem;
    tabLayer: TTabItem;
    tabExtractions: TTabItem;
    tabQuests: TTabItem;
  private
    FMap: TMap;
    FPicturePanel: TfrPicture;
    FLayerList: TfrLayerList;
    FMarkerGrid: TfrMarkerGrid;
    FQuestList: TfrQuest;

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
    function GetPicture: TBitmap;
    procedure SetPicture(const Value: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetInstance(const Value: TMap);
    procedure PostValues(const Value: TMap);

    property MapName: string read GetMapName write SetMapName;
    property MapLeft: Integer read GetMapLeft write SetMapLeft;
    property MapTop: Integer read GetMapTop write SetMapTop;
    property MapRight: Integer read GetMapRight write SetMapRight;
    property MapBottom: Integer read GetMapBottom write SetMapBottom;
    property Picture: TBitmap read GetPicture write SetPicture;
  end;

implementation

{$R *.fmx}

constructor TedMap.Create(AOwner: TComponent);
begin
  inherited;

  MainContainer.TabIndex := tabGeneral.Index;

  FPicturePanel := TfrPicture.Create(Self);
  FPicturePanel.Parent := paPicture;
  FPicturePanel.Align := TAlignLayout.Client;
  FPicturePanel.Title := 'Изображени карты ' + #13#10 + '(для меню)';

  FLayerList := TfrLayerList.Create(Self);
  FLayerList.Parent := tabLayer;
  FLayerList.Align := TAlignLayout.Client;

  FMarkerGrid := TfrMarkerGrid.Create(Self);
  FMarkerGrid.Parent := tabExtractions;
  FMarkerGrid.Align := TAlignLayout.Client;

  FQuestList := TfrQuest.Create(Self);
  FQuestList.Parent := tabQuests;
  FQuestList.Align := TAlignLayout.Client;
end;

function TedMap.GetMapName: string;
begin
  Result := edMapName.Text;
end;

procedure TedMap.SetMapName(const Value: string);
begin
  edMapName.Text := Value;
end;

function TedMap.GetMapLeft: Integer;
begin
  Result := Trunc(edLeft.Value);
end;

procedure TedMap.SetMapLeft(const Value: Integer);
begin
  edLeft.Value := Value;
end;

function TedMap.GetMapTop: Integer;
begin
  Result := Trunc(edTop.Value);
end;

procedure TedMap.SetMapTop(const Value: Integer);
begin
  edTop.Value := Value;
end;

function TedMap.GetMapRight: Integer;
begin
  Result := Trunc(edRight.Value);
end;

procedure TedMap.SetMapRight(const Value: Integer);
begin
  edRight.Value := Value;
end;

function TedMap.GetMapBottom: Integer;
begin
  Result := Trunc(edBottom.Value);
end;

procedure TedMap.SetMapBottom(const Value: Integer);
begin
  edBottom.Value := Value;
end;

function TedMap.GetPicture: TBitmap;
begin
  Result := FPicturePanel.Picture;
end;

procedure TedMap.SetPicture(const Value: TBitmap);
begin
  FPicturePanel.Picture := Value;
end;

procedure TedMap.SetInstance(const Value: TMap);
begin
  FMap := Value;

  if FMap.IsNewInstance then
    Caption := 'Создание новой карты'
  else
    Caption := '#' + VarToStr(FMap.ID) + '  Редактирование карты "' + FMap.Name + '"';

  MapName := FMap.Name;
  MapLeft := FMap.Left;
  MapTop := FMap.Top;
  MapRight := FMap.Right;
  MapBottom := FMap.Bottom;
  Picture := FMap.Picture;

  FLayerList.Init(FMap);
  FMarkerGrid.Init(FMap);
  FQuestList.Init(FMap);
end;

procedure TedMap.PostValues(const Value: TMap);
begin
  Value.Name := MapName;
  FMap.Left := MapLeft;
  FMap.Top := MapTop;
  FMap.Right := MapRight;
  FMap.Bottom := MapBottom;
  Value.Picture := Picture;
end;

end.
