unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit, CSLabel, Vcl.ExtCtrls,Common.Entities.Card, cxLabel,Common.Entities.Round,
  cxMemo,GamesSelectFra,KingSelectFra,TalonSelectFra, BiddingFra;

const
    CSM_REFRESHCARDS=WM_USER+1;
type
  TCardPosition=(cpMyCards,cpFirstPlayer,cpSecondPlayer,cpThirdPlayer);

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
    Button1: TButton;
    bStartGame: TButton;
    pFirstplayerCards: TPanel;
    pThirdPlayerCards: TPanel;
    pSecondPlayerCards: TPanel;
    imgSecondCard: TImage;
    imgThirdCard: TImage;
    imgMyCard: TImage;
    imgFirstCard: TImage;
    tRefresh: TTimer;
    mGameInfo: TcxMemo;
    cbPlayers: TComboBox;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BStartGameClick(Sender: TObject);
    procedure tRefreshTimer(Sender: TObject);
  private
    { Private declarations }
    FGameSelect:TfraGameSelect;
    FKingSelect:TfraKingSelect;
    FTalonSelect:TfraTalonSelect;
    FBiddingSelect:TfraBidding;
    FLastThrowShown:Boolean;

    procedure GetPlayers;
    procedure ShowCards;overload;
    procedure ShowCards(ACards:TCards; APosition:TCardPosition);overload;
    procedure ShowThrow(const ARound:TGameRound);
    procedure ShowTurn;
    procedure DoThrowCard(Sender:TObject);
    procedure GameInfo;
    procedure ShowGameSelect;
    procedure ShowKingSelect;
    procedure ShowTalon;
    procedure ShowBiddingSelect;
    procedure ReactiveServerConnection;
    procedure ClearThrownCards;
  protected
    procedure WndProc(var Message:TMessage);override;
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Common.Entities.Player,Classes.Entities,Classes.CardControl,
  Common.Entities.GameSituation, Common.Entities.GameType, ConnectionErrorFrm,
  WiRL.http.Client.Interfaces;

{$R *.dfm}


const

  MYCARDMOSTTOP=410;
  MYCARDMOSTLEFT=20;
  CARDXOFFSET=90;
  BACKCARDXOFFSET=30;
  CARDYOFFSET=0;

procedure TfrmTarock.Button1Click(Sender: TObject);
begin
  if cbPlayers.ItemIndex>=0 then begin
    try
      dm.MyName:=cbPlayers.Items[cbPlayers.ItemIndex];
      dm.RegisterPlayer(dm.MyName);
      FreeAndNil(FTalonSelect);

    finally
      GetPlayers;
    end;
  end;
end;

procedure TfrmTarock.DoThrowCard(Sender: TObject);
begin
  if (dm.GameSituation.State=gsPlaying) and dm.IsMyTurn then begin
    dm.PutTurn(TCardControl(Sender).Card.ID);
    dm.MyCards.Find(TCardControl(Sender).Card.ID).Fold:=True;
    PostMessage(Handle,CSM_REFRESHCARDS,0,0);
  end;
end;

procedure TfrmTarock.ClearThrownCards;
var player:TPlayer;
begin
   for player in dm.Players do  // clear last thrown of game before
     player.CardImage.Picture.Assign(nil);
end;

procedure TfrmTarock.bStartGameClick(Sender: TObject);
begin
  dm.StartNewGame;
  bStartGame.Enabled:=False;
end;

var TaskCount:Integer;
function EnumWindowsProc(hWnd: HWND; lParam: LPARAM): Bool;stdCall;
var
  Capt: PWideChar;
begin
  GetMem(Capt,255);
  GetWindowText(hWnd, Capt,Sizeof(capt)-1);
  if Capt='Tarock' then
    Inc(TaskCount);
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
begin
  mGameInfo.Lines.Clear;
  tRefresh.Enabled:=True;
  bStartGame.Enabled:=False;
  TaskCount:=0;
//  EnumWindows(@EnumWindowsProc, 0);
(*
  case TaskCount of
    0:   dm.MyName:='ANDI';
    1:   dm.MyName:='HANNES';
    2:   dm.MyName:='WOLFGANG';
    3:   dm.MyName:='LUKI';
    else Halt;
  end;
showmessage(dm.MyName);
  dm.RegisterPlayer(dm.MyName);  *)
  dm.GetPlayers;

end;

procedure TfrmTarock.GameInfo;
begin
  mGameInfo.Lines.Assign(dm.GameSituation.GameInfo);
  SendMessage(mGameInfo.InnerControl.Handle,EM_LINESCROLL,0,mGameInfo.Lines.Count-1);
end;

procedure TfrmTarock.GetPlayers;
var itm:TPlayer;
begin
  dm.GetPlayers;
  for itm in dm.Players do begin
    itm.PlayerLabel.Caption:=itm.Name;
  end;
end;

procedure TfrmTarock.ShowBiddingSelect;
begin
  FreeAndNil(FBiddingSelect);

  FBiddingSelect:=TfraBidding.Create(Self);
  FBiddingSelect.Top:=(pBoard.Height-FBiddingSelect.Height) div 2;
  FBiddingSelect.Left:=(pBoard.Width-FBiddingSelect.Width) div 2;
  FBiddingSelect.Parent:=pBoard;
  FBiddingSelect.Show;
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
                imgLeft:=imgLeft-(CARDXOFFSET div 2);
                cardParent:=pMyCards
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

  if APosition in [cpMyCards] then begin
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

