unit ME.Connection;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, MemDS, DBAccess, Uni, UniProvider, SQLiteUniProvider;

type
  TMEConnection = class(TComponent)
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

constructor TMEConnection.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := TUniConnection.Create(Self);
end;

destructor TMEConnection.Destroy;
begin
  FreeAndNil(FConnection);

  inherited;
end;

function TMEConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TMEConnection.SetConnected(const Value: Boolean);
begin
  if Value then
    Connect
  else
    Disconnect;
end;

procedure TMEConnection.InitConnection;
begin
  FConnection.Close;
  FConnection.ProviderName := 'SQLite';
  FConnection.Database := AppParams.Path + 'data.db';
  FConnection.SpecificOptions.Values['Direct'] := 'True';
  FConnection.SpecificOptions.Values['UseUnicode'] := 'True';
end;

procedure TMEConnection.Connect;
begin
  if Connected then
    Exit;

  InitConnection;
  FConnection.Connect;
end;

procedure TMEConnection.Disconnect;
begin
  FConnection.Disconnect;
end;

end.
