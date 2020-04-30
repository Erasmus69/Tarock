unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit, CSLabel, Vcl.ExtCtrls,Common.Entities.Card, cxLabel,Common.Entities.Round,
  cxMemo,GamesSelectFra;

const
    CSM_REFRESHCARDS=WM_USER+1;
type
  TCardPosition=(cpMyCards,cpTalon,cpFirstPlayer,cpSecondPlayer,cpThirdPlayer);

  TfrmTarock = class(TForm)
    Button2: TButton;
    pBottom: TPanel;
    clME: TcxLabel;
    pLeft: TPanel;
    clFirstPlayer: TcxLabel;
    pRight: TPanel;
    pTop: TPanel;
    pBoard: TPanel;
    pMyCards: TPanel;
    clThirdPlayer: TcxLabel;
    clSecondPlayer: TcxLabel;
    CSEdit1: TCSEdit;
    Button1: TButton;
    bStartGame: TButton;
    pTalon: TPanel;
    Button4: TButton;
    pFirstplayerCards: TPanel;
    pThirdPlayerCards: TPanel;
    pSecondPlayerCards: TPanel;
    imgSecondCard: TImage;
    imgThirdCard: TImage;
    imgMyCard: TImage;
    imgFirstCard: TImage;
    tRefresh: TTimer;
    bNewRound: TButton;
    mGameInfo: TcxMemo;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BStartGameClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure tRefreshTimer(Sender: TObject);
    procedure bNewRoundClick(Sender: TObject);
  private
    { Private declarations }
    FGameSelect:TfraGameSelect;
    FBetsShownIdx:Integer;

    procedure GetPlayers;
    procedure ShowCards;overload;
    procedure ShowCards(ACards:TCards; APosition:TCardPosition);overload;
    procedure ShowThrow(const ARound:TGameRound);
    procedure ShowTurn;
    procedure DoThrowCard(Sender:TObject);
    procedure GameInfo(const AInfo:String);
    procedure ShowGameSelect;
    procedure ShowBiddingState;
  protected
    procedure WndProc(var Message:TMessage);override;
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Classes.Entities,Classes.CardControl,
  Common.Entities.GameSituation, Common.Entities.GameType;

{$R *.dfm}


const

  MYCARDMOSTTOP=410;
  MYCARDMOSTLEFT=20;
  CARDXOFFSET=90;
  BACKCARDXOFFSET=30;
  CARDYOFFSET=0;

procedure TfrmTarock.Button1Click(Sender: TObject);
begin
  if csEdit1.Text>'' then begin
    try
    //  dm.RegisterPlayer(CSEdit1.Text);
      dm.MyName:=CSEdit1.Text;
    finally
      GetPlayers;
    end;
  end;
end;

procedure TfrmTarock.Button4Click(Sender: TObject);
var c:TCards;
begin
  if pTalon.Visible then
    pTalon.Visible:=False
  else begin
    c:=dm.GetCards('TALON');
    try
      ShowCards(c,cpTalon);
    finally
      FreeAndNil(c);
    end;
  end;
end;

procedure TfrmTarock.DoThrowCard(Sender: TObject);
begin
  if dm.GameSituation.TurnOn=dm.MyName then begin
    dm.PutTurn(TCardControl(Sender).Card.ID);
    dm.MyCards.Find(TCardControl(Sender).Card.ID).Fold:=True;
    PostMessage(Handle,CSM_REFRESHCARDS,0,0);
  end;
end;

procedure TfrmTarock.bNewRoundClick(Sender: TObject);
begin
  dm.NewRound
end;

procedure TfrmTarock.bStartGameClick(Sender: TObject);
begin
  dm.StartNewGame;
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
begin
  dm.MyName:=CSEdit1.Text;
  mGameInfo.Lines.Clear;
  tRefresh.Enabled:=True;
end;

procedure TfrmTarock.GameInfo(const AInfo: String);
begin
  mGameInfo.Lines.Add(AInfo);
end;

procedure TfrmTarock.GetPlayers;
var p:TPlayers;
    itm:TPlayer;
begin
  dm.GetPlayers;
  for itm in dm.Players do begin
    itm.PlayerLabel.Caption:=itm.Name;
  end;
end;

procedure TfrmTarock.ShowCards(ACards: TCards; APosition: TCardPosition);
var i:Integer;
    imgLeft,imgTop:Integer;
    img:TCardControl;
    card:TCard;
    cardParent:TPanel;
    backCardKind:TBackCardKind;
