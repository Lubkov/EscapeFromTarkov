unit Map.CursorService;

interface

uses
  FMX.Platform, FMX.Types, System.UITypes;

type
  TMapCursorService = class(TInterfacedObject, IFMXCursorService)
  private
    class var FPreviousPlatformService: IFMXCursorService;
    class var FCursorService: TMapCursorService;
    class var FCurrentCursor: TCursor;

    class procedure SetCurrentCursor(const Value: TCursor); static;
  public
    class constructor Create;

    procedure SetCursor(const ACursor: TCursor);
    function GetCursor: TCursor;

    class property Cursor: TCursor read FCurrentCursor write SetCurrentCursor;
  end;

implementation

{ TMapCursorService }

class constructor TMapCursorService.Create;
begin
  FCursorService := TMapCursorService.Create;

  FPreviousPlatformService := TPlatformServices.Current.GetPlatformservice(IFMXCursorService) as IFMXCursorService; // TODO: if not assigned

  TPlatformServices.Current.RemovePlatformService(IFMXCursorService);
  TPlatformServices.Current.AddPlatformService(IFMXCursorService, FCursorService);
end;

function TMapCursorService.GetCursor: TCursor;
begin
  Result :=  FPreviousPlatformService.GetCursor;
end;

procedure TMapCursorService.SetCursor(const ACursor: TCursor);
begin
  if FCurrentCursor = crDefault then
    FPreviousPlatformService.SetCursor(ACursor)
  else
    FPreviousPlatformService.SetCursor(FCurrentCursor);
end;

class procedure TMapCursorService.SetCurrentCursor(const Value: TCursor);
begin
  FCurrentCursor := Value;
  TMapCursorService.FPreviousPlatformService.SetCursor(FCurrentCursor);
end;

end.
