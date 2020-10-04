unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit, CSLabel, Vcl.ExtCtrls,Common.Entities.Card, cxLabel,Common.Entities.Round,
  cxMemo,GamesSelectFra,KingSelectFra,TalonSelectFra, BiddingFra, ScoreFra,TalonInfoFra,Common.Entities.Player,
  Classes.Entities, hyieutils, iexBitmaps, hyiedefs, iesettings, ieview,
  imageenview, imageen;

const
    CSM_REFRESHCARDS=WM_USER+1;
type
  TfrmTarock = class(TForm)
    Button2: TButton;
    pBottom: TPanel;
    clME: TcxLabel;
    pLeft: TPanel;
    clFirstPlayer: TcxLabel;
    pRight: TPanel;
    pTop: TPanel;
    pMyCards: TPanel;
    clThirdPlayer: TcxLabel;
    clSecondPlayer: TcxLabel;
    bRegister: TButton;
    bStartGame: TButton;
    pFirstplayerCards: TPanel;
    pThirdPlayerCards: TPanel;
    tRefresh: TTimer;
    mGameInfo: TcxMemo;
    cbPlayers: TComboBox;
    pBoard: TPanel;
    pCenter: TPanel;
    pSecondPlayerCards: TPanel;
    pThrowCards: TPanel;
    imgFirstCard: TImage;
    imgSecondCard: TImage;
    imgMyCard: TImage;
    imgThirdCard: TImage;
    imgTalon: TImage;

    procedure bRegisterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BStartGameClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure tRefreshTimer(Sender: TObject);
  private
    { Private declarations }
    FScore:TfraScore;
    FGameSelect:TfraGameSelect;
    FKingSelect:TfraKingSelect;
    FTalonSelect:TfraTalonSelect;
    FBiddingSelect:TfraBidding;
    FTalonInfo:TfraTalonInfo;
    FLastThrowShown:Boolean;
    FThrowActive:Boolean;
    FScalingFactor:Double;

    procedure GetPlayers;
    procedure ClearCards(const AParent:TWinControl);
    procedure ShowCards;overload;
    procedure ShowCards(ACards:TCards; APosition:TCardPosition);overload;
    procedure ShowThrow(const ARound:TGameRound);
    procedure ShowTurn;
    procedure DoThrowCard(Sender:TObject);
    procedure GameInfo;
    procedure ShowGameSelect;
    procedure ShowKingSelect;
    procedure ShowTalon;
    procedure CreateTalonInfo;
    procedure ShowBiddingSelect;
    procedure ClearThrownCards;
    procedure ShowCardOfOthers;
    procedure ScaleCardImages;
    procedure CenterFrame(AFrame:TFrame);
    procedure CenterCards(const APanel: TPanel; AHorizontal:Boolean);
    function GetCardParent(const APosition: TCardPosition): TPanel;
    procedure ShowForbiddenCardsLaysDown;
  protected
    procedure WndProc(var Message:TMessage);override;
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Classes.CardControl,
  Common.Entities.GameSituation, Common.Entities.GameType, ConnectionErrorFrm,
  WiRL.http.Client.Interfaces, RegistrationFrm;

{$R *.dfm}


const

  MYCARDMOSTTOP=410;
  MYCARDMOSTLEFT=20;
  BACKCARDXOFFSET=30;
  CARDYOFFSET=0;
  OTHERCARDPANELHEIGHT=40;


procedure TfrmTarock.bRegisterClick(Sender: TObject);
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
var error:String;
    card:TCard;
begin
  if not FThrowActive then Exit;

  if (dm.GameSituation.State=gsPlaying) and dm.IsMyTurn then begin
    card:=dm.MyCards.Find(TCardControl(Sender).Card.ID);
    if dm.CanThrow(card,error) then begin
      card.Fold:=True;
      dm.PutTurn(TCardControl(Sender).Card.ID);
      PostMessage(Handle,CSM_REFRESHCARDS,0,0);
    end
    else begin
      Beep;
      ShowMessage('Du kannst diese Karte nicht werfen. '+error);
    end;
  end;
end;

procedure TfrmTarock.CenterCards(const APanel: TPanel; AHorizontal:Boolean);
var i:Integer;
    mostLeft: Integer;
    mostRight: Integer;
    offset: Integer;
