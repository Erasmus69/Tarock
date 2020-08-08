unit BiddingFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, cxLabel, Vcl.ExtCtrls,Common.Entities.Player,
  Common.Entities.Bet;

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
    bPagatFang: TcxButton;
    bKingFang: TcxButton;
    procedure bBetClick(Sender: TObject);
  private
    { Private declarations }
    FMyTeam: TTeam;
    procedure SetBet(AButton: TcxButton; ABet: TAddBet);
    function FixButtonStatus: Boolean;
  public
    { Public declarations }
    procedure CheckMyTurn;
    constructor Create(AOwner:TComponent);override;
  end;

implementation

uses
  TarockDM, Common.Entities.GameType;

{$R *.dfm}

procedure TfraBidding.bBetClick(Sender: TObject);
var b:TBet;
    addBets:TAddBets;
  i: Integer;
begin
  b:=TBet.Create;
  b.Player:=dm.MyName;
  b.GameTypeid:='';
  addBets:=Default(TAddBets);
  if bSack.Enabled then
    addBets.Minus10.BetType:=TAddBetType(Integer(bSack.Down)+bSack.Tag);
  if bAllKings.Enabled then
    addBets.AllKings.BetType:=TAddBetType(Integer(bAllKings.Down)+bAllKings.Tag);
  if bKingUlt.Enabled then
    addBets.KingUlt.BetType:=TAddBetType(Integer(bKingUlt.Down)+bKingUlt.Tag);
  if bTrull.Enabled then
    addBets.Trull.BetType:=TAddBetType(Integer(bTrull.Down)+bTrull.Tag);
  if bPagatUlt.Enabled then
    addBets.PagatUlt.BetType:=TAddBetType(Integer(bPagatUlt.Down)+bPagatUlt.Tag);
  if bVogel2.Enabled then
    addBets.VogelII.BetType:=TAddBetType(Integer(bVogel2.Down)+bVogel2.Tag);
  if bVogel3.Enabled then
    addBets.VogelIII.BetType:=TAddBetType(Integer(bVogel3.Down)+bVogel3.Tag);
  if bVogel4.Enabled then
    addBets.VogelIV.BetType:=TAddBetType(Integer(bVogel4.Down)+bVogel4.Tag);
  if bGame.Enabled then
    addBets.ContraGame.BetType:=TAddBetType(Integer(bGame.Down)+bGame.Tag);
  if bKingFang.Enabled then
    addBets.CatchKing.BetType:=TAddBetType(Integer(bKingFang.Down)+bKingFang.Tag);
  if bPagatFang.Enabled then
    addBets.CatchPagat.BetType:=TAddBetType(Integer(bPagatFang.Down)+bPagatFang.Tag);
  if bXXIFang.Enabled then
    addBets.CatchXXI.BetType:=TAddBetType(Integer(bXXIFang.Down)+bXXIFang.Tag);
  if bValat.Enabled then
    addBets.Valat.BetType:=TAddBetType(Integer(bValat.Down)+bValat.Tag);
  b.AddBets:=addBets;

  dm.NewBet(b);

  for i := 0 to pBackGround.ControlCount-1 do begin
    if pBackGround.Controls[i] is TcxButton then
      TcxButton(pBackGround.Controls[i]).Down:=False;
  end;
end;

procedure TfraBidding.SetBet(AButton:TcxButton; ABet:TAddBet);
begin
  if AButton.Tag<0 then Exit;

  if ABet.BetType=abtRe then
    AButton.Enabled:=false
  else if (ABet.BetType>abtNone) and (ABet.Team=FMyTeam) then
    AButton.Enabled:=False
  else begin
    AButton.Enabled:=True;
    AButton.Tag:=Ord(ABet.BetType);
  end;
  if (ABet.BetType=abtBet) and (Copy(AButton.Caption,1,6)<>'Contra') then
    AButton.Caption:='Contra '+AButton.Caption
  else if ABet.BetType>=abtContra then begin
    if Copy(AButton.Caption,1,6)='Contra' then
      AButton.Caption:='Re '+Copy(AButton.Caption,8,Length(AButton.Caption))
    else if Copy(AButton.Caption,1,2)<>'Re' then
      AButton.Caption:='Re '+AButton.Caption;
  end;
