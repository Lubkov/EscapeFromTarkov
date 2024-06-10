unit App.SQLite.Connection;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, MemDS, DBAccess, Uni, UniProvider, SQLiteUniProvider,
  App.DB.Connection;

type
  TSQLiteConnection = class(TDBConnection)
  private
    FDatabase: string;
//    FReadOnly: Boolean;
  protected
    procedure InitConnection; override;
  public
    property Database: string read FDatabase write FDatabase;
//    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

implementation

{ TSQLiteConnection }

procedure TSQLiteConnection.InitConnection;
begin
  Connection.Close;
  Connection.ProviderName := 'SQLite';
  Connection.Database := Database;
  Connection.SpecificOptions.Values['Direct'] := 'True';
  Connection.SpecificOptions.Values['UseUnicode'] := 'True';
//  Connection.SpecificOptions.Values['ConnectMode'] := 'cmReadOnly';
  Connection.SpecificOptions.Values['LockingMode'] := 'lmNormal';
end;

end.