begin
  mostLeft:=10000;
  mostRight:=0;

  for i:=0 to APanel.ControlCount-1 do begin
    if APanel.Controls[i] is TCardControl then begin
      if AHorizontal then begin
        if APanel.Controls[i].Left<mostLeft then
          mostLeft:=APanel.Controls[i].Left;
        if APanel.Controls[i].Left+APanel.Controls[i].Width>mostRight then
          mostRight:=APanel.Controls[i].Left+APanel.Controls[i].Width;
      end
      else begin
        if APanel.Controls[i].Top<mostLeft then
          mostLeft:=APanel.Controls[i].Top;
        if APanel.Controls[i].Top+APanel.Controls[i].Height>mostRight then
          mostRight:=APanel.Controls[i].Top+APanel.Controls[i].Height;

      end;
    end;
  end;
  if mostLeft=10000 then Exit;

  if AHorizontal then begin
    offset:=((APanel.Width-mostRight+mostleft) div 2)-mostleft;
    for i:=0 to APanel.ControlCount-1 do begin
      if APanel.Controls[i] is TCardControl then
        APanel.Controls[i].Left:=APanel.Controls[i].Left+offset;
    end;
  end
  else begin
    offset:=((APanel.Height-mostRight+mostleft) div 2)-mostleft;
    for i:=0 to APanel.ControlCount-1 do begin
      if APanel.Controls[i] is TCardControl then
        APanel.Controls[i].Top:=APanel.Controls[i].Top+offset;
    end;
  end;
end;

procedure TfrmTarock.CenterFrame(AFrame: TFrame);
begin
  AFrame.Top:=(pBoard.Height-AFrame.Height) div 2;
  AFrame.Left:=(pBoard.Width-AFrame.Width) div 2;
end;

procedure TfrmTarock.ClearCards(const AParent: TWinControl);
var i: Integer;
begin
  for i:=AParent.ControlCount-1 downto 0 do begin
    if AParent.Controls[i] is TCardControl then
      AParent.Controls[i].Free
  end;
end;

procedure TfrmTarock.ClearThrownCards;
var player:TPlayer;
begin
   for player in dm.Players do  // clear last thrown of game before
     player.CardImage.Picture.Assign(nil);
   imgTalon.Picture.Assign(nil);
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

procedure TfrmTarock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tRefresh.Enabled:=false;
  try
//    dm.UnRegisterPlayer;
  except
  end;
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
var
  frm: TfrmRegistration;
  dc:HDC;
//  dpi:Double;
begin
  cbPlayers.Visible:=dm.DebugMode;
  bRegister.Visible:=dm.DebugMode;
  dc:=GetDC(0);
//  dpi:=GetDeviceCaps(dc, LOGPIXELSX)/96;
  FScalingFactor:=GetDeviceCaps(dc, VERTRES)/1080;
  CARDWIDTH:=Round(CARDWIDTH*FScalingFactor);
  CARDHEIGHT:=Round(CARDHEIGHT*FScalingFactor);
  CARDXOFFSET:=Round(CARDXOFFSET*FScalingFactor);
  SMALLCARDWIDTH:=Round(SMALLCARDWIDTH*FScalingFactor);
  SMALLCARDHEIGHT:=Round(SMALLCARDHEIGHT*FScalingFactor);
  SMALLCARDXOFFSET:=Round(SMALLCARDXOFFSET*FScalingFactor);

  mGameInfo.Lines.Clear;
  bStartGame.Enabled:=False;
  TaskCount:=0;
  clFirstPlayer.Caption:='';
  clSecondPlayer.Caption:='';
  clThirdPlayer.Caption:='';
  clME.Caption:='';
  FScore:=TfraScore.Create(Self);
  FScore.Parent:=pBoard;
  FScore.Top:=0;
  FScore.Left:=0;
  FScore.Hide;
  ScaleCardImages;

  if not dm.DebugMode then begin
    frm:=TfrmRegistration.Create(self);
    try
      if frm.ShowModal<>mrOk then begin
        Application.Terminate;
        Exit;
      end;
    finally
      frm.Free
    end;
  end;
  tRefresh.Enabled:=True;
end;

