unit App.Service;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.IOUtils;

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
var
  FileName: string;
begin
  FileName := TPath.Combine(AppParams.DataPath, 'data.json');
  DataSertvice.Load(FileName);
end;

end.
