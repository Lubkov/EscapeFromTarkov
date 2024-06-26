﻿unit ME.Edit.Layer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, System.Actions, FMX.ActnList, FMX.Controls.Presentation, FMX.Objects,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.ImgList, System.ImageList,
  ME.DB.Entity, ME.DB.Layer, ME.Edit.Form.Presenter, ME.Frame.Picture;

type
  TedLayer = class(TEditForm, IEditDialog<TLayer>)
    edLevel: TNumberBox;
    edLevelName: TEdit;
    paPicture: TPanel;
  private
    FLayer: TLayer;
    FPicturePanel: TfrPicture;

    function GetLevel: Integer;
    procedure SetLevel(const Value: Integer);
    function GetLevelName: string;
    procedure SetLevelName(const Value: string);
    function GetPicture: TBitmap;
    procedure SetPicture(const Value: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetInstance(const Value: TLayer);
    procedure PostValues(const Value: TLayer);

    property Level: Integer read GetLevel write SetLevel;
    property LevelName: string read GetLevelName write SetLevelName;
    property Picture: TBitmap read GetPicture write SetPicture;
  end;

implementation

{$R *.fmx}

constructor TedLayer.Create(AOwner: TComponent);
begin
  inherited;

  FPicturePanel := TfrPicture.Create(Self);
  FPicturePanel.Parent := paPicture;
  FPicturePanel.Align := TAlignLayout.Client;
end;

function TedLayer.GetLevel: Integer;
begin
  Result := Trunc(edLevel.Value);
end;

procedure TedLayer.SetLevel(const Value: Integer);
begin
  edLevel.Value := Value;
end;

function TedLayer.GetLevelName: string;
begin
  Result := edLevelName.Text;
end;

procedure TedLayer.SetLevelName(const Value: string);
begin
  edLevelName.Text := Value;
end;

function TedLayer.GetPicture: TBitmap;
begin
  Result := FPicturePanel.Picture;
end;

procedure TedLayer.SetPicture(const Value: TBitmap);
begin
  FPicturePanel.Picture := Value;
end;

procedure TedLayer.SetInstance(const Value: TLayer);
begin
  FLayer := Value;

  if FLayer.IsNewInstance then
    Caption := 'Добавление нового уровня карты'
  else
    Caption := '#' + VarToStr(FLayer.ID) + ' Редактирование уровня карты';

  Level := FLayer.Level;
  LevelName := FLayer.Name;
  Picture := FLayer.Picture;
end;

procedure TedLayer.PostValues(const Value: TLayer);
begin
  Value.Level := Level;
  Value.Name := LevelName;
  Value.Picture := Picture;
end;

end.