procedure TfrmTarock.FormResize(Sender: TObject);
begin
  if Assigned(FGameSelect) and FGameSelect.Visible then begin
    FGameSelect.Height:=400;
    CenterFrame(FGameSelect);
    if FGameSelect.Top+FGameSelect.Height>pMyCards.Top then
      FGameSelect.Top:=pMyCards.Top-FGameSelect.Height;
    if FgameSelect.Top<pSecondPlayerCards.height then begin
      FGameSelect.Height:=pCenter.Height;
      FGameSelect.Top:=pSecondPlayerCards.Height;
    end;
  end;

  if Assigned(FTalonSelect) and FTalonSelect.Visible then
    CenterFrame(FTalonSelect);
  if Assigned(FBiddingSelect) and FBiddingSelect.Visible then
    CenterFrame(FBiddingSelect);
  if Assigned(FKingSelect) and FKingSelect.Visible then
    CenterFrame(FKingSelect);

  pThrowCards.Top:=(pCenter.Height-pSecondPlayerCards.Height-pThrowCards.Height) div 2+pSecondPlayerCards.Height;
  pThrowCards.Left:=(pCenter.Width-pThrowCards.Width) div 2;

  CenterCards(pMyCards,True);
  if Assigned(dm.ActGame) and (dm.ActGame.TeamKind in [tkOuvert,tkAllOuvert]) then begin
    CenterCards(pFirstPlayerCards,False);
    CenterCards(pSecondPlayerCards,True);
    CenterCards(pThirdPlayerCards,False);
  end;

  if Assigned(FTalonInfo) then begin
    FTalonInfo.Top:=pMyCards.Top-FTalonInfo.Height;
    FTalonInfo.Left:=pBoard.Width-FTalonInfo.Width;
  end;
end;

procedure TfrmTarock.GameInfo;
begin
  if mGameInfo.Lines.Text<>dm.GameSituation.GameInfo.Text then begin
    mGameInfo.Lines.Assign(dm.GameSituation.GameInfo);
    SendMessage(mGameInfo.InnerControl.Handle,EM_LINESCROLL,0,mGameInfo.Lines.Count-1);
  end;
end;

procedure TfrmTarock.GetPlayers;
var itm:TPlayer;
begin
  dm.GetPlayers;
  for itm in dm.Players do begin
    itm.PlayerLabel.Caption:=itm.Name;
  end;
end;

procedure TfrmTarock.ScaleCardImages;
begin
  imgFirstCard.Height:=CARDHEIGHT;
  imgFirstCard.Width:=CARDWIDTH;
  imgSecondCard.Height:=CARDHEIGHT;
  imgSecondCard.Width:=CARDWIDTH;
  imgThirdCard.Height:=CARDHEIGHT;
  imgThirdCard.Width:=CARDWIDTH;
  imgMyCard.Height:=CARDHEIGHT;
  imgMyCard.Width:=CARDWIDTH;
  imgTalon.Height:=CARDHEIGHT;
  imgTalon.Width:=CARDWIDTH;

  imgFirstCard.Top:=imgSecondCard.Height div 2 +imgSecondCard.Top;
  imgThirdCard.Top:=imgFirstCard.Top;
  imgMyCard.Top:=imgSecondCard.Top+imgSecondCard.Height+30;
  imgTalon.Top:=imgMyCard.Top;
  pMyCards.Height:=CARDHEIGHT+CARDUPLIFT;
  pThrowCards.Height:=CARDHEIGHT*2+CARDUPLIFT;

  FormResize(Self);
end;

procedure TfrmTarock.ShowBiddingSelect;
begin
  FreeAndNil(FBiddingSelect);

  FBiddingSelect:=TfraBidding.Create(Self);
  FBiddingSelect.Parent:=pBoard;
  CenterFrame(FBiddingSelect);
  FBiddingSelect.Show;
end;

procedure TfrmTarock.ShowForbiddenCardsLaysDown;
begin
  dm.RefreshGameSituation;
  if not Assigned(FTalonInfo) and (dm.ActGame.Talon<>tkNoTalon) and
     Assigned(dm.GameSituation.CardsLayedDown) and (dm.GameSituation.CardsLayedDown.Count>0) then begin
    CreateTalonInfo;
    FTalonInfo.lCaption.Caption:=dm.GameSituation.Gamer+' hat abgelegt';
    FTalonInfo.ShowCards(dm.GameSituation.CardsLayedDown);
  end;
end;