procedure TfrmTarock.ShowKingSelect;
begin
  FreeAndNil(FKingSelect);

  FKingSelect:=TfraKingSelect.Create(Self);
  FKingSelect.Top:=(pBoard.Height-FKingSelect.Height) div 2;
  FKingSelect.Left:=(pBoard.Width-FKingSelect.Width) div 2;
  FKingSelect.Parent:=pBoard;
  FKingSelect.Show;
end;

procedure TfrmTarock.ShowCards;
begin
  ShowCards(dm.MyCards,cpMyCards);
end;

procedure TfrmTarock.ShowTalon;
var i: Integer;
begin
  FreeAndNil(FTalonSelect);

  FTalonSelect:=TfraTalonSelect.Create(Self);
  FTalonSelect.Top:=(pBoard.Height-FTalonSelect.Height) div 2;
  FTalonSelect.Left:=(pBoard.Width-FTalonSelect.Width) div 2;
  FTalonSelect.Parent:=pBoard;
  FTalonSelect.Show;

  for i:=0 to pMyCards.ControlCount-1 do begin
    if pMyCards.Controls[i] is TCardControl then begin
      TCardControl(pMyCards.Controls[i]).RemainUp:=True;
      TCardControl(pMyCards.Controls[i]).Up:=False;
    end;
  end;
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
    end;
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

    if dm.GameSituation.State<>gsNone then begin
      if not Assigned(dm.MyCards) then
         dm.GetMyCards;
      ShowCards;
    end
    else if dm.Players.Count=4 then
      bStartGame.Enabled:=True;
  end;

  procedure Bidding;
  begin
    if not Assigned(FGameSelect) then begin
      bStartGame.Enabled:=False;
      FLastThrowShown:=False;
      ClearThrownCards;

      dm.GetMyCards;
      ShowCards;
      ShowGameSelect;
    end;

    dm.GetBets;
    FGameSelect.RefreshGames;
    FGameSelect.CheckMyTurn;
  end;

  procedure ShowActGame;
  begin
    if Assigned(FGameSelect) and Assigned(dm.ActGame) then begin
  //   GameInfo(dm.GameSituation.Gamer+' spielt '+dm.ActGame.Name);
      FreeAndNil(FGameSelect);
//      FViewSelectedKing:=False;
    end;
  end;

  procedure CallingKing;
  begin
    ShowActGame;
    if (dm.MyName=dm.GameSituation.Gamer) and not Assigned(FKingSelect) then
      ShowKingSelect;
  end;

  procedure GettingTalon;
  begin
    ShowActGame;
    FreeAndNil(FKingSelect);

    if not Assigned(FTalonSelect) then
      ShowTalon;
  end;

  procedure FinalBidding;
  begin
    ShowActGame;
    if Assigned(FTalonSelect) then begin
      FreeAndNil(FTalonSelect);
      if (dm.MyName=dm.GameSituation.Gamer) then begin
        dm.GetMyCards;
        ShowCards;
      end;
    end;
    if not Assigned(FBiddingSelect) then
      ShowBiddingSelect;
    FBiddingSelect.CheckMyTurn;
  end;

  procedure Playing;
  var r:TGameRound;
  begin
    if Assigned(FBiddingSelect) then
      FreeAndnil(FBiddingSelect);

    r:=dm.GetRound;
    try
      if Assigned(r) then begin  // game is started
        ShowThrow(r);

        if r.Done and dm.IsMyTurn then begin
          Application.ProcessMessages;
          Sleep(3000);
          dm.NewRound;
        end;
      end;

    finally
      r.Free;
    end;
  end;

  procedure GameTerminated;
  var r:TGameRound;
  begin
    if not FLastThrowShown then begin
      r:=dm.GetRound;
      try
        if Assigned(r) then begin //show last cards thrown
          ShowThrow(r);
          FLastThrowShown:=True;
        end;
      finally
        r.Free;
      end;
    end;
    bStartGame.Enabled:=True;
  end;


begin
  tRefresh.Enabled:=False;

  try
    if dm.MyName='' then exit;
    try
      dm.RefreshGameSituation;
      GameInfo;
      if not Assigned(dm.Players) then
        Setup;

      ShowTurn;

      case  dm.GameSituation.State  of
        gsNone:   Setup;
        gsBidding:Bidding;
        gsCallKing:CallingKing;
        gsGetTalon:GettingTalon;
        gsFinalBet:FinalBidding;
        gsPlaying:Playing;
        gsTerminated:GameTerminated;
      end;
    except
      on E:EWiRLSocketException do
        ReactiveServerConnection;
      on E:EInvalidCast do begin
        if E.Message='SS' then Beep;

      end;
      on E:Exception do
        Showmessage(E.ClassName+' '+E.Message);

    end;
  finally
    tRefresh.Enabled:=True;
  end;
end;

procedure TfrmTarock.ReactiveServerConnection;
var frm:TfrmConnectionError;
  i: Integer;
begin
  tRefresh.Enabled:=False;
  frm:=TfrmConnectionError.Create(Self);
  try
    frm.Show;
    while True do begin
      for i :=0 to 50 do begin
        Sleep(100);
        Application.ProcessMessages;
      end;

      try
        dm.RefreshGameSituation;
        Break;
      except
        on E:EWiRLSocketException do
        else
          Raise;
      end;
    end;
  finally
    FreeAndNil(frm);
  end;
end;

procedure TfrmTarock.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg=CSM_REFRESHCARDS then
    ShowCards(dm.MyCards,cpMyCards)
end;

end.
