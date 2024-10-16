unit App.DB.Connection;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, MemDS, DBAccess, Uni;

type
  TDBConnection = class(TComponent)
  private
    FConnection: TUniConnection;

    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
  protected
    procedure InitConnection; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Connected: Boolean read GetConnected write SetConnected;
    property Connection: TUniConnection read FConnection;
  end;


implementation

{ TDBConnection }

constructor TDBConnection.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := TUniConnection.Create(Self);
end;

destructor TDBConnection.Destroy;
begin
  FreeAndNil(FConnection);

  inherited;
end;

function TDBConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TDBConnection.SetConnected(const Value: Boolean);
begin
  if Value then
    Connect
  else
    Disconnect;
end;

procedure TDBConnection.Connect;
begin
  if Connected then
    Exit;

  InitConnection;
  FConnection.Connect;
end;

procedure TDBConnection.Disconnect;
begin
  FConnection.Disconnect;
end;

end.
