unit Server.Register;

interface

uses
  Spring.Container
;

function GetContainer: TContainer;

implementation

uses
  Spring.Container.Common
, Spring.Logging.Configuration
, Server.Logger
, Server.Repository
, Server.Controller
, Server.Configuration
, Server.WiRL;

var
  Container: TContainer;

{======================================================================================================================}
function GetContainer: TContainer;
{======================================================================================================================}
begin
  Result := Container;
end;

{======================================================================================================================}
procedure RegisterWithContainer(AContainer: TContainer);
{======================================================================================================================}
begin
  AContainer.RegisterType<TRepository>.AsPooled(1, 1);
  AContainer.RegisterType<TApiV1Controller>;
  AContainer.RegisterType<TConfiguration>.AsSingleton(TRefCounting.False);
  AContainer.RegisterType<TServerREST>.AsSingleton(TRefCounting.False);
  AContainer.Build;
end;

{======================================================================================================================}
procedure InitializeLogger(AContainer: TContainer);
{======================================================================================================================}
var
  configuration: TConfiguration;
begin
  configuration := GetContainer.Resolve<TConfiguration>;

  TLoggingConfiguration.LoadFromString(
    Container,
    GetLoggingConfiguration(configuration.LogFilename, configuration.LogLevel)
  );
  Container.Build;
end;

initialization
  Container := TContainer.Create;
  RegisterWithContainer(Container);
  InitializeLogger(Container);

finalization
  Container.Free;
end.

