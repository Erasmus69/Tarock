program Tarock;

uses
  Vcl.Forms,
  TarockFrm in 'TarockFrm.pas' {frmTarock},
  TarockDM in 'TarockDM.pas' {dmTarock: TDataModule},
  Rest.Neon in 'Rest.Neon.pas',
  Classes.Entities in 'Classes.Entities.pas',
  Server.Entities.Card in '..\Server\Server.Entities.Card.pas',
  Server.Entities.Game in '..\Server\Server.Entities.Game.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmTarock, dm);
  Application.CreateForm(TfrmTarock, frmTarock);
  Application.Run;
end.
