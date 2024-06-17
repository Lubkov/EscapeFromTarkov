unit Map.Data.Service;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.IOUtils,
  Map.Data.Types, Map.Data.Classes;

type
  TDataSertvice = class
  private
    FData: TJSONMapData;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;

    property Data: TJSONMapData read FData;
  end;

var
  DataSertvice: TDataSertvice;

implementation

uses
  App.Constants;

{ TDataSertvice }

constructor TDataSertvice.Create;
begin
  inherited;

  FData := TJSONMapData.Create;
end;

destructor TDataSertvice.Destroy;
begin
  FData.Free;

  inherited;
end;

procedure TDataSertvice.Load;
var
  FileName: string;
begin
  FileName := System.IOUtils.TPath.Combine(AppParams.Path, 'data.json');
  FData.LoadFromFile(FileName);
end;

end.
