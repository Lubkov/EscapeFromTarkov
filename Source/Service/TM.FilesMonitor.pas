unit TM.FilesMonitor;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows;

type
  TChangeMonitor = class(TThread)
  private
    FDirectory: string;
    FOnChange: TNotifyEvent;

    procedure DoChange;
  protected
    procedure Execute; override;
  public
    constructor Create(const Directory: string);

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

{ TChangeMonitor }

constructor TChangeMonitor.Create(const Directory: string);
begin
  inherited Create(True);

  FDirectory := Directory;
end;

procedure TChangeMonitor.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TChangeMonitor.Execute;
const
  ScanSubDirs = False;
var
  ChangeHandle: THandle;
begin
  {получаем хэндл события}
  ChangeHandle := FindFirstChangeNotification(PChar(FDirectory),
                                              ScanSubDirs,
                                              FILE_NOTIFY_CHANGE_FILE_NAME);

  if ChangeHandle = INVALID_HANDLE_VALUE then
    Terminate;

  try
    while not Terminated do begin
      case WaitForSingleObject(ChangeHandle, 1000) of
        WAIT_FAILED:
          Terminate;
        WAIT_OBJECT_0:
          Synchronize(DoChange);
      end;
      FindNextChangeNotification(ChangeHandle);
    end;
  finally
    FindCloseChangeNotification(ChangeHandle);
  end;
end;

end.
