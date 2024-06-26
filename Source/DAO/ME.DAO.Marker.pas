unit ME.DAO.Marker;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Generics.Collections, Data.DB,
  MemDS, DBAccess, Uni, ME.DB.Entity, ME.DB.DAO, ME.DB.Marker;

type
  TMarkerDAO = class(TDAOCommon)
  private
  protected
    function EntityClass: TEntityClass; override;
  public
    function GetAt(ID: Integer; const Entity: TEntity): Boolean; override;
    procedure GetAll(const Items: TList<TEntity>); override;
    procedure LoadMarkers(const MapID: Variant; const Items: TList<TMarker>);
    procedure Insert(const Entity: TEntity); override;
    procedure Update(const Entity: TEntity); override;
  end;

implementation

const
  SqlSelectCommandText =
    ' SELECT ' +
    '     t.ID as ID, ' +
    '     t.MapID as MapID, ' +
    '     t.Name as Name, ' +
    '     t.Kind as Kind, ' +
    '     t.Left as Left, ' +
    '     t.Top as Top ' +
    ' FROM Marker t ' +
    ' %s ';

{ TMarkerDAO }

function TMarkerDAO.EntityClass: TEntityClass;
begin
  Result := TMarker;
end;

function TMarkerDAO.GetAt(ID: Integer; const Entity: TEntity): Boolean;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := Format(SqlSelectCommandText, [' WHERE (t.ID = :ID) ']);
    Query.ParamByName('ID').Value := ID;
    Query.Open;

    Result := not Query.Eof;
    if Result then
      Entity.Assign(Query);
  finally
    Query.Free;
  end;
end;

procedure TMarkerDAO.GetAll(const Items: TList<TEntity>);
const
  Filter = '';
var
  Query: TUniQuery;
  Entity: TEntity;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := Format(SqlSelectCommandText, [Filter]);
    Query.Open;

    while not Query.Eof do begin
      Entity := EntityClass.Create;
      try
        Entity.Assign(Query);
      finally
        Items.Add(Entity);
      end;

      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TMarkerDAO.LoadMarkers(const MapID: Variant; const Items: TList<TMarker>);
const
  Filter = ' WHERE (t.MapID = :MapID) ';
var
  Query: TUniQuery;
  Entity: TMarker;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := Format(SqlSelectCommandText, [Filter]);
    Query.ParamByName('MapID').Value := MapID;
    Query.Open;

    while not Query.Eof do begin
      Entity := TMarker.Create;
      try
        Entity.Assign(Query);
      finally
        Items.Add(Entity);
      end;

      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;
procedure TMarkerDAO.Insert(const Entity: TEntity);
var
  Query: TUniQuery;
  Marker: TMarker;
begin
  Marker := TMarker(Entity);

  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text :=
      ' INSERT INTO Marker (MapID, Name, Kind, Left, Top) ' +
      ' VALUES (:MapID, :Name, :Kind, :Left, :Top) ';
    Query.ParamByName('MapID').Value := Marker.MapID;
    Query.ParamByName('Name').AsString := Marker.Name;
    Query.ParamByName('Kind').AsInteger := Ord(Marker.Kind);
    Query.ParamByName('Left').AsInteger := Marker.Left;
    Query.ParamByName('Top').AsInteger := Marker.Top;
    Query.Execute;
    Marker.ID := Query.LastInsertId;
  finally
    Query.Free;
  end;
end;

procedure TMarkerDAO.Update(const Entity: TEntity);
var
  Query: TUniQuery;
  Marker: TMarker;
begin
  Marker := TMarker(Entity);

  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text :=
      ' UPDATE Marker ' +
      ' SET ' +
      '   MapID = :MapID, ' +
      '   Name = :Name, ' +
      '   Kind = :Kind, ' +
      '   Left = :Left, ' +
      '   Top = :Top ' +
      ' WHERE ID = :ID ';
    Query.ParamByName('ID').Value := Marker.ID;
    Query.ParamByName('MapID').Value := Marker.MapID;
    Query.ParamByName('Name').AsString := Marker.Name;
    Query.ParamByName('Kind').AsInteger := Ord(Marker.Kind);
    Query.ParamByName('Left').AsInteger := Marker.Left;
    Query.ParamByName('Top').AsInteger := Marker.Top;
    Query.Execute;
  finally
    Query.Free;
  end;
end;

end.