procedure TfrmTarock.ShowCards(ACards: TCards; APosition: TCardPosition);
type TCardAlignment=(caUp,caLeft,caRight);

  function CreateCardControl(ACard:TCard; AParent:TWinControl; AAlignment:TCardAlignment; ASmall:Boolean=False):TCardControl;
  var imageen: TImageEn;
  begin
    Result:=TCardControl.Create(Self,ACard);
    Result.Parent:=AParent;
    if AAlignment=caUp then begin
      if ASmall then begin
        Result.Height:=SMALLCARDHEIGHT;
        Result.Width:=SMALLCARDWIDTH;
      end
      else begin
        Result.Height:=CARDHEIGHT;
        Result.Width:=CARDWIDTH;
      end;
      dm.imCards.GetBitmap(ACard.ImageIndex,Result.Picture.Bitmap);
    end
    else begin
      if ASmall then begin
        Result.Width:=SMALLCARDHEIGHT;
        Result.Height:=SMALLCARDWIDTH;
      end
      else begin
        Result.Width:=CARDHEIGHT;
        Result.Height:=CARDWIDTH;
      end;

      imageen:=TImageEn.Create(nil);
      try
        dm.imCards.GetBitmap(ACard.ImageIndex,imageen.Bitmap);
        if AAlignment=caLeft then
          imageen.Proc.Rotate(90)
        else
          imageen.Proc.Rotate(-90);

        Result.Picture.Bitmap:=imageen.Bitmap;

      finally
        imageen.Free;
      end;
    end;
  end;

var imgLeft,imgTop:Integer;
    img:TCardControl;
    card:TCard;
    cardParent:TPanel;
begin
  cardParent:=GetCardParent(APosition);
  ClearCards(cardParent);

  if APosition in [cpMyCards] then begin
    imgLeft:=(Width-((ACards.UnFoldCount-1)*CARDXOFFSET)-CARDWIDTH) div 2;
    imgLeft:=imgLeft-(CARDXOFFSET div 2);

    for card in ACards do begin
      if not card.Fold then begin
        img:=CreateCardControl(card,cardParent,caUp);
        img.OnDblClick:=DoThrowCard;
        img.Top:=CARDUPLIFT;
        img.Left:=imgLeft;
        imgLeft:=imgLeft+CARDXOFFSET;
      end;
    end;
  end
  else if APosition=cpSecondPlayer then begin
    imgLeft:=(Width-((ACards.UnFoldCount-1)*SMALLCARDXOFFSET)-SMALLCARDWIDTH) div 2;
    for card in ACards do begin
      if not card.Fold then begin
        img:=CreateCardControl(card,cardParent,caUp,True);
        img.Top:=0;
        img.Left:=imgLeft;
        imgLeft:=imgLeft+SMALLCARDXOFFSET;
        img.Enabled:=False;
      end;
    end;
  end
  else begin
    imgTop:=(pFirstPlayerCards.Height-((ACards.UnFoldCount-1)*SMALLCARDXOFFSET)-SMALLCARDWIDTH) div 2;
    for card in ACards do begin
      if not card.Fold then begin
        if APosition=cpFirstPlayer then
          img:=CreateCardControl(card,cardParent,caLeft,True)
        else
          img:=CreateCardControl(card,cardParent,caRight,True);
        img.Top:=imgTop;
        img.Left:=0;
        imgTop:=imgTop+SMALLCARDXOFFSET;
        img.Enabled:=False;
      end;
    end;
  end;
  (*  else if APosition=cpSecondPlayer then begin
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
  end;*)
end;

procedure TfrmTarock.ShowGameSelect;
begin
  FreeAndNil(FGameSelect);
  FGameSelect:=TfraGameSelect.Create(Self);
  FGameSelect.Parent:=pBoard;
  CenterFrame(FGameSelect);
  FGameSelect.Show;
end;

procedure TfrmTarock.ShowKingSelect;
begin
  FreeAndNil(FKingSelect);

  FKingSelect:=TfraKingSelect.Create(Self);
  FKingSelect.Parent:=pBoard;
  CenterFrame(FKingSelect);
  FKingSelect.Show;
end;

procedure TfrmTarock.ShowCards;
begin
  ShowCards(dm.MyCards,cpMyCards);
  CenterCards(pMyCards,True);
end;

procedure TfrmTarock.ShowCardOfOthers;
var player:TPlayer;
    cards:TCards;
begin
  if not (dm.ActGame.TeamKind in [tkOuvert,tkAllOuvert]) then Exit;

  mGameinfo.Visible:=False;
  FScore.Visible:=false;

  for player in dm.Players do begin
    if (player.Name<>dm.MyName) and
       ((dm.ActGame.TeamKind=tkAllOuvert) or (player.Name=dm.GameSituation.Gamer)) then begin

      if player.CardPosition=cpSecondPlayer then
        GetCardParent(player.CardPosition).Height:=SMALLCARDHEIGHT
      else
        GetCardParent(player.CardPosition).Width:=SMALLCARDHEIGHT;

      cards:=dm.GetCards(player.Name);
      try
        ShowCards(cards,player.CardPosition);
      finally
        cards.Free;
      end;
    end;
  end;
  FormResize(Self);
