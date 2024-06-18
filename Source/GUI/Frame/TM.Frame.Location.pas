unit TM.Frame.Location;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.ImageList, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.ImgList, Map.Data.Types;

type
  TLocationChangedEvent = procedure (const Value: PMap) of object;

  TLocationGrid = class(TFrame)
    MainContainer: THorzScrollBox;
    Grid: TGridLayout;
    MainStyleBook: TStyleBook;
    ImageList1: TImageList;
  private
//    FItems: TList<TEntity>;
    FMaxHeight: Integer;
    FMaxWidth: Integer;
    FOnLocationChanged: TLocationChangedEvent;

    function GetCount: Integer;
    function GetItem(Index: Integer): PMap;
    procedure OnLocationClick(Sender: TObject);
    function GetColumnCount: Integer;
    function GetRowCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

//    procedure Clear;
    procedure Init;

    property Count: Integer read GetCount;
    property ColumnCount: Integer read GetColumnCount;
    property RowCount: Integer read GetRowCount;
    property Items[Index: Integer]: PMap read GetItem;
    property MaxHeight: Integer read FMaxHeight;
    property MaxWidth: Integer read FMaxWidth;
    property OnLocationChanged: TLocationChangedEvent read FOnLocationChanged write FOnLocationChanged;
  end;

implementation

uses
  Map.Data.Service;

{$R *.fmx}

constructor TLocationGrid.Create(AOwner: TComponent);
const
  ItemHeight = 180;
  ItemWidth = 160;
  BackgroundColor = $001C1612;
begin
  inherited;

//  Self.Fill.Color := BackgroundColor;
//  Self.Fill.Kind := TBrushKind.Solid;

//  FItems := TList<TEntity>.Create;
  FOnLocationChanged := nil;

  Grid.ItemHeight := ItemHeight;
  Grid.ItemWidth := ItemWidth;
end;

destructor TLocationGrid.Destroy;
begin
  FOnLocationChanged := nil;
//  Clear;
//  FItems.Free;

  inherited;
end;

function TLocationGrid.GetCount: Integer;
begin
  Result := DataSertvice.Data.Count;
end;

function TLocationGrid.GetColumnCount: Integer;
begin
  Result := Count div 2;
  if (Count mod 2) <> 0 then
    Result := Result + 1;
end;

function TLocationGrid.GetRowCount: Integer;
begin
  Result := 2;
end;

function TLocationGrid.GetItem(Index: Integer): PMap;
begin
  Result := DataSertvice.Data.Map[Index];
end;

//procedure TLocationGrid.Clear;
//var
//  i: Integer;
//begin
//  for i := 0 to Count - 1 do
//    FItems[i].Free;
//
//  FItems.Clear;
//end;

procedure TLocationGrid.Init;
var
  Button: TSpeedButton;
  i: Integer;
begin
//  MapService.GetAll(FItems);

  for i := 0 to Count - 1 do begin
    Button := TSpeedButton.Create(Self);
    Button.Parent := Grid;
    Button.Height := Grid.ItemHeight;
    Button.Width := Grid.ItemWidth;
    Button.Margins.Left := 5;
    Button.Margins.Top := 5;
    Button.Margins.Right := 0;
    Button.Margins.Bottom := 0;
    Button.Cursor := crHandPoint;
    Button.StyleLookup := 'LocationGridItemStyle';
    Button.Images := ImageList1;
    Button.ImageIndex := i;
    Button.Text := Items[i].Name;
//    Button.Bitmap.Assign(Items[i].Picture);
    Button.Tag := i;
    Button.OnClick := OnLocationClick;
  end;

  FMaxWidth := Trunc(Grid.ItemWidth) * ColumnCount + 5; //+ 20;
  FMaxHeight := Trunc(Grid.ItemHeight) * RowCount + 5; //+ 20;

  Grid.Position.X := 0;
  Grid.Position.Y := 0;
  Grid.Width := FMaxWidth;
  Grid.Height := FMaxHeight;
end;

procedure TLocationGrid.OnLocationClick(Sender: TObject);
begin
  if Assigned(FOnLocationChanged) then
    FOnLocationChanged(Items[TImage(Sender).Tag]);
end;

end.
