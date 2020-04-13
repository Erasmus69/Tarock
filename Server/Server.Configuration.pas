unit Server.Configuration;

interface

type
  TConfiguration = class
  private
    FDatabaseConnectionName: String;
    FLogFileName: String;
    FLogLevel: String;
    FServerPort: Integer;
  public
    constructor Create;
    property DatabaseConnectionName: String read FDatabaseConnectionName write FDatabaseConnectionName;
    property LogFileName: String read FLogFileName;
    property LogLevel: String read FLogLevel write FLogLevel;
    property ServerPort: Integer read FServerPort write FServerPort;
  end;

implementation

uses
  System.IniFiles
, System.IOUtils
, System.SysUtils
;

type
  TPersistentConfiguration = class
  public
    class procedure Load(const AConfiguration: TConfiguration);
  end;

const
  CONNECTION_NAME_DEFAULT = 'ERGO';
  LOG_FILENAME = 'WiRLServerTemplate_%s.log';
  LOG_LEVEL = 'ERROR';
  SERVER_PORT = 8080;

{ TConfiguration }

{======================================================================================================================}
constructor TConfiguration.Create;
{======================================================================================================================}
begin
  TPersistentConfiguration.Load(Self);
end;

{ TPersistentConfiguration }

{======================================================================================================================}
class procedure TPersistentConfiguration.Load(const AConfiguration: TConfiguration);
{======================================================================================================================}
var
  appPath: String;
  appName: String;
  tmpPath: String;
  iniFileName: String;
  ini: TIniFile;
begin
  appPath := IncludeTrailingBackslash(TPath.GetDirectoryName(ParamStr(0)));
  appName := TPath.GetFileNameWithoutExtension(ParamStr(0));
  iniFileName := appPath + appName + '.ini';

  ini := TIniFile.Create(iniFileName);
  try
    tmpPath := TPath.GetTempPath;
    AConfiguration.FDatabaseConnectionName := ini.ReadString('SERVICE', 'DBNAME', CONNECTION_NAME_DEFAULT);
    AConfiguration.FLogFileName := ini.ReadString('SERVICE', 'LOG_FILENAME', tmpPath + LOG_FILENAME);
    AConfiguration.FLogLevel := ini.ReadString('SERVICE', 'LOG_LEVEL', LOG_LEVEL);
    AConfiguration.FServerPort := ini.ReadInteger('SERVICE', 'SERVER_PORT', SERVER_PORT);
  finally
    FreeAndNil(ini);
  end;
end;

end.

