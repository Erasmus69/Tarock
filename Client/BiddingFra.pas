unit BiddingFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, cxLabel, Vcl.ExtCtrls;

type
  TfraBidding = class(TFrame)
    pBackground: TPanel;
    lCaption: TcxLabel;
    bSack: TcxButton;
    bKingUlt: TcxButton;
    bPagatUlt: TcxButton;
    bVogel4: TcxButton;
    bGame: TcxButton;
    bTrull: TcxButton;
    bAllKings: TcxButton;
    bXXIFang: TcxButton;
    bValat: TcxButton;
    bBet: TcxButton;
    bVogel3: TcxButton;
    bVogel2: TcxButton;
    procedure bBetClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    procedure CheckMyTurn;
  end;

implementation

uses
  Common.Entities.Bet, TarockDM;

{$R *.dfm}

procedure TfraBidding.bBetClick(Sender: TObject);
var b:TBet;
    addBets:TAddBets;
  i: Integer;
begin
  b:=TBet.Create;
  b.Player:=dm.MyName;
  b.GameTypeid:='';
  addBets.Minus10:=TAddBetType(bSack.Down);
  addBets.AllKings:=TAddBetType(bAllKings.Down);
  addBets.KingUlt:=TAddBetType(bKingUlt.Down);
  addBets.Trull:=TAddBetType(bTrull.Down);
  addBets.PagatUlt:=TAddBetType(bPagatUlt.Down);
  addBets.VogelII:=TAddBetType(bVogel2.Down);
  addBets.VogelIII:=TAddBetType(bVogel3.Down);
  addBets.VogelIV:=TAddBetType(bVogel4.Down);
  addBets.Game:=TAddBetType(bGame.Down);
  addBets.CatchXXI:=TAddBetType(bXXIFang.Down);
  addBets.Valat:=TAddBetType(bValat.Down);
  b.AddBets:=addBets;

  dm.NewBet(b);

  for i := 0 to ControlCount-1 do begin
    if Controls[i] is TcxButton then
      TcxButton(Controls[i]).Down:=False;
  end;
end;

procedure TfraBidding.CheckMyTurn;
begin
  bBet.Enabled:=dm.GameSituation.TurnOn=dm.MyName;
  if dm.GameSituation.TurnOn=dm.MyName then
    lCaption.Caption:='Möchtest du bieten ?'
  else
    lCaption.Caption:=dm.GameSituation.TurnOn+' ist an der Reihe';
end;

end.
