program Tarock;

uses
  Vcl.Forms,
  TarockFrm in 'TarockFrm.pas' {frmTarock},
  TarockDM in 'TarockDM.pas' {dmTarock: TDataModule},
  Rest.Neon in 'Rest.Neon.pas',
  Classes.Entities in 'Classes.Entities.pas',
  Common.Entities.Card in '..\Common\Common.Entities.Card.pas',
  Classes.CardControl in 'Classes.CardControl.pas',
  Common.Entities.Round in '..\Common\Common.Entities.Round.pas',
  Common.Entities.GameType in '..\Common\Common.Entities.GameType.pas',
  GamesSelectFra in 'GamesSelectFra.pas' {fraGameSelect: TFrame},
  Common.Entities.Gamesituation in '..\Common\Common.Entities.Gamesituation.pas',
  Common.Entities.Player in '..\Common\Common.Entities.Player.pas',
  Common.Entities.Bet in '..\Common\Common.Entities.Bet.pas',
  ConnectionErrorFrm in 'ConnectionErrorFrm.pas' {frmConnectionError};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmTarock, dm);
  Application.CreateForm(TfrmTarock, frmTarock);
  Application.CreateForm(TfrmConnectionError, frmConnectionError);
  Application.Run;
end.
