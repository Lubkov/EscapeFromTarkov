unit TM.Form.Location;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, Data.DB, ME.DB.Entity, ME.DB.Map, FMX.Objects, FMX.Layouts;

type
  TLocationChangedEvent = procedure (const Value: TMap) of object;

  TLocationForm = class(TForm)
    GridLayout1: TGridLayout;
  private
    FItems: TList<TEntity>;
    FOnLocationChanged: TLocationChangedEvent;

    function GetCount: Integer;
    function GetItem(Index: Integer): TMap;
    procedure OnLocationClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    procedure Init;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMap read GetItem;
    property OnLocationChanged: TLocationChangedEvent read FOnLocationChanged write FOnLocationChanged;
  end;

implementation

uses
  ME.Service.Map;

{$R *.fmx}

{ TLocationForm }

constructor TLocationForm.Create(AOwner: TComponent);
const
  BackgroundColor = $001C1612;
begin
  inherited;

  Self.Fill.Color := BackgroundColor;
  Self.Fill.Kind := TBrushKind.Solid;

  FItems := TList<TEntity>.Create;
  FOnLocationChanged := nil;
end;

destructor TLocationForm.Destroy;
begin
  FOnLocationChanged := nil;
  Clear;
  FItems.Free;

  inherited;
end;

function TLocationForm.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TLocationForm.GetItem(Index: Integer): TMap;
begin
  Result := TMap(FItems[Index]);
end;

procedure TLocationForm.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    FItems[i].Free;

  FItems.Clear;
end;

procedure TLocationForm.Init;
const
  ItemHeight = 200;
  ItemWidth = 200;
var
  Image: TImage;
  i: Integer;
begin
  MapService.GetAll(FItems);

  for i := 0 to Count - 1 do begin
    Image := TImage.Create(Self);
    Image.Parent := GridLayout1;
    Image.Height := 200;
    Image.Width := 200;
    Image.Margins.Left := 5;
    Image.Margins.Top := 5;
    Image.Margins.Right := 5;
    Image.Margins.Bottom := 5;
    Image.Cursor := crHandPoint;
    Image.Bitmap.Assign(Items[i].Picture);
    Image.Tag := i;
    Image.OnClick := OnLocationClick;
  end;

  Self.Width := (ItemWidth + 10) * (Count div 2);
  Self.Height := (ItemHeight + 10) * 2;
end;

procedure TLocationForm.OnLocationClick(Sender: TObject);
begin
  if Assigned(FOnLocationChanged) then
    FOnLocationChanged(Items[TImage(Sender).Tag]);

  Self.Close;
end;

end.
