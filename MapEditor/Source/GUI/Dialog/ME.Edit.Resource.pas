unit ME.Edit.Resource;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ME.Edit.Form, System.Actions, FMX.ActnList, FMX.Controls.Presentation,
  FMX.Edit, FMX.Layouts, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  Map.Data.Types, ME.Frame.Picture, ME.Edit.Form.Presenter;

type
  TedResource = class(TEditForm, IEditDialog<TResource>)
    ImageDescription: TLayout;
    TopLayout: TLayout;
    edDescription: TMemo;
    laDescription: TLabel;
  private
    FResource: TResource;
    FPicturePanel: TfrPicture;

    function GetDescription: string;
    function GetPicture: TBitmap;
    procedure SetDescription(const Value: string);
    procedure SetPicture(const Value: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetInstance(const Value: TResource);
    procedure PostValues(const Value: TResource);

    property Description: string read GetDescription write SetDescription;
    property Picture: TBitmap read GetPicture write SetPicture;
  end;

implementation

uses
  Map.Data.Service;

{$R *.fmx}

{ TedMarkerImage }

constructor TedResource.Create(AOwner: TComponent);
begin
  inherited;

  FPicturePanel := TfrPicture.Create(Self);
  FPicturePanel.Parent := ImageDescription;
  FPicturePanel.Align := TAlignLayout.Client;
end;

function TedResource.GetDescription: string;
begin
  Result := edDescription.Text;
end;

procedure TedResource.SetDescription(const Value: string);
begin
  edDescription.Text := Value;
end;

function TedResource.GetPicture: TBitmap;
begin
  Result := FPicturePanel.Picture;
end;

procedure TedResource.SetPicture(const Value: TBitmap);
begin
  FPicturePanel.Picture := Value;
end;

procedure TedResource.SetInstance(const Value: TResource);
begin
  FResource := Value;

  if FResource.IsNewInstance then
    Caption := 'Добавление нового ресурса'
  else
    Caption := 'Редактирование ресурса';

  Description := FResource.Description;

  DataSertvice.LoadImage(FResource, Picture);
end;

procedure TedResource.PostValues(const Value: TResource);
begin
  Value.Description := Description;

  if FPicturePanel.Changed then
    DataSertvice.SaveImage(Value, Picture);
end;

end.