end;

procedure TfrmTarock.ShowTalon;
var i: Integer;
begin
  FreeAndNil(FTalonSelect);

  FTalonSelect:=TfraTalonSelect.Create(Self);
  FTalonSelect.Parent:=pBoard;
  CenterFrame(FTalonSelect);
  FTalonSelect.Show;

  for i:=0 to pMyCards.ControlCount-1 do begin
    if pMyCards.Controls[i] is TCardControl then begin
      TCardControl(pMyCards.Controls[i]).RemainUp:=True;
      TCardControl(pMyCards.Controls[i]).Up:=False;
    end;
  end;
end;

procedure TfrmTarock.CreateTalonInfo;
begin
  FreeAndNil(FTalonInfo);

  FTalonInfo:=TfraTalonInfo.Create(Self);
  FTalonInfo.Parent:=pBoard;
  FTalonInfo.Top:=pMyCards.Top-FTalonInfo.Height;
  FTalonInfo.Left:=pBoard.Width-FTalonInfo.Width;
end;

procedure TfrmTarock.ShowThrow(const ARound:TGameRound);
var itm:TCardThrown;
    player:TPlayer;
begin
  if ARound=nil then Exit;
  imgTalon.Picture.Assign(nil);

  for itm in ARound.CardsThrown do begin
     if itm.PlayerName='TALON' then
       dm.imCards.GetBitmap(ALLCARDS.Find(itm.Card).ImageIndex,imgTalon.Picture.Bitmap)
     else begin
       player:=dm.Players.Find(itm.PlayerName);
       if itm.Card=None then
          player.CardImage.Picture.Assign(nil)
       else
         dm.imCards.GetBitmap(ALLCARDS.Find(itm.Card).ImageIndex,player.CardImage.Picture.Bitmap);
     end;
  end;

  if Assigned(dm.ActGame) and (dm.ActGame.TeamKind in [tkOuvert,tkAllOuvert]) and (dm.GameSituation.RoundNo>1) then
    ShowCardOfOthers;
end;

procedure TfrmTarock.ShowTurn;
var player:TPlayer;
begin
  for player in dm.Players do begin
    if Assigned(dm.GameSituation) and (dm.GameSituation.TurnOn=player.Name) then begin
      player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style+[fsBold];
      player.PlayerLabel.Style.Color:=clSkyBlue;
    end
    else begin
      player.PlayerLabel.Style.Font.Style:=player.PlayerLabel.Style.Font.Style-[fsBold];
      player.PlayerLabel.Style.Color:=clBtnFace;
    end;
  end;
end;

function TfrmTarock.GetCardParent(const APosition:TCardPosition):TPanel;
begin
  case APosition of
    cpMyCards:     Result:=pMyCards ;
    cpFirstPlayer: Result:=pFirstPlayerCards;
    cpSecondPlayer:Result:=pSecondPlayerCards;
    cpThirdPlayer: Result:=pThirdPlayerCards;
  end;
end;