begin

  case APosition of
    cpMyCards:begin
                imgLeft:=(Width-((ACards.Count-1)*CARDXOFFSET)-CARDWIDTH) div 2;
                cardParent:=pMyCards
              end;
    cpTalon:  begin
                cardParent:=pTalon;
                imgLeft:=0;
                pTalon.Visible:=True;
              end;
    cpFirstPlayer:begin
                    cardParent:=pFirstPlayerCards;
                    backCardKind:=bckLeft;
                  end;
    cpSecondPlayer:begin
                    cardParent:=pSecondPlayerCards;
                    backCardKind:=bckDown;
                  end;
    cpThirdPlayer:begin
                    cardParent:=pThirdPlayerCards;
                    backCardKind:=bckRight;
                  end;
  end;

  for i:=cardParent.ControlCount-1 downto 0 do begin
    if cardParent.Controls[i] is TCardControl then
      cardParent.Controls[i].Free
  end;

  if APosition in [cpMyCards,cpTalon] then begin
    for card in ACards do begin
      if not card.Fold then begin
        img:=TCardControl.Create(Self,card);
        img.Parent:=cardParent;
        dm.imCards.GetBitmap(card.ImageIndex,img.Picture.Bitmap);
        img.OnDblClick:=DoThrowCard;
        img.Top:=CARDUPLIFT;
        img.Left:=imgLeft;
        imgLeft:=imgLeft+CARDXOFFSET;
      end;
    end;
  end
  else if APosition=cpSecondPlayer then begin
    imgLeft:=(Width-((ACards.Count-1)*BACKCARDXOFFSET)-CARDWIDTH) div 2;
    for card in ACards do begin
      if not card.Fold then begin
        with TBackCardControl.Create(Self,backCardKind) do begin
          Parent:=cardParent;
          Top:=0;
          Left:=imgLeft;
        end;
        imgLeft:=imgLeft+BACKCARDXOFFSET;
      end;
    end;
  end
  else begin
    imgTop:=(pFirstPlayerCards.Height-((ACards.Count-1)*BACKCARDXOFFSET)-CARDWIDTH) div 2;
    for card in ACards do begin
      if not card.Fold then begin
        with TBackCardControl.Create(Self,backCardKind) do begin
          Parent:=cardParent;
          Top:=imgTop;
          Left:=0;
        end;
        imgTop:=imgTop+BACKCARDXOFFSET;
      end;
    end;
  end;
end;

procedure TfrmTarock.ShowGameSelect;
begin
  FreeAndNil(FGameSelect);

  FGameSelect:=TfraGameSelect.Create(Self);
  FGameSelect.Top:=(pBoard.Height-FGameSelect.Height) div 2;
  FGameSelect.Left:=(pBoard.Width-FGameSelect.Width) div 2;
  FGameSelect.Parent:=pBoard;
  FGameSelect.Show;
end;

procedure TfrmTarock.ShowCards;
begin
  ShowCards(dm.MyCards,cpMyCards);
end;

procedure TfrmTarock.ShowThrow(const ARound:TGameRound);
var itm:TCardThrown;
    player:TPlayer;
begin
  if ARound=nil then Exit;
  
  for itm in ARound.CardsThrown do begin
     player:=dm.Players.Find(itm.PlayerName);
     if itm.Card=None then
        player.CardImage.Picture.Assign(nil)
     else
       dm.imCards.GetBitmap(ALLCARDS.Find(itm.Card).ImageIndex,player.CardImage.Picture.Bitmap);

     if player.Name=ARound.TurnOn then
       player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style+[fsBold]
     else
       player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style-[fsBold]
  end;
end;

procedure TfrmTarock.ShowBiddingState;
var i: Integer;
begin
  for i := FBetsShownIdx+1 to dm.Bets.Count-1 do begin
    if dm.Bets[i].GameTypeID='PASS' then
      GameInfo(Format('%s hat gepasst',[dm.Bets[i].Player]))
    else if dm.Bets[i].GameTypeID='HOLD' then
      GameInfo(Format('%s hat das Spiel aufgenommen',[dm.Bets[i].Player]))
    else
      GameInfo(Format('%s lizitiert %s',[dm.Bets[i].Player,ALLGAMES.Find(dm.Bets[i].GameTypeID).Name]))
  end;
  FBetsShownIdx:=dm.Bets.Count-1;
end;

procedure TfrmTarock.ShowTurn;
var player:TPlayer;
begin
  for player in dm.Players do begin
    if Assigned(dm.GameSituation) and (dm.GameSituation.TurnOn=player.Name) then
      player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style+[fsBold]
    else
      player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style-[fsBold]
  end;
end;

procedure TfrmTarock.tRefreshTimer(Sender: TObject);
  procedure Setup;
  begin
    if not Assigned(dm.Players) or (dm.Players.Count<dm.GameSituation.Players.Count) then
      GetPlayers;

    mGameInfo.Lines.Clear;
    if dm.GameSituation.Players.Count<4 then begin
      GameInfo('Wir warten auf weitere Spieler');

    end
    else
      GameInfo('Starte das Spiel');
  end;

  procedure Bidding;
  begin
    if not Assigned(FGameSelect) then begin
      bStartGame.Enabled:=False;
      mGameInfo.Lines.Clear;
      GameInfo('Neues Spiel gestartet');
      GameInfo(dm.GameSituation.Beginner+' hat die Vorhand');
      ShowGameSelect;
      FBetsShownIdx:=-1;
    end;

    dm.GetBets;
    if FBetsShownIdx<dm.Bets.Count-1 then
      FGameSelect.RefreshGames;
    FGameSelect.CheckMyTurn;
    ShowBiddingState;
    ShowTurn;
  end;

  procedure Playing;
  var r:TGameRound;
  begin
    try
      r:=dm.GetRound;
      if Assigned(r) then begin  // game is started
        if not Assigned(dm.MyCards) then begin
          dm.GetMyCards;
          ShowCards;
        end;
        ShowThrow(r);
        ShowTurn;
      end;
    finally
      r.Free;
    end;
  end;


begin
  tRefresh.Enabled:=False;
  try
    dm.RefreshGameSituation;
    if (dm.GameSituation.State<>gsNone) and not Assigned(dm.Players) then
      Setup;

    case  dm.GameSituation.State  of
      gsNone:   Setup;
      gsBidding:Bidding;
      gsPlaying:Playing;

    end;
  finally
    tRefresh.Enabled:=True;
  end;
end;

procedure TfrmTarock.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg=CSM_REFRESHCARDS then
    ShowCards(dm.MyCards,cpMyCards)
end;

end.
