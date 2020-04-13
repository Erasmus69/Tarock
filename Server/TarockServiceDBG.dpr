program TarockServiceDBG;

{$IF CompilerVersion >= 33.0}  // XE10.3 RIO
{$R 'WIRLSERVERTEMPLATEDBG_VI.RES' 'WIRLSERVERTEMPLATEDBG_VI.RC'}
{$IFEND}

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {FrmMain},
  Server.Register in 'Server.Register.pas',
  Server.Logger in 'Server.Logger.pas',
  Server.Configuration in 'Server.Configuration.pas',
  Classes.DailyFileLogAppender in 'Classes.DailyFileLogAppender.pas',
  Server.WiRL in 'Server.WiRL.pas',
  Classes.Dataset.Helpers in 'Classes.Dataset.Helpers.pas',
  Server.Entities in 'Server.Entities.pas',
  Server.Controller in 'Server.Controller.pas',
  Server.Resources in 'Server.Resources.pas',
  Server.Repository in 'Server.Repository.pas',
  Server.Wirl.Response in 'Server.Wirl.Response.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
