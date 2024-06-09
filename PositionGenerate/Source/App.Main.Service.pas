unit App.Main.Service;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  App.Lite.Connection;

type
  TAppService = class(TComponent)
  private
    FConnection: TLiteConnection;

    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    function GetDatabase: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Connected: Boolean read GetConnected write SetConnected;
    property Connection: TLiteConnection read FConnection;
    property Database: string read GetDatabase;
  end;

var
  AppService: TAppService;

implementation

{ TAppService }

constructor TAppService.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := TLiteConnection.Create(Self);
end;

destructor TAppService.Destroy;
begin
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