end;

procedure TfraBidding.CheckMyTurn;
begin
  bBet.Enabled:=dm.GameSituation.TurnOn=dm.MyName;
  if dm.GameSituation.TurnOn=dm.MyName then
    lCaption.Caption:='Möchtest du bieten ?'
  else
    lCaption.Caption:=dm.GameSituation.TurnOn+' ist an der Reihe';

  if (dm.GameSituation.AddBets.ContraGame.BetType=abtNone) and (FMyTeam=ttTeam1) then
    bGame.Enabled:=False
  else
    SetBet(bGame, dm.GameSituation.AddBets.ContraGame);

  SetBet(bSack, dm.GameSituation.AddBets.Minus10);
  SetBet(bKingUlt, dm.GameSituation.AddBets.KingUlt);
  if (dm.GameSituation.AddBets.KingUlt.BetType<abtBet) and (FMyTeam=ttTeam2) then
    bKingUlt.Enabled:=False;

  SetBet(bAllKings, dm.GameSituation.AddBets.AllKings);
  SetBet(bTrull, dm.GameSituation.AddBets.Trull);
  SetBet(bPagatUlt, dm.GameSituation.AddBets.PagatUlt);
  SetBet(bVogel2, dm.GameSituation.AddBets.VogelII);
  SetBet(bVogel3, dm.GameSituation.AddBets.VogelIII);
  SetBet(bVogel4, dm.GameSituation.AddBets.VogelIV);
  SetBet(bKingFang, dm.GameSituation.AddBets.CatchKing);
  if (dm.GameSituation.AddBets.CatchKing.BetType<abtBet) and (FMyTeam=ttTeam1) then
    bKingFang.Enabled:=False;

  SetBet(bPagatFang, dm.GameSituation.AddBets.CatchPagat);
  SetBet(bXXIFang, dm.GameSituation.AddBets.CatchXXI);
  SetBet(bValat, dm.GameSituation.AddBets.Valat);
end;

constructor TfraBidding.Create(AOwner: TComponent);
begin
  inherited;

  FMyTeam:=dm.GameSituation.Players.Find(dm.MyName).Team;
  if not dm.ActGame.Positive then begin
    bSack.Enabled:=False;
    bAllKings.Enabled:=False;
    bTrull.Enabled:=False;
    bPagatUlt.Enabled:=False;
    bVogel2.Enabled:=False;
    bVogel3.Enabled:=False;
    bVogel4.Enabled:=False;
    bPagatFang.Enabled:=False;
    bXXIFang.Enabled:=False;
    bValat.Enabled:=False;
  end
  else if dm.ActGame.JustColors then begin
    bSack.Enabled:=False;
    bAllKings.Enabled:=False;
    bTrull.Enabled:=False;
    bPagatUlt.Enabled:=False;
    bVogel2.Enabled:=False;
    bVogel3.Enabled:=False;
    bVogel4.Enabled:=False;
    bPagatFang.Enabled:=False;
    bXXIFang.Enabled:=False;
  end
  else begin
    case dm.ActGame.WinCondition of
      wcT1Trick: bPagatUlt.Enabled:=False;
      wcT2Trick: bVogel2.Enabled:=False;
      wcT3Trick: bVogel3.Enabled:=False;
      wcT4Trick: bVogel4.Enabled:=False;
    end;
  end;

  bKingFang.Enabled:=(dm.ActGame.TeamKind=tkPair);
  bKingUlt.Enabled:=(dm.ActGame.TeamKind=tkPair);
  if FixButtonStatus then
    bBetClick(self);
end;

function TfraBidding.FixButtonStatus:Boolean;
var i: Integer;
begin
  Result:=True;
  for i:=0 to pBackground.ControlCount-1 do begin
    if (pBackground.Controls[i] is TcxButton) then begin
      if not TcxButton(pBackground.Controls[i]).Enabled then
        TcxButton(pBackground.Controls[i]).Tag:=-1
      else if pBackground.Controls[i]<>bBet then
        Result:=false;
    end;
  end;
end;

end.
