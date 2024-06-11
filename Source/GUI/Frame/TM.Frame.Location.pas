unit TM.Frame.Location;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, Data.DB, ME.DB.Entity, ME.DB.Map, FMX.Objects;

type
  TLocationChangedEvent = procedure (const Value: TMap) of object;

  TLocationPanel = class(TFrame)
    MainContainer: THorzScrollBox;
    Grid: TGridLayout;
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

constructor TLocationPanel.Create(AOwner: TComponent);
const
  BackgroundColor = $001C1612;
begin
  inherited;

//  Self.Fill.Color := BackgroundColor;
//  Self.Fill.Kind := TBrushKind.Solid;

  FItems := TList<TEntity>.Create;
  FOnLocationChanged := nil;
end;

destructor TLocationPanel.Destroy;
begin
  FOnLocationChanged := nil;
  Clear;
  FItems.Free;

  inherited;
end;

function TLocationPanel.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TLocationPanel.GetItem(Index: Integer): TMap;
begin
  Result := TMap(FItems[Index]);
end;

procedure TLocationPanel.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    FItems[i].Free;

  FItems.Clear;
end;

procedure TLocationPanel.Init;
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
    Image.Parent := Grid;
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

  Grid.Position.X := 0;
  Grid.Position.Y := 0;
  Grid.Width := (ItemWidth + 10) * Round(Count / 2 + 0.1);
  Grid.Height := (ItemHeight + 10) * 2;
end;

procedure TLocationPanel.OnLocationClick(Sender: TObject);
begin
  if Assigned(FOnLocationChanged) then
    FOnLocationChanged(Items[TImage(Sender).Tag]);

  Self.Visible := False;
end;

end.
