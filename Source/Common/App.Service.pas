unit App.Service;

interface

uses
  System.SysUtils, System.Variants, System.Classes;

type
  TAppService = class(TComponent)
  private
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadParams;
    procedure LoadDataFromJSON;
  end;

var
  AppService: TAppService;

implementation

uses
  App.Constants, Map.Data.Service;

{ TAppService }

constructor TAppService.Create(AOwner: TComponent);
begin
  inherited;

  DataSertvice := TDataSertvice.Create;
end;

destructor TAppService.Destroy;
begin
  DataSertvice.Free;

  inherited;
end;

procedure TAppService.LoadParams;
begin
  AppParams.Load;
end;

procedure TAppService.LoadDataFromJSON;
begin
  DataSertvice.Load(AppParams.DataPath);
end;

end.
