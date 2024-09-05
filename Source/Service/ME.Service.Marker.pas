unit ME.Service.Marker;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Generics.Collections,
  Data.DB, ME.DB.Entity, ME.DB.DAO, ME.DB.Service, ME.DB.Marker, ME.DAO.Marker,
  ME.DB.Resource;

type
  TMarkerService = class(TServiceCommon)
  private
    function GetMarkerDAO: TMarkerDAO;
  protected
    function GetDAOClass: TDAOClass; override;
  public
    procedure Insert(const Entity: TEntity); override;
    procedure Remove(const ID: Variant); override;

    procedure LoadMarkers(const MapID: Variant; const Items: TList<TDBMarker>);
    procedure LoadQuestMarkers(const MapID, QuestID: Variant; const Items: TList<TDBMarker>);
    procedure LoadPictures(const ID: Variant; const Items: TList<TDBResource>);
    procedure DeletePictures(const Items: TList<TDBResource>);

    property MarkerDAO: TMarkerDAO read GetMarkerDAO;
  end;

var
  MarkerService: TMarkerService;

implementation

uses
  ME.Service.Resource;

{ TMarkerService }

function TMarkerService.GetMarkerDAO: TMarkerDAO;
begin
  Result := TMarkerDAO(DAO);
end;

function TMarkerService.GetDAOClass: TDAOClass;
begin
  Result := TMarkerDAO;
end;

procedure TMarkerService.Insert(const Entity: TEntity);
var
  Marker: TDBMarker;
  Resource: TDBResource;
begin
  Marker := TDBMarker(Entity);
//  case Marker.Kind of
//    TResourceKind.Screenshot:
//      inherited;
//    TResourceKind.QuestItem:
//      ;
//  else
//    raise Exception.Create('TResourceKind is not supported');
//  end;

  inherited;

  for Resource in Marker.Images do begin
    Resource.MarkerID := Marker.ID;
    ResourceService.Save(Resource);
    ResourceService.SavePicture(Resource);
  end;

//  for Resource in Marker.Items do
//    ResourceService.SavePicture(Resource);
end;

procedure TMarkerService.Remove(const ID: Variant);
var
  Marker: TDBMarker;
begin
  Marker := TDBMarker.Create;
  try
    if GetAt(ID, Marker) then begin
      LoadPictures(ID, Marker.Images);
      DeletePictures(Marker.Images);
    end;
  finally
    Marker.Free;
  end;

  inherited;
end;

procedure TMarkerService.LoadMarkers(const MapID: Variant; const Items: TList<TDBMarker>);
begin
  MarkerDAO.LoadMarkers(MapID, Null, Items);
end;

procedure TMarkerService.LoadQuestMarkers(const MapID, QuestID: Variant; const Items: TList<TDBMarker>);
begin
  MarkerDAO.LoadMarkers(MapID, QuestID, Items);
end;

procedure TMarkerService.LoadPictures(const ID: Variant; const Items: TList<TDBResource>);
begin
  ResourceService.LoadMarkerPictures(ID, Items);
end;

procedure TMarkerService.DeletePictures(const Items: TList<TDBResource>);
var
  Resource: TDBResource;
begin
  for Resource in Items do
    ResourceService.DeletePicture(Resource);
end;

end.
