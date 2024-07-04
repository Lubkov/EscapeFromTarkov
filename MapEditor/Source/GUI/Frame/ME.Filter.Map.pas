unit ME.Filter.Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.ListBox,
  Map.Data.Types, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList,
  FMX.Layouts;

type
  TMapFilter = class(TFrame)
    laMapName: TLabel;
    edMapName: TComboBox;
    ImageList1: TImageList;
    ActionList1: TActionList;
    acAddMap: TAction;
    acEditMap: TAction;
    acDeleteMap: TAction;
    MainLayout: TLayout;
    ToolLayout: TLayout;
    edEditMap: TSpeedButton;
    MapNameLayout: TLayout;
    ButtonLayout: TLayout;
    procedure edMapNameChange(Sender: TObject);
    procedure acEditMapExecute(Sender: TObject);
  private
    FOnMapChanged: TMapChangedEvent;

    function GetMap: TMap;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;

    property Map: TMap read GetMap;
    property OnMapChanged: TMapChangedEvent read FOnMapChanged write FOnMapChanged;
  end;

implementation

uses
  Map.Data.Service, ME.Presenter.Map, ME.Edit.Map;

{$R *.fmx}

{ TMapFilter }

constructor TMapFilter.Create(AOwner: TComponent);
begin
  inherited;

  FOnMapChanged := nil;
end;

destructor TMapFilter.Destroy;
begin
  FOnMapChanged := nil;

  inherited;
end;

function TMapFilter.GetMap: TMap;
begin
  if edMapName.ItemIndex >= 0 then
    Result := DataService.Map[edMapName.ItemIndex]
  else
    Result := nil;
end;

procedure TMapFilter.Init;
var
  i: Integer;
begin
  edMapName.Clear;
  for i := 0 to DataService.Count - 1 do
    edMapName.Items.Add(DataService.Map[i].Caption);

  if DataService.Count > 0 then
    edMapName.ItemIndex := 0;
end;

procedure TMapFilter.edMapNameChange(Sender: TObject);
begin
  if Assigned(FOnMapChanged) then
    FOnMapChanged(Map);
end;

procedure TMapFilter.acEditMapExecute(Sender: TObject);
var
  Presenter: TEditMapPresenter;
  Dialog: TedMap;
begin
  Dialog := TedMap.Create(Self);
  try
    Presenter := TEditMapPresenter.Create(Dialog, Map);
    try
      if Presenter.Edit then
        edMapName.Items[edMapName.ItemIndex] := Map.Caption;
    finally
      Presenter.Free;
    end;
  finally
    Dialog.Free;
  end;
end;


end.
