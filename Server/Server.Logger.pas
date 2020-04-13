unit Server.Logger;

interface

function GetLoggingConfiguration(const ALogFilename: String; const ALogLevel: String): String;

implementation

uses
  SysUtils
, Spring.Logging
, Spring.Logging.Configuration.Builder
, Classes.DailyFileLogAppender
;

{======================================================================================================================}
function GetLoggingConfiguration(const ALogFilename: String; const ALogLevel: String): String;
{======================================================================================================================}
const
  LOG_LEVEL_ERROR = 'ERROR';
  LOG_LEVEL_WARN = 'WARN';
  LOG_LEVEL_INFO = 'INFO';
  LOG_LEVEL_DEBUG = 'DEBUG';
var
  builder: TLoggingConfigurationBuilder;
  logLevels: TLogLevels;
begin
  logLevels := [TLogLevel.Error];
  if SameText(ALogLevel, LOG_LEVEL_WARN) then logLevels := logLevels + [TLogLevel.Warn];
  if SameText(ALogLevel, LOG_LEVEL_INFO) then logLevels := logLevels + [TLogLevel.Warn, TLogLevel.Info];
  if SameText(ALogLevel, LOG_LEVEL_DEBUG) then logLevels := logLevels + [TLogLevel.Warn, TLogLevel.Info, TLogLevel.Debug];

  builder := TLoggingConfigurationBuilder.Create
    .BeginAppender('fileAppender', TDailyFileLogAppender)
      .Enabled(True)
      .Levels(logLevels)
      .EventTypes([
        TLogEventType.Text,
        TLogEventType.Entering,
        TLogEventType.Leaving
      ])
      .Prop('Filename', ALogFilename)
    .EndAppender

    .BeginLogger('default')         // Naming it 'default' enable us to inject it simply tagging a property like [Inject]
    .EndLogger;

//    .BeginLogger('anotherLogger') // 'anotherLogger' will become a container service-name of this logger
//      .Assign('TLogger')          // but only if this begin/end section is not empty!
//    .EndLogger;                   // We can then inject it tagging a property as [Inject('anotherLogger')]

  Result := builder.ToString;
end;

end.

