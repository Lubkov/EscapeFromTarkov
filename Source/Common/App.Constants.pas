unit App.Constants;

interface

uses
  System.SysUtils, System.IniFiles, System.IOUtils;

type
  TAppParams = record
  public
    Path: string;
    DataPath: string;
    SreenshotPath: string;
    TrackLocation: Boolean;
  public
    procedure Load;
  end;

var
  AppParams: TAppParams;

implementation

{ TAppParams }

procedure TAppParams.Load;
const
  ConfigFileName = 'Config.ini';
var
  Config: TIniFile;
begin
  Config := TIniFile.Create(TPath.Combine(Path, ConfigFileName));
  try
    DataPath := Config.ReadString('Options', 'DataPath', '');
    SreenshotPath := Config.ReadString('Options', 'SreenshotPath', '');
    TrackLocation := Config.ReadBool('Options', 'TrackLocation', True);
  finally
    Config.Free;
  end;
end;

initialization
  AppParams.Path := IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir);

end.