procedure TfrmTarock.tRefreshTimer(Sender: TObject);
  procedure SetScore(const ALabel:TcxLabel; const AScore:Smallint);
  begin
    ALabel.Caption:=IntToStr(AScore);
    if AScore<0 then
      ALabel.Style.Font.Color:=clRed
    else
      ALabel.Style.Font.Color:=clBlack;
  end;

  procedure ShowScore;
  begin
    if not FScore.Visible then begin
      FScore.clPlayer1.Caption:=dm.GameSituation.Players[0].Name;
      FScore.clPlayer2.Caption:=dm.GameSituation.Players[1].Name;
      FScore.clPlayer3.Caption:=dm.GameSituation.Players[2].Name;
      FScore.clPlayer4.Caption:=dm.GameSituation.Players[3].Name;
      SetScore(FScore.clScore1,dm.GameSituation.Players[0].Score);
      SetScore(FScore.clScore2,dm.GameSituation.Players[1].Score);
      SetScore(FScore.clScore3,dm.GameSituation.Players[2].Score);
      SetScore(FScore.clScore4,dm.GameSituation.Players[3].Score);

      FScore.Show;
    end;
  end;

  procedure Setup;
  begin
    if not Assigned(dm.Players) or (dm.Players.Count<dm.GameSituation.Players.Count) then
      GetPlayers;

    if (dm.GameSituation.State>gsNone) then
      ShowScore;

    FThrowActive:=False;
    if dm.GameSituation.State<>gsNone then begin
      if not Assigned(dm.MyCards) then begin
         dm.GetMyCards;

         if Assigned(dm.ActGame) and (dm.ActGame.GameTypeid='TRISCH') then
           pThrowCards.Width:=imgTalon.Left+imgTalon.Width
         else
           pThrowCards.Width:=imgThirdCard.Left+imgThirdCard.Width;
         FormResize(Self);
      end;
      ShowCards;
    end
    else if dm.Players.Count=4 then
      bStartGame.Enabled:=True;
  end;

  procedure Bidding;
  begin
    ShowScore;

    if not Assigned(FGameSelect) then begin
      bStartGame.Enabled:=False;
      FLastThrowShown:=False;
      ClearThrownCards;
      FreeAndnil(FTalonInfo);

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
      FreeAndNil(FGameSelect);
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

    if not Assigned(FTalonSelect) and ((dm.ActGame.GameTypeid<>'63') or dm.IAmGamer) then
      ShowTalon;
  end;

  procedure FinalBidding;
  begin
    ShowActGame;
    FreeAndNil(FKingSelect);
    if Assigned(FTalonSelect) then begin
      FreeAndNil(FTalonSelect);
      if (dm.MyName=dm.GameSituation.Gamer) then begin
        dm.GetMyCards;
        ShowCards;
      end;
    end;
    if not Assigned(FBiddingSelect) then
      ShowBiddingSelect;

    if (dm.MyName<>dm.GameSituation.Gamer) and not Assigned(FTalonInfo) then begin
      ShowForbiddenCardsLaysDown;
    end;


    FBiddingSelect.CheckMyTurn;
  end;

  procedure Playing;
  var r:TGameRound;
  begin
    if Assigned(FBiddingSelect) then begin
      FreeAndnil(FBiddingSelect);
      if Assigned(dm.ActGame) and (dm.ActGame.GameTypeid='TRISCH') then
        pThrowCards.Width:=imgTalon.Left+imgTalon.Width
      else
        pThrowCards.Width:=imgThirdCard.Left+imgThirdCard.Width;
      FormResize(Self);
    end;
    if Assigned(FTalonInfo) then
      FreeAndnil(FTalonInfo);
    FThrowActive:=True;

    r:=dm.GetRound;
    try
      if Assigned(r) then begin  // game is started
        ShowThrow(r);

        if r.Done and dm.IsMyTurn then begin
          FThrowActive:=False;
          Application.ProcessMessages;
          Sleep(2000);
          dm.NewRound;
          FThrowActive:=True;
        end;
      end;

    finally
      r.Free;
    end;
  end;

  procedure GameTerminated;
  var r:TGameRound;
  begin
    mGameInfo.Visible:=true;
    FScore.Visible:=True;
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
      if dm.ActGame.TeamKind in [tkOuvert,tkAllOuvert] then begin
        pFirstPlayerCards.Width:=OTHERCARDPANELHEIGHT;
        pSecondPlayerCards.Height:=OTHERCARDPANELHEIGHT;
        pThirdPlayerCards.Width:=OTHERCARDPANELHEIGHT;
        ClearCards(pFirstPlayerCards);
        ClearCards(pSecondPlayerCards);
        ClearCards(pThirdPlayerCards);
      end;
    end;

    if (dm.ActGame.Talon=tkNoTalon) and not Assigned(FTalonInfo) then begin
     CreateTalonInfo;
     FTalonInfo.ShowCards(dm.GetCards('TALON'));
    end;


    SetScore(FScore.clScore1,dm.GameSituation.Players[0].Score);
    SetScore(FScore.clScore2,dm.GameSituation.Players[1].Score);
    SetScore(FScore.clScore3,dm.GameSituation.Players[2].Score);
    SetScore(FScore.clScore4,dm.GameSituation.Players[3].Score);
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
      on E:EWiRLSocketException do begin
        tRefresh.Enabled:=False;
        dm.ReactiveServerConnection;
      end;
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

procedure TfrmTarock.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg=CSM_REFRESHCARDS then
    ShowCards(dm.MyCards,cpMyCards)
end;

end.
