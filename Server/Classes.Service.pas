unit Classes.Service;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs

, Classes.WorkerThread
;

type
  TErgoLicenseServerMasterWiRL = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
  private
    { Private declarations }
    WorkerThread: TWorkerThread;
    procedure ServiceStopShutdown;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ErgoLicenseServerMasterWiRL: TErgoLicenseServerMasterWiRL;

implementation

uses
  Registry
, System.IOUtils
, Server.Register
, Classes.Database
;

{$R *.dfm}
{$R ErgoLicenseServerMasterWSVC_EventLog.res}

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure ServiceController(CtrlCode: DWord); stdcall;
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
begin
  ArtPictureService.Controller(CtrlCode);
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
function TErgoLicenseServerMasterWiRL.GetServiceController: TServiceController;
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
begin
  Result := ServiceController;
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceAfterInstall(Sender: TService);
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
var
  reg: TRegistry;
  key: String;
begin
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) then
    begin
      reg.WriteString('Description', 'Servizio di aggiornamento immagini articoli');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;

  // Create registry entries so that the event viewer show messages properly when we use the LogMessage method.
  Key := '\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Self.Name;
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKey(Key, True) then
    begin
      reg.WriteString('EventMessageFile', ParamStr(0));
      reg.WriteInteger('TypesSupported', 7);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceAfterUninstall(Sender: TService);
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
var
  reg: TRegistry;
  key: String;
begin
  // Delete registry entries for event viewer.
  key := '\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Self.Name;
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.KeyExists(key) then
      reg.DeleteKey(key);
  finally
    reg.Free;
  end;
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceStart(Sender: TService; var Started: Boolean);
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
var
  appPath: String;
  appName: String;
  iniFileName: String;
  database: TDatabase;
begin
  appPath := IncludeTrailingBackslash(TPath.GetDirectoryName(ParamStr(0)));
  appName := TPath.GetFileNameWithoutExtension(ParamStr(0));
  iniFileName := appPath + appName + '.ini';

  if not FileExists(iniFileName) then begin
    LogMessage(
      Format('Can''t find then configuration file ''%s'' - Service won''t start!', [iniFileName]),
      EVENTLOG_WARNING_TYPE, 0, 3
    );
    Started := False;
    Exit;
  end;

  database := GetContainer.Resolve<TDatabase>;
  if not database.SQLConnection.Connected then
    database.SQLConnection.Connected := True;

  WorkerThread := GetContainer.Resolve<TWorkerThread>;
  WorkerThread.Start;

  LogMessage('ServiceStart succeeded', EVENTLOG_SUCCESS, 0, 1);
//  LogMessage('Your message goes here INFO', EVENTLOG_INFORMATION_TYPE, 0, 2);
//  LogMessage('Your message goes here WARN', EVENTLOG_WARNING_TYPE, 0, 3);
//  LogMessage('Your message goes here ERRO', EVENTLOG_ERROR_TYPE, 0, 4);
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceStop(Sender: TService; var Stopped: Boolean);
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
begin
  ServiceStopShutdown;
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceShutdown(Sender: TService);
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
begin
  ServiceStopShutdown;
end;

{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
procedure TErgoLicenseServerMasterWiRL.ServiceStopShutdown;
{//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}
var
  database: TDatabase;
begin
  if Assigned(WorkerThread) and (not WorkerThread.CheckTerminated) then begin
    LogMessage('ServiceStopShutdown is terminating WorkerThread', EVENTLOG_INFORMATION_TYPE, 0, 2);
    WorkerThread.Terminate;
    WorkerThread.Event.SetEvent;
    WorkerThread.WaitFor;
    FreeAndNil(WorkerThread);
    LogMessage('ServiceStopShutdown succeeded', EVENTLOG_SUCCESS, 0, 1);
  end;

  database := GetContainer.Resolve<TDatabase>;
  database.SQLConnection.Connected := False;
end;

end.
