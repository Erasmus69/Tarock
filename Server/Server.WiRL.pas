unit Server.WiRL;

interface

uses
  Neon.Core.Types
, WiRL.Core.Engine
, WiRL.http.Server
, WiRL.http.Server.Indy

, Spring.Logging

, Server.Configuration
;

type
  TServerREST = class
  private
    FServer: TWiRLServer;
    FLogger: ILogger;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    constructor Create(const AConfiguration: TConfiguration; const ALogger: ILogger);
    destructor Destroy; override;
    property Active: Boolean read GetActive write SetActive;
    property Logger: ILogger read FLogger;
  end;

implementation

{ TServerREST }

uses
  System.SysUtils,Common.Entities.Card
;


{======================================================================================================================}
constructor TServerREST.Create(const AConfiguration: TConfiguration; const ALogger: ILogger);
{======================================================================================================================}
begin
  FLogger := ALogger;

  Logger.Enter('TServerREST.Create');

  FServer := TWiRLServer.Create(nil);

  FServer
    .SetPort(AConfiguration.ServerPort)
    .SetThreadPoolSize(20)
    .AddEngine<TWiRLEngine>('/rest')
    .SetEngineName('Tarock Server')
    .AddApplication('/app')
      .SetAppName('Tarock')
      .SetResources('*')
      .SetFilters('*')
      .ConfigureSerializer
        .SetUseUTCDate(True)
        .SetMemberCase(TNeonCase.SnakeCase);
  //    .GetSerializers.RegisterSerializer(TCardKeySerializer);

  Logger.Leave('TServerREST.Create');
end;

{======================================================================================================================}
destructor TServerREST.Destroy;
{======================================================================================================================}
begin
  Logger.Enter('TServerREST.Destroy');

  Active := False;
  FServer.Free;

  inherited;

  Logger.Leave('TServerREST.Destroy');
end;

{======================================================================================================================}
function TServerREST.GetActive: Boolean;
{======================================================================================================================}
begin
  Result := FServer.Active;
end;

{======================================================================================================================}
procedure TServerREST.SetActive(const Value: Boolean);
{======================================================================================================================}
begin
  if FServer.Active <> Value then begin
    FServer.Active := Value;

    Logger.Info('TServerREST.SetActive :: %s is the new value', [BoolToStr(Value, True)]);
  end;
end;

end.
