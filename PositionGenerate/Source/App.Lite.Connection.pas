unit App.Lite.Connection;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, MemDS, DBAccess, Uni, UniProvider, SQLiteUniProvider;

type
  TLiteConnection = class(TComponent)
  private
    FConnection: TUniConnection;

    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure InitConnection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Connected: Boolean read GetConnected write SetConnected;
    property Connection: TUniConnection read FConnection;
  end;


implementation

uses
  App.Constants;

{ TConnection }

constructor TLiteConnection.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := TUniConnection.Create(Self);
end;

destructor TLiteConnection.Destroy;
begin
  FreeAndNil(FConnection);

  inherited;
end;

function TLiteConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TLiteConnection.SetConnected(const Value: Boolean);
begin
  if Value then
    Connect
  else
    Disconnect;
end;

procedure TLiteConnection.InitConnection;
begin
  FConnection.Close;
  FConnection.ProviderName := 'SQLite';
  FConnection.Database := AppParams.Path + 'data.db';
  FConnection.SpecificOptions.Values['Direct'] := 'True';
  FConnection.SpecificOptions.Values['UseUnicode'] := 'True';
  FConnection.SpecificOptions.Values['ConnectMode'] := 'cmReadOnly';
  FConnection.SpecificOptions.Values['LockingMode'] := 'lmNormal';
end;

procedure TLiteConnection.Connect;
begin
  if Connected then
    Exit;

  InitConnection;
  FConnection.Connect;
end;

procedure TLiteConnection.Disconnect;
begin
  FConnection.Disconnect;
end;

end.
