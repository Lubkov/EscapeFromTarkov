unit ME.Frame.Resource;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.Actions, FMX.ActnList, System.ImageList,
  FMX.ImgList, FMX.Grid, FMX.ScrollBox, FMX.Objects, FMX.Controls.Presentation,
  Map.Data.Types;

type
  TResourcesGrid = class(TFrame)
    paTopPanel: TPanel;
    edAddResource: TSpeedButton;
    edEditResource: TSpeedButton;
    edDeleteResource: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    CaptionColumn: TStringColumn;
    ImageList1: TImageList;
    ActionList1: TActionList;
    acAddResource: TAction;
    acEditResource: TAction;
    acDeleteResource: TAction;
    IDColumn: TStringColumn;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSelChanged(Sender: TObject);
    procedure acAddResourceExecute(Sender: TObject);
    procedure acEditResourceExecute(Sender: TObject);
    procedure acDeleteResourceExecute(Sender: TObject);
    procedure GridCellDblClick(const Column: TColumn; const Row: Integer);
  private
    FMarker: TMarker;
    FFocusedIndex: Integer;

    function GetFocusedIndex: Integer;
    procedure SetFocusedIndex(const Value: Integer);
    function InternalResourceEdit(const Resource: TResource): Boolean;
    procedure ResourceEdit(const Index: Integer);
  protected
    function GetCount: Integer; virtual;
    function GetResource(Index: Integer): TResource; virtual;
    function GetResourceClass: TResourceClass; virtual;
    procedure InternalAddResource(const Resource: TResource); virtual;
    procedure InternalDeleteResource(const Index: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const Marker: TMarker);

    property Marker: TMarker read FMarker;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TResource read GetResource;
    property FocusedIndex: Integer read GetFocusedIndex write SetFocusedIndex;
  end;

implementation

uses
  Map.Data.Service, ME.Presenter.Resource, ME.Edit.Resource,
  ME.Dialog.Message;

{$R *.fmx}

{ TMarkerImagesGrid }

constructor TResourcesGrid.Create(AOwner: TComponent);
begin
  inherited;

  Grid.RowCount := 0;
end;

destructor TResourcesGrid.Destroy;
begin

  inherited;
end;

procedure TResourcesGrid.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
const
  IDColumnIdx = 0;
  DescriptionColumnIdx = 1;
begin
  if Count <= ARow then
    Exit;

  case ACol of
    IDColumnIdx:
      Value := Items[ARow].ID;
    DescriptionColumnIdx:
      Value := Items[ARow].Description;
  end;
end;

procedure TResourcesGrid.GridSelChanged(Sender: TObject);
begin
  FocusedIndex := Grid.Selected;
end;

function TResourcesGrid.GetFocusedIndex: Integer;
begin
  if (FMarker = nil) or (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Result := -1
  else
    Result := Grid.Selected;
end;

procedure TResourcesGrid.SetFocusedIndex(const Value: Integer);
begin
  if FFocusedIndex = Value then
    Exit;

  FFocusedIndex := Value;
end;

function TResourcesGrid.InternalResourceEdit(const Resource: TResource): Boolean;
var
  Presenter: TEditResourcePresenter;
  Dialog: TedResource;
begin
  Dialog := TedResource.Create(Self);
  try
    Presenter := TEditResourcePresenter.Create(Dialog, Resource);
    try
      Result := Presenter.Edit;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TResourcesGrid.ResourceEdit(const Index: Integer);
var
  Resource: TResource;
begin
  if (Index < 0) or (Index >= Count) then
    Exit;

  Resource := Items[Index];
  Grid.BeginUpdate;
  try
    InternalResourceEdit(Resource);
//    imMapPicture.Bitmap.Assign(Layer.Picture);
  finally
    Grid.EndUpdate;
  end;
end;

function TResourcesGrid.GetCount: Integer;
begin
  if FMarker <> nil then
    Result := FMarker.Images.Count
  else
    Result := 0;
end;

function TResourcesGrid.GetResource(Index: Integer): TResource;
begin
  Result := FMarker.Images[Index];
end;

function TResourcesGrid.GetResourceClass: TResourceClass;
begin
  Result := TResource;
end;

procedure TResourcesGrid.InternalAddResource(const Resource: TResource);
begin
  FMarker.Images.Add(Resource);
end;

procedure TResourcesGrid.InternalDeleteResource(const Index: Integer);
begin
  FMarker.Images.Delete(Grid.Selected);
end;

procedure TResourcesGrid.Init(const Marker: TMarker);
begin
  FMarker := Marker;

  Grid.BeginUpdate;
  try
    Grid.RowCount := Count;
  finally
    Grid.EndUpdate;
  end;

  if Count > 0 then begin
    Grid.Selected := -1;
    Grid.Selected := 0;
  end;
end;

procedure TResourcesGrid.acAddResourceExecute(Sender: TObject);
var
  Resource: TResource;
  Res: Boolean;
begin
  Res := False;
  Resource := GetResourceClass.Create;
  try
    Res := InternalResourceEdit(Resource);
    if Res then begin
      InternalAddResource(Resource);

      Grid.BeginUpdate;
      try
        Grid.RowCount := Count;
      finally
        Grid.EndUpdate;
      end;
    end;
  finally
    if not Res then
      Resource.Free;
  end;
end;

procedure TResourcesGrid.acEditResourceExecute(Sender: TObject);
begin
  ResourceEdit(Grid.Selected);
end;

procedure TResourcesGrid.acDeleteResourceExecute(Sender: TObject);
var
  Resource: TResource;
  Presenter: TDelResourcePresenter;
  Dialog: TedMessage;
begin
  if (Grid.Selected < 0) or (Grid.Selected >= Count) then
    Exit;

  Resource := Items[Grid.Selected];

  Dialog := TedMessage.Create(Self);
  try
    Presenter := TDelResourcePresenter.Create(Dialog, Resource);
    try
      if Presenter.Delete then begin
        Grid.BeginUpdate;
        try
          InternalDeleteResource(Grid.Selected);
          Grid.RowCount := Count;
        finally
          Grid.EndUpdate;
        end;
      end;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TResourcesGrid.GridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  ResourceEdit(Row);
end;

end.
