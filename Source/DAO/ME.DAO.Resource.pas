unit ME.DAO.Resource;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Generics.Collections, Data.DB,
  MemDS, DBAccess, Uni, ME.DB.Entity, ME.DB.DAO, ME.DB.Resource;

type
  TResourceDAO = class(TDAOCommon)
  private
  protected
    function EntityClass: TDBEntityClass; override;
  public
    function GetAt(ID: Integer; const Entity: TDBEntity): Boolean; override;
    procedure GetAll(const Items: TList<TDBEntity>); override;
    procedure GetPictures(const MarkerID: Variant; const Items: TList<TDBResource>);
    procedure GetQuestItems(const MarkerID: Variant; const Items: TList<TDBResource>);
    procedure Insert(const Entity: TDBEntity); override;
    procedure Update(const Entity: TDBEntity); override;

//    procedure LoadPicture(const Entity: TDBEntity);
//    procedure SavePicture(const Entity: TDBEntity);
  end;

implementation

{ TResourceDAO }

function TResourceDAO.EntityClass: TDBEntityClass;
begin
  Result := TDBResource;
end;

function TResourceDAO.GetAt(ID: Integer; const Entity: TDBEntity): Boolean;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := 'SELECT ' + TDBResource.FieldList + ' FROM ' + TDBResource.EntityName + ' WHERE ID = :ID';
    Query.ParamByName('ID').Value := ID;
    Query.Open;

    Result := not Query.Eof;
    if Result then
      Entity.Assign(Query);
  finally
    Query.Free;
  end;
end;

procedure TResourceDAO.GetAll(const Items: TList<TDBEntity>);
var
  Query: TUniQuery;
  Entity: TDBEntity;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := 'SELECT ' + TDBResource.FieldList + ' FROM ' + TDBResource.EntityName;
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

procedure TResourceDAO.GetPictures(const MarkerID: Variant; const Items: TList<TDBResource>);
var
  Query: TUniQuery;
  Resource: TDBResource;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text := 'SELECT ' + TDBResource.FieldList + ' FROM ' + TDBResource.EntityName + ' WHERE MarkerID = :MarkerID';
    Query.ParamByName('MarkerID').Value := MarkerID;
    Query.Open;

    while not Query.Eof do begin
      Resource := TDBResource.Create;
      try
        Resource.Assign(Query);
      finally
        Items.Add(Resource);
      end;

      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TResourceDAO.GetQuestItems(const MarkerID: Variant; const Items: TList<TDBResource>);
var
  Query: TUniQuery;
  Resource: TDBResource;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text :=
      ' SELECT ' +
      '   r.ID, ' +
      '   r.MarkerID, ' +
      '   r.Kind, ' +
      '   r.Description ' +
      ' FROM Resource r ' +
      '   INNER JOIN QuestItem qi ON (qi.ResourceID = r.ID) ' +
      '       AND (qi.MarkerID = :MarkerID) ' +
      '       AND (r.Kind = :Kind) ';
    Query.ParamByName('MarkerID').Value := MarkerID;
    Query.ParamByName('Kind').Value := Ord(TResourceKind.QuestItem);
    Query.Open;

    while not Query.Eof do begin
      Resource := TDBResource.Create;
      try
        Resource.Assign(Query);
      finally
        Items.Add(Resource);
      end;

      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TResourceDAO.Insert(const Entity: TDBEntity);
var
  Query: TUniQuery;
  Resource: TDBResource;
begin
  Resource := TDBResource(Entity);

  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text :=
      ' INSERT INTO ' + TDBResource.EntityName +
      '   (MarkerID, Kind, Description) ' +
      ' VALUES ' +
      '   (:MarkerID, :Kind, :Description)';

    Query.ParamByName('MarkerID').Value := Resource.MarkerID;
    Query.ParamByName('Kind').AsInteger := Ord(Resource.Kind);
    Query.ParamByName('Description').AsString := Resource.Description;
//    TDBEntity.AssignPictureTo(Resource.Picture, Query.ParamByName('Picture'));
    Query.Execute;
    Resource.ID := Query.LastInsertId;
  finally
    Query.Free;
  end;
end;

procedure TResourceDAO.Update(const Entity: TDBEntity);
var
  Query: TUniQuery;
  Resource: TDBResource;
begin
  Resource := TDBResource(Entity);

  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Connection;
    Query.SQL.Text :=
      ' UPDATE ' + TDBResource.EntityName +
      ' SET ' +
      '    MarkerID = :MarkerID, ' +
      '    Kind = :Kind, ' +
      '    Description = :Description ' +
//      '    Picture = :Picture ' +
      ' WHERE ID = :ID';
    Query.ParamByName('ID').Value := Resource.ID;
    Query.ParamByName('MarkerID').Value := Resource.MarkerID;
    Query.ParamByName('Kind').AsInteger := Ord(Resource.Kind);
    Query.ParamByName('Description').AsString := Resource.Description;
//    TDBEntity.AssignPictureTo(Resource.Picture, Query.ParamByName('Picture'));
    Query.Execute;
  finally
    Query.Free;
  end;
end;

//procedure TResourceDAO.LoadPicture(const Entity: TDBEntity);
//var
//  Query: TUniQuery;
//  Resource: TDBResource;
//  Stream: TMemoryStream;
//begin
//  Resource := TDBResource(Entity);
//
//  Query := TUniQuery.Create(nil);
//  try
//    Query.Connection := Connection;
//    Query.SQL.Text := 'SELECT ID, Picture FROM ' + TDBResource.EntityName + ' WHERE ID = :ID';
//    Query.ParamByName('ID').Value := Resource.ID;
//    Query.Open;
//
//    Stream := TMemoryStream.Create;
//    try
//      TBlobField(Query.FieldByName('Picture')).SaveToStream(Stream);
//      Stream.Position := 0;
//      Resource.Picture.LoadFromStream(Stream);
//    finally
//      Stream.Free;
//    end;
//  finally
//    Query.Free;
//  end;
//end;
//
//procedure TResourceDAO.SavePicture(const Entity: TDBEntity);
//var
//  Query: TUniQuery;
//  Resource: TDBResource;
//  Stream: TMemoryStream;
//begin
//  Resource := TDBResource(Entity);
//
//  Query := TUniQuery.Create(nil);
//  try
//    Query.Connection := Connection;
//    Query.SQL.Text := 'UPDATE ' + TDBResource.EntityName + ' SET Picture = :Picture WHERE ID = :ID';
//    Query.ParamByName('ID').Value := Resource.ID;
//
//    if Resource.Picture.IsEmpty then
//      Query.ParamByName('Picture').Value := Null
//    else begin
//      Stream := TMemoryStream.Create;
//      try
//        Resource.Picture.SaveToStream(Stream);
//        Stream.Position := 0;
//        Query.ParamByName('Picture').LoadFromStream(Stream, ftBlob);
//      finally
//        Stream.Free;
//      end;
//    end;
//    Query.Execute;
//  finally
//    Query.Free;
//  end;
//end;

end.
