unit App.Constants;

interface

uses
  System.SysUtils, System.IniFiles, System.IOUtils;

type
  TAppParams = record
  public
    Path: string;
    DatabasePath: string;
    SreenshotPath: string;
    TrackLocation: Boolean;

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
    DatabasePath := Config.ReadString('Options', 'DatabasePath', '');
    SreenshotPath := Config.ReadString('Options', 'SreenshotPath', '');
    TrackLocation := Config.ReadBool('Options', 'TrackLocation', True);
  finally
    Config.Free;
  end;
end;

initialization
  AppParams.Path := IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir);

end.
