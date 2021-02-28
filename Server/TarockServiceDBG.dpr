program TarockServiceDBG;
  (*
{$IF CompilerVersion >= 33.0}  // XE10.3 RIO
{$R 'WIRLSERVERTEMPLATEDBG_VI.RES' 'WIRLSERVERTEMPLATEDBG_VI.RC'}
{$IFEND} *)

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {FrmMain},
  Server.Register in 'Server.Register.pas',
  Server.Logger in 'Server.Logger.pas',
  Server.Configuration in 'Server.Configuration.pas',
  Classes.DailyFileLogAppender in 'Classes.DailyFileLogAppender.pas',
  Server.WiRL in 'Server.WiRL.pas',
  Classes.Dataset.Helpers in 'Classes.Dataset.Helpers.pas',
  Common.Entities.Player in '..\Common\Common.Entities.Player.pas',
  Server.Controller in 'Server.Controller.pas',
  Server.Resources in 'Server.Resources.pas',
  Server.Repository in 'Server.Repository.pas',
  Server.Wirl.Response in 'Server.Wirl.Response.pas',
  Common.Entities.Card in '..\Common\Common.Entities.Card.pas',
  Server.DataModule in 'Server.DataModule.pas' {dm: TDataModule},
  Server.Controller.GAme in 'Server.Controller.GAme.pas',
  Common.Entities.Round in '..\Common\Common.Entities.Round.pas',
  Common.Entities.GameType in '..\Common\Common.Entities.GameType.pas',
  Common.Entities.Bet in '..\Common\Common.Entities.Bet.pas',
  Common.Entities.Gamesituation in '..\Common\Common.Entities.Gamesituation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
  Common.Entities.Card.TearDown;
  Common.Entities.GameType.TearDown;
end.
