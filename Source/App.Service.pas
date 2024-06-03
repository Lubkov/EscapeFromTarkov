unit App.Service;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  App.DB.Connection;

type
  TAppService = class(TComponent)
  private
    FConnection: TDBConnection;

    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    function GetDatabase: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Connected: Boolean read GetConnected write SetConnected;
    property Connection: TDBConnection read FConnection;
    property Database: string read GetDatabase;
  end;

var
  AppService: TAppService;

implementation

uses
  ME.Service.Point, ME.Service.Map, ME.Service.Layer, ME.Service.Marker,
  ME.Service.Quest;

{ TAppService }

constructor TAppService.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := TDBConnection.Create(Self);
  PointService := TPointService.Create(FConnection.Connection);
  MapService := TMapService.Create(FConnection.Connection);
  LayerService := TLayerService.Create(FConnection.Connection);
  MarkerService := TMarkerService.Create(FConnection.Connection);
  QuestService := TQuestService.Create(FConnection.Connection);
end;

destructor TAppService.Destroy;
begin
  FreeAndNil(MapService);
  FreeAndNil(PointService);
  FreeAndNil(LayerService);
  FreeAndNil(MarkerService);
  FreeAndNil(QuestService);

  FreeAndNil(FConnection);

  inherited;
end;

function TAppService.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TAppService.SetConnected(const Value: Boolean);
begin
  FConnection.Connected := Value;
end;

function TAppService.GetDatabase: string;
begin
  Result := FConnection.Connection.Database;
end;

procedure TAppService.Connect;
begin
  FConnection.Connect;
end;

procedure TAppService.Disconnect;
begin
  FConnection.Disconnect;
end;

end.
