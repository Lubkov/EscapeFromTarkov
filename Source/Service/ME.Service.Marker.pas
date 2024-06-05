unit ME.Service.Marker;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Generics.Collections,
  Data.DB, ME.DB.Entity, ME.DB.DAO, ME.DB.Service, ME.DB.Marker, ME.DAO.Marker;

type
  TMarkerService = class(TServiceCommon)
  private
    function GetMarkerDAO: TMarkerDAO;
  protected
    function GetDAOClass: TDAOClass; override;
  public
    procedure LoadMarkers(const MapID: Variant; const Items: TList<TMarker>);
    procedure LoadQuestMarkers(const MapID, QuestID: Variant; const Items: TList<TMarker>);

    property MarkerDAO: TMarkerDAO read GetMarkerDAO;
  end;

var
  MarkerService: TMarkerService;

implementation

{ TMarkerService }

function TMarkerService.GetMarkerDAO: TMarkerDAO;
begin
  Result := TMarkerDAO(DAO);
end;

function TMarkerService.GetDAOClass: TDAOClass;
begin
  Result := TMarkerDAO;
end;

procedure TMarkerService.LoadMarkers(const MapID: Variant; const Items: TList<TMarker>);
begin
  MarkerDAO.LoadMarkers(MapID, Null, Items);
end;

procedure TMarkerService.LoadQuestMarkers(const MapID, QuestID: Variant; const Items: TList<TMarker>);
begin
  MarkerDAO.LoadMarkers(MapID, QuestID, Items);
end;

end.
