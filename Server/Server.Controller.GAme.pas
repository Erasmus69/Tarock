unit Server.Controller.Game;

interface
uses Server.Entities.Game,
     Common.Entities.Card,
     Common.Entities.Round,
     Common.Entities.Bet, Common.Entities.Player;

type
  TGameController=class
  private
    FGame:TGame;
    function DetermineWinner(ACards: TCardsThrown): String;
    function CheckBetTerminated:Boolean;
    procedure CheckGameTerminated;
    function NextPlayer(const APlayerName: String): String;
    function PreviousPlayer(const APlayerName: String): String;
    function CountTricks(const ARounds:TGameRounds; const AGamer:String): Integer;
    procedure CalcResults(AWinner: TTeam);
    procedure CalcSingleResults;
    procedure ShowResults;
    procedure UpdateScore;
    procedure CalcPoints(AGame: TGame);
    procedure DistributeTalon(AGame: TGame);
    function TrickBy(const ACard: TCardKey; const ALastRound: Integer;
      var AWinsByTeam: TTeam): Boolean;

  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
    procedure SetKing(const ACard:TCardKey);
    procedure ChangeCards(const ACards:TCards);

    function NewBet(ABet:TBet):String;
    function FinalBet(const ABet: TBet): String;

    function NewRound(const AIsFirst:Boolean=False): String;
    function Turn(APlayer:String; ACard:TCardKey):String;
    function NextTurn(const ARound:TGameRound):String;

    procedure CloseRound;
  end;

implementation
uses System.SysUtils, System.Generics.Collections,Common.Entities.GameType,
     Common.Entities.GameSituation, dialogs,
     System.Classes;

const EPS=1E-04;
      POINTSTOWIN=35.666-EPS;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
  FGame.Situation.GameInfo.Clear;
  FGame.Situation.GameInfo.Add('Neues Spiel gestartet');
  FGame.Situation.GameInfo.Add(FGame.Situation.Beginner+' hat die Vorhand');
  if FGame.Doubles.Count>0 then begin
    FGame.Situation.Doubles:=FGame.Doubles[0];
    FGame.Doubles.Delete(0);
  end
  else
    FGame.Situation.Doubles:=0;

  if FGame.Situation.Doubles>1 then
    FGame.Situation.GameInfo.Add(Format('Es gelten %d Räder',[FGame.Situation.Doubles]))
  else if FGame.Situation.Doubles=1 then
    FGame.Situation.GameInfo.Add('Es gilt ein Rad');
end;

function TGameController.NewBet(ABet: TBet):String;

  procedure InsertBet(const ABet:TBet);
  var newBet:TBet;
  begin
    newBet:=TBet.Create;
    newBet.Assign(ABet);
    FGame.Bets.Add(newBet);

    if ABet.GameTypeID='PASS' then
      FGame.Situation.GameInfo.Add(Format('%s hat gepasst',[ABet.Player]))
    else if ABet.GameTypeID='HOLD' then
      FGame.Situation.GameInfo.Add(Format('%s hat das Spiel aufgenommen',[ABet.Player]))
    else
      FGame.Situation.GameInfo.Add(Format('%s lizitiert %s',[ABet.Player,ALLGAMES.Find(ABet.GameTypeID).Name]))
  end;

var value:Integer;
    player:TPlayerCards;
    i: Integer;
    game:TGameType;
    actPlayer:String;
begin
  if (ABet.GameTypeID='HOLD') or (ABet.GameTypeid='PASS') then
    value:=0
  else begin
    game:=ALLGAMES.Find(ABet.GameTypeID);
    if Assigned(game) then
      value:=game.Value
    else
      raise Exception.Create('Unknown Game '+ABet.GameTypeID);
  end;

  player:=FGame.FindPlayer(ABet.Player);
  if not assigned(player) then
     raise Exception.Create('Unknown Player '+ABet.Player);

  if FGame.Bets.Count>0 then begin
    if FGame.Situation.TurnOn<>ABet.Player then
      raise Exception.Create('Is not your turn')
    else if ABet.GameTypeID='HOLD' then
      raise Exception.Create('Just first bet can be a HOLD')
    else if player.BetState=btPass then
      raise Exception.Create('You cannot bet anymore')

    else if ABet.GameTypeID='PASS' then
      InsertBet(ABet)
    else begin
      if (value>FGame.Situation.BestBet) or ((value=FGame.Situation.BestBet) and (ABet.Player=FGame.Situation.Beginner)) then begin
        InsertBet(ABet);
        FGame.Situation.BestBet:=value;
        player.BetState:=btBet;
      end
      else
        raise Exception.Create('Your bet must be higher than actual one')
    end;
  end
  else if ABet.Player<>FGame.Situation.Beginner then
    raise Exception.Create('Is not your turn')
  else begin
    InsertBet(ABet);
    FGame.Situation.BestBet:=value;
    if ABet.GameTypeID='HOLD' then
      player.BetState:=btHold
    else
      player.BetState:=btBet;
  end;

  if ABet.GameTypeID='PASS' then
    player.BetState:=btPass;

  if not CheckBetTerminated then begin
    actPlayer:=ABet.Player;
    for i := 1 to 4 do begin
      FGame.Situation.TurnOn:=NextPlayer(actPlayer);

      if FGame.FindPlayer(FGame.Situation.TurnOn).BetState<>btPass then
        Break
      else
        actPlayer:=FGame.Situation.TurnOn;
    end;
  end;

  Result:=FGame.Situation.TurnOn;
end;

function TGameController.FinalBet(const ABet:TBet):String;

  function MergeBets(ASource,ADest:TAddBets; const ASourceTeam:TTeam):TAddBets;
    procedure Merge(const ASourceBet:TAddBet; var ADestBet:TAddBet);
    begin
      if ASourceBet.BetType>ADestBet.BetType then begin
        ADestBet.BetType:=ASourceBet.BetType;
        ADestBet.Team:=ASourceTeam;
      end;
    end;

  begin
    Merge(ASource.Minus10,ADest.Minus10);
    Merge(ASource.ContraGame,ADest.ContraGame);
    Merge(ASource.AllKings,ADest.AllKings);
    Merge(ASource.KingUlt,ADest.KingUlt);
    Merge(ASource.PagatUlt,ADest.PagatUlt);
    Merge(ASource.VogelII,ADest.VogelII);
    Merge(ASource.VogelIII,ADest.VogelIII);
    Merge(ASource.VogelIV,ADest.VogelIV);
    Merge(ASource.Valat,ADest.Valat);
    Merge(ASource.Trull,ADest.Trull);
    Merge(ASource.CatchKing,ADest.CatchKing);
    Merge(ASource.CatchPagat,ADest.CatchPagat);
    Merge(ASource.CatchXXI,ADest.CatchXXI);
    Result:=ADest;
  end;

  function AddInfo(const ASL:TStringList;const AMessage:String;const APlayer:String; const ABet:TAddBet):String;
  var s:String;
  begin
    if ABet.BetType=abtBet then
      s:=APlayer+' sagt '+AMessage+' an'
    else if ABet.BetType=abtContra then
      s:=APlayer+' sagt contra '+AMessage
    else
      Exit;
    ASL.Add(s);
  end;

var player:TPlayerCards;
    sl:TStringList;
begin
  if FGame.LastFinalBidder='' then
    FGame.LastFinalBidder:=PreviousPlayer(FGame.Situation.Gamer);

  player:=FGame.FindPlayer(ABet.Player);
  if not assigned(player) then
     raise Exception.Create('Unknown Player '+ABet.Player);

  if FGame.Situation.TurnOn<>ABet.Player then
    raise Exception.Create('Is not your turn');

  FGame.Situation.AddBets:=MergeBets(ABet.AddBets,FGame.Situation.AddBets,player.Team);

  sl:=TStringList.Create;
  try
    AddInfo(sl,'Sack',ABet.Player,ABet.AddBets.Minus10);
    AddInfo(sl,'König ult',ABet.Player,ABet.AddBets.KingUlt);
    AddInfo(sl,'Pagat ult',ABet.Player,ABet.AddBets.PagatUlt);
    AddInfo(sl,'Vogel II',ABet.Player,ABet.AddBets.VogelII);
    AddInfo(sl,'Vogel III',ABet.Player,ABet.AddBets.VogelIII);
    AddInfo(sl,'Vogel IV',ABet.Player,ABet.AddBets.VogelIV);
    AddInfo(sl,'alle 4 Könige',ABet.Player,ABet.AddBets.AllKings);
    AddInfo(sl,'Trull',ABet.Player,ABet.AddBets.Trull);
    AddInfo(sl,'König Fang',ABet.Player,ABet.AddBets.CatchKing);
    AddInfo(sl,'Pagat Fang',ABet.Player,ABet.AddBets.CatchPagat);
    AddInfo(sl,'XXI Fang',ABet.Player,ABet.AddBets.CatchXXI);
    AddInfo(sl,'Valat',ABet.Player,ABet.AddBets.Valat);
    case ABet.AddBets.ContraGame.BetType of
      abtBet:   sl.Add(ABet.Player+' sagt contra Spiel an');
      abtContra:sl.Add(ABet.Player+' sagt re Spiel an');
    end;

    if sl.Count>0 then begin
      FGame.LastFinalBidder:=PreviousPlayer(ABet.Player);
      FGame.Situation.GameInfo.AddStrings(sl);
    end
    else if ABet.Player=FGame.Situation.Gamer then
      FGame.Situation.GameInfo.Add(ABet.Player+' liegt')
    else
      FGame.Situation.GameInfo.Add(ABet.Player+' sagt weiter');

  finally
    sl.Free;
  end;

  if ABet.Player=FGame.LastFinalBidder then begin
    FGame.Situation.State:=gsPlaying;
    if not FGame.ActGame.Positive then
      FGame.Situation.TurnOn:=FGame.Situation.Gamer
    else
      FGame.Situation.TurnOn:=FGame.Situation.Beginner;
    FGame.Situation.GameInfo.Add(' ');
    FGame.Situation.GameInfo.Add(FGame.Situation.TurnOn+' kommt raus');
    NewRound(True);
  end
  else
    FGame.Situation.TurnOn:=NextPlayer(ABet.Player);

  Result:=FGame.Situation.TurnOn;
end;

function TGameController.NewRound(const AIsFirst:Boolean):String;
var r:TGameRound;
  i: Integer;
begin
  r:=FGame.ActRound;
  if Assigned(r) and not r.Done then
    raise Exception.Create('Prior Round not closed yet')
  else begin
    if AIsFirst then
      FGame.TalonRounds:=FGame.Rounds.Count;  // rounds used by save cards of talon layeddown

    r:=TGameRound.Create;
    if AIsFirst or not Assigned(FGame.ActRound) then
      r.TurnOn:=FGame.Situation.TurnOn
    else
      r.TurnOn:=FGame.ActRound.Winner;
    FGame.Situation.TurnOn:=r.TurnOn;

    // reihenfolge der Spieler definieren
    for i := FGame.FindPlayer(r.TurnOn).Index to 3 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].Name));
    for i := 0 to FGame.FindPlayer(r.TurnOn).Index-1 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].Name));
    FGame.Rounds.Add(r);
  end;

  Result:=r.TurnOn;
end;

function TGameController.NextPlayer(const APlayerName:String):String;
var player:TPlayerCards;
begin
  player:=FGame.FindPlayer(APlayerName);
  if Assigned(player) then
    Result:=FGame.Players[(player.Index+1) mod 4].Name
  else
    raise Exception.Create('Unknown Player '+APlayerName);
end;

function TGameController.NextTurn(const ARound: TGameRound): String;
begin
  ARound.TurnOn:=NextPlayer(ARound.TurnOn);
  FGame.Situation.TurnOn:=ARound.TurnOn;
  Result:=ARound.TurnOn;
end;

function TGameController.PreviousPlayer(const APlayerName: String): String;
var player:TPlayerCards;
begin
  player:=FGame.FindPlayer(APlayerName);
  if Assigned(player) then
    Result:=FGame.Players[(player.Index+3) mod 4].Name
  else
    raise Exception.Create('Unknown Player '+APlayerName);
end;

procedure TGameController.SetKing(const ACard: TCardKey);
  function KingName(const ACard:TCardKey):String;
  begin
    case ACard of
      HK:Result:='Herz-König';
      CK:Result:='Kreuz-König';
      SK:Result:='Pik-König';
      DK:Result:='Karo-König';
    end;
  end;

var player:TPlayerCards;
begin
  if FGame.Situation.State=gsCallKing then begin
    if ACard in [HK,CK,SK,DK] then begin
      FGame.Situation.KingSelected:=ACard;
      FGame.Situation.GameInfo.Add(FGame.Situation.Gamer+' hat den '+KingName(ACard)+' gerufen');

      // Get Teams
      for player in FGame.Players do begin
        if player.Name=FGame.Situation.Gamer then
          player.Team:=ttTeam1
        else if player.Cards.Exists(FGame.Situation.KingSelected) then
           player.Team:=ttTeam1
        else
          player.Team:=ttTeam2;
      end;

      if FGame.ActGame.Talon<>tkNoTalon then
        FGame.Situation.State:=gsGetTalon
      else begin
        DistributeTalon(FGame);
        FGame.Situation.State:=gsFinalBet;
      end
    end
    else
      raise Exception.Create('It is not a king-card');
  end
  else
    raise Exception.Create('you cannot choice a king now');
end;

procedure TGameController.Shuffle;

  procedure IntShuffle(var ACards: TCards; const APlayerCards:TPlayerCards; const ACount: Integer);
  var i,r:Integer;
      itm:TCard;
  begin
    APlayerCards.Cards.Clear;

    for i:=1 to ACount do begin
      r:=Random(ACards.Count);
      itm:=ACards.Extract(ACards.Items[r]);
      APlayerCards.Cards.Add(itm);
    end;
    APlayerCards.Cards.Sort;
  end;

var cards:TCards;
    i:Integer;
begin
  cards:=ALLCARDS.Clone;
  try
    for I := 0 to FGame.Players.Count-1 do
      IntShuffle(cards,FGame.Players[i],12);
    IntShuffle(cards,FGame.Talon,6);
  finally
    cards.Free
  end;
end;

function TGameController.Turn(APlayer: String; ACard: TCardKey):String;
var player:TPlayerCards;
begin
  player:=FGame.FindPlayer(APlayer);
  if not Assigned(player) then
    raise Exception.Create('Player ' +APlayer +' not known');

  if FGame.ActRound.TurnOn<>APlayer then
    raise Exception.Create('Turn is not on ' +APlayer);
  if FGame.ActRound.Done then
    raise Exception.Create('Turn is just complete');

  FGame.ActRound.ThrowCard(APlayer,ACard);
  FGame.Players.Find(APlayer).Cards.Find(ACard).Fold:=True;

  if FGame.ActRound.Done then begin
    CloseRound;
    if Assigned(FGame.ActRound) then
      Result:='The Winner is '+FGame.ActRound.Winner
  end
  else
    Result:='Next Player is '+NextTurn(FGame.ActRound);
end;

procedure TGameController.CloseRound;
var
  c: TCardThrown;
begin
  FGame.ActRound.Winner:=DetermineWinner(FGame.ActRound.CardsThrown);
  FGame.Situation.GameInfo.Add(FGame.ActRound.Winner+' sticht');
  FGame.Situation.TurnOn:=FGame.ActRound.Winner;

  // on Trischaken distribute talon to first 6 tricks
  if (FGame.ActGame.GameTypeid='TRISCH') and (FGame.Talon.Cards.Count>0) then begin
    c:=TCardThrown.Create('TALON');
    c.Card:=FGame.Talon.Cards.First.ID;
    FGame.ActRound.CardsThrown.Add(c);
    FGame.Talon.Cards.Delete(0);
  end;

  CheckGameTerminated;
end;

function TGameController.DetermineWinner(ACards: TCardsThrown):String;
   function ActCardWins(const AActCard:TCard; const AFormerCard:TCard):Boolean;
    begin
      if not Assigned(AFormerCard) then
        Result:=True
      else if AActCard.CType=AFormerCard.CType then
        Result:=AActCard.Value>AFormerCard.Value
      else if not FGame.ActGame.JustColors then
        Result:=AActCard.CType=ctTarock
      else
        Result:=False;
    end;

var c:TCardThrown;
    strongestCard,actCard:TCard;
begin
  if ACards.Exists(T1) and ACards.Exists(T21) and ACards.Exists(T22) then  // whole Trull present
    Result:=ACards.Find(T1).PlayerName       // Pagat wins
  else begin
    strongestCard:=nil;
    for c in ACards do begin
      actCard:=ALLCARDS.Find(c.Card);
      if ActCardWins(actCard,strongestCard) then begin
        Result:=c.PlayerName;
        strongestCard:=actCard;
      end
    end;
  end;
end;

procedure TGameController.ChangeCards(const ACards: TCards);
var player:TPlayerCards;
    otherplayer:String;
    card: TCard;
    cthrown: TCardThrown;
    layDown:TCard;
    forOtherTeam,forMyTeam:TGameRound;
begin
  try
    if FGame.Situation.State=gsGetTalon then begin
      otherPlayer:='';
      for player in FGame.Players do begin
        if player.Team=ttTeam2 then begin
          otherPlayer:=player.Name;
          Break;
        end;
      end;

      player:=FGame.Players.Find(FGame.Situation.Gamer);
      if not Assigned(player) then
        raise Exception.Create('Actual gamer '+FGame.Situation.Gamer+' not found');

      for card in ACards do begin
        if not Card.Fold then begin
          if card.ID in [HK,CK,DK,SK] then
            raise Exception.Create('Kings cannot be layed away')
          else if card.ID in [T1,T21,T22] then
            raise Exception.Create('Trull cannot be layed away');
        end;
      end;

      for card in FGame.Talon.Cards do
        player.Cards.AddItem(card.ID,card.CType,card.Value,card.Points,card.ImageIndex);

      forMyTeam:=TGameRound.Create;
      forMyTeam.Winner:=FGame.Situation.Gamer;
      if FGame.ActGame.Talon=tk3Talon then begin
        forOtherTeam:=TGameRound.Create;
        forOtherTeam.Winner:=otherPlayer;
      end
      else
        forOtherTeam:=Nil;

      for card in ACards do begin
        laydown:=player.Cards.Find(card.ID);

        if Assigned(layDown) then begin
          layDown:=player.Cards.Extract(layDown);

          cthrown:= TCardThrown.Create('');
          cthrown.Card:=laydown.ID;
          if card.Fold and (FGame.ActGame.Talon=tk3Talon)then begin  // cards belongs to other team
            cthrown.PlayerName:=otherplayer;
            forOtherTeam.CardsThrown.Add(cthrown);
            FGame.Talon.Cards.Find(card.ID).Fold:=True;  // sign that belongs to other team
          end
          else begin                                     // cards belongs to my team
            cthrown.PlayerName:=FGame.Situation.Gamer;
            forMyTeam.CardsThrown.Add(cthrown);
            if laydown.CType=ctTarock then begin
              if not Assigned(FGame.Situation.CardsLayedDown) then
                FGame.Situation.CardsLayedDown:=TCards.Create(True);
              FGame.Situation.CardsLayedDown.AddItem(laydown.ID,laydown.CType,laydown.Value,laydown.Points,laydown.ImageIndex);
            end;
          end;
          laydown.Free;
        end;
      end;
      player.Cards.Sort;

      FGame.Rounds.Add(forMyTeam);
      if Assigned(forOtherTeam) then
        FGame.Rounds.Add(forOtherTeam);

      FGame.Situation.State:=gsFinalBet;
    end
    else
      raise Exception.Create('you cannot can cards with talon now');
  finally
  //  ACards.Free;
  end;
end;

function TGameController.CheckBetTerminated: Boolean;

  function WinningGame(ABets:TBets):String;
  var i: Integer;
  begin
    for i:=ABets.Count-1 downto 0  do begin
       if ABets[i].GameTypeID<>'PASS' then begin
         result:=ABets[i].GameTypeID;
         break;
       end;
    end;
  end;

var passed:Smallint;
    player:TPlayerCards;
begin
  Result:=False;
  passed:=0;
  for player in FGame.Players do begin
    if player.BetState=btPass then
      Inc(passed);
  end;

  FGame.Situation.Gamer:='';
  if passed=3 then begin
    for player in FGame.Players do begin
      if player.BetState=btBet then begin
        FGame.Situation.Gamer:=player.Name;

        Result:=True;
        Break;
      end;
    end;
  end;

  if Result then begin
    FGame.ActGame:=ALLGames.Find(WinningGame(FGame.Bets));
    FGame.Situation.GameType:=FGame.ActGame.GameTypeid;
    FGame.Situation.TurnOn:=FGame.Situation.Gamer;
    FGame.Situation.GameInfo.Clear;
    FGame.Situation.GameInfo.Add(FGame.Situation.Gamer+' spielt '+FGame.ActGame.Name);

    if FGame.ActGame.Positive and (FGame.ActGame.TeamKind=tkPair) then
      FGame.Situation.State:=gsCallKing        // teams will be build later
    else begin
      // Get Teams
      for player in FGame.Players do begin
        if player.Name=FGame.Situation.Gamer then
          player.Team:=ttTeam1
        else
          player.Team:=ttTeam2;
      end;

      if not FGame.ActGame.Positive then begin
        FGame.Situation.State:=gsFinalBet;
        FGame.Situation.TurnOn:=NextPlayer(FGame.Situation.Gamer);
      end

      else if FGame.ActGame.Talon<>tkNoTalon then
        FGame.Situation.State:=gsGetTalon
      else begin
        DistributeTalon(FGame);
        FGame.Situation.State:=gsFinalBet
      end;
    end;
  end;
end;

procedure TGameController.DistributeTalon(AGame:TGame);
type TKingFound=(kfNone,kfFirst,kfSecond);

  procedure AssignCards(const APlayerName:String;const AFrom, ATo:Integer);
  var
    cthrown: TCardThrown;
    i: Integer;
    round: TGameRound;
  begin
    round:=TGameRound.Create;
    round.Winner:=APlayerName;

    for i:=AFrom to ATo do begin
      cthrown:= TCardThrown.Create('');
      cthrown.Card:=FGame.Talon.Cards[i].ID;
      cthrown.PlayerName:=APlayerName;
      round.CardsThrown.Add(cthrown);
    end;
    FGame.Rounds.Add(round);
  end;

var otherplayer:String;
    i: Integer;
    player:TPlayerCards;
    kingFound:TKingFound;

begin
  if not AGame.ActGame.Positive or  (AGame.ActGame.Talon<>tkNoTalon) then Exit;

  otherPlayer:='';
  for player in FGame.Players do begin
    if player.Team=ttTeam2 then begin
      otherPlayer:=player.Name;
      Break;
    end;
  end;

  kingfound:=kfNone;
  if (AGame.ActGame.TeamKind=tkPair) then begin
    for i:=0 to FGAme.Talon.Cards.Count-1 do begin
      if FGame.Talon.Cards[i].ID=AGame.Situation.KingSelected then begin
        if i<3 then
          kingFound:=kfFirst
        else
          kingFound:=kfSecond;
        Break;
      end;
    end;
  end;

  if kingFound=kfNone then    //whole talon belongs to enemy
    AssignCards(otherplayer,0,FGame.Talon.Cards.Count-1)

  // if called king stays in Talon half of them belongs to gamer
  else if kingFound=kfFirst then begin
    AssignCards(FGame.Situation.Gamer,0,2);
    AssignCards(otherplayer,3,5);
  end
  else begin
    AssignCards(otherplayer,0,2);
    AssignCards(FGame.Situation.Gamer,3,5);
  end;
end;

procedure TGameController.CheckGameTerminated;
var winner:TTeam;
    allRoundsPlayed:Boolean;
    i,k: Integer;
begin
  if not FGame.Active then Exit;

  allRoundsPlayed:=((FGame.Rounds.Count-FGame.TalonRounds)>=12);
  winner:=ttTeam1;

  case FGame.ActGame.WinCondition of
    wc12Rounds,
    wcT1Trick,
    wcT2Trick,
    wcT3Trick,
    wcT4Trick:begin
                 FGame.Active:=not allRoundsPlayed;
(*                 if FGame.ActRound.CardsThrown.Exists(HK) then
                   FGame.Active:=False;*)
                 if not FGame.Active then begin
                   CalcPoints(FGame);

                   if FGame.ActGame.GameTypeid='TRISCH' then begin
                     winner:=ttTeam2;

                     k:= FGame.Doubles.Count;
                     for i:=0 to k-1 do        // add 4 doubles to next games
                       FGame.Doubles[i]:=FGame.Doubles[i]+1;
                     for i:=1 to 4-k do
                       FGame.Doubles.Add(1);
                   end
                   // player whos says contra must get at least 35 + 2 cards to win even is not the gamer itself
                   else if (FGame.Situation.AddBets.ContraGame.BetType>abtNone) and (FGame.Situation.AddBets.ContraGame.Team=ttTeam2) then begin
                     if FGame.Situation.Team2Results.Points>=POINTSTOWIN then
                       winner:=ttTeam2
                     else
                       winner:=ttTeam1;
                   end
                   else if FGame.Situation.Team1Results.Points>=POINTSTOWIN then
                     winner:=ttTeam1
                   else
                     winner:=ttTeam2;

                   // vogel-game must also be tricked
                   if (winner=ttTeam1) and ( FGame.ActGame.WinCondition<>wc12Rounds) then begin
                     if (FGame.ActGame.WinCondition=wcT1Trick) and TrickBy(T1,FGame.Rounds.Count-1,winner)  then
                     else if (FGame.ActGame.WinCondition=wcT2Trick) and TrickBy(T2,FGame.Rounds.Count-2,winner)then
                     else if (FGame.ActGame.WinCondition=wcT3Trick) and TrickBy(T3,FGame.Rounds.Count-3,winner)then
                     else if (FGame.ActGame.WinCondition=wcT4Trick) and TrickBy(T4,FGame.Rounds.Count-4,winner)then
                     else
                       winner:=ttTeam2;
                   end;
                 end;
               end;
    wc0Trick:  begin
                 if FGame.ActRound.Winner=FGame.Situation.Gamer then begin
                   FGame.Active:=False;
                   winner:=ttTeam2;
                 end
                 else if allRoundsPlayed then begin
                   FGame.Active:=False;
                   winner:=ttTeam1;
                 end;
               end;
    wc1Trick:  begin
                 if (FGame.ActRound.Winner=FGame.Situation.Gamer) and
                    (CountTricks(FGame.Rounds,FGame.Situation.Gamer)>1) then begin
                   FGame.Active:=False;
                   winner:=ttTeam2;
                 end
                 else if allRoundsPlayed then begin
                   FGame.Active:=False;
                   if CountTricks(FGame.Rounds,FGame.Situation.Gamer)=1 then
                     winner:=ttTeam1
                   else
                     winner:=ttTeam2;
                 end;
               end;
    wc2Trick:  begin
                 if (FGame.ActRound.Winner=FGame.Situation.Gamer) and
                    (CountTricks(FGame.Rounds,FGame.Situation.Gamer)>2) then begin
                   FGame.Active:=False;
                   winner:=ttTeam2;
                 end
                 else if allRoundsPlayed then begin
                   FGame.Active:=False;
                   if CountTricks(FGame.Rounds,FGame.Situation.Gamer)=2 then
                     winner:=ttTeam1
                   else
                     winner:=ttTeam2;
                 end;
               end;
  end;

  if not FGame.Active then begin
    FGame.Situation.State:=gsTerminated;
    FGame.Situation.TurnOn:=NextPlayer(FGame.Situation.Beginner);
    FGame.Situation.GameInfo.Clear;
    FGame.Situation.GameInfo.Add('Spiel ist beendet');

    FGame.Situation.GameInfo.Add('======================');
    if FGame.ActGame.WinCondition=wc12Rounds then begin
      FGame.Situation.GameInfo.Add('Das Team1 macht '+FGame.Situation.Team1Results.PointsAsString)
    end;

    if winner=ttTeam1 then begin
      if FGame.ActGame.TeamKind in [tkSolo,tkOuvert] then
        FGame.Situation.GameInfo.Add(FGame.Situation.Gamer+' gewinnt')
      else
        FGame.Situation.GameInfo.Add('Das Team1 ('+FGame.Team1Names+') gewinnt')
    end
    else if FGame.ActGame.GameTypeid='TRISCH' then
      FGame.Situation.GameInfo.Add(FGame.Team1Names+' zahlt an '+FGame.Team2Names)
    else
      FGame.Situation.GameInfo.Add('Das Team2 ('+FGame.Team2Names+') gewinnt');

    if FGame.ActGame.TeamKind<>tkSinglePlayer then
      CalcResults(winner)
    else
      CalcSingleResults;
    ShowResults;
    UpdateScore;
  end;
end;

procedure TGameController.CalcPoints(AGame:TGame);
var
  round: TGameRound;
  team1Points,team2Points:Double;
  player:TPlayerCards;
  existsVirgin:Boolean;

begin
  team1Points:=0;
  team2Points:=0;

  if AGame.ActGame.TeamKind=tkSinglePlayer then begin
    for player in AGame.Situation.Players do begin
      player.Team:=ttNone;
      player.Points:=0;
      player.Results:=0;
    end;
    for round in AGame.Rounds do
      AGame.Situation.Players.Find(round.Winner).Points:=AGame.Situation.Players.Find(round.Winner).Points+round.CardsThrown.TotalValue;

    if AGame.ActGame.GameTypeid='TRISCH' then begin
      existsVirgin:=False;
      for player in AGame.Situation.Players do begin
        if player.Points>team1Points then
          team1Points:=player.Points
        else if player.Points=0 then
          existsVirgin:=True;
      end;

      for player in AGame.Situation.Players do begin
        if Abs(player.Points-team1Points)<EPS then
          player.Team:=ttTeam1           // team1=looser
        else if existsVirgin and (player.Points=0) then  // if exists virgin(s) they take it all
          player.Team:=ttTeam2
        else if not existsVirgin then
          player.Team:=ttTeam2;
      end;
    end;
  end
  else begin
    for round in AGame.Rounds do begin
      AGame.Situation.Players.Find(round.Winner).Points:=AGame.Situation.Players.Find(round.Winner).Points+round.CardsThrown.TotalValue;

      if AGame.TeamOf(round.Winner)=ttTeam1 then
        team1Points:=team1Points+round.CardsThrown.TotalValue
      else
        team2Points:=team2Points+round.CardsThrown.TotalValue
    end;
  end;

  AGame.Situation.Team1Results.SetPoints(team1Points);
  AGame.Situation.Team2Results.SetPoints(team2Points);
end;

procedure TGameController.UpdateScore;
var player:TPlayerCards;
begin
  if FGame.ActGame.TeamKind=tkSinglePlayer then begin
    for player in FGame.Situation.Players do begin
      if FGame.Situation.Doubles>0 then
        player.Score:=player.Score+(player.Results*2*FGame.Situation.Doubles)
      else
        player.Score:=player.Score+player.Results;
      player.Results:=0;
    end;
  end
  else begin
    for player in FGame.Situation.Players do begin
      if FGame.TeamOf(player.Name)=ttTeam1 then
        player.Score:=player.Score+FGame.Situation.Team1Results.GrandTotal
      else
        player.Score:=player.Score+FGame.Situation.Team2Results.GrandTotal
    end;
  end;
end;

procedure TGameController.ShowResults;

  procedure ShowResult(ABet:String;const ATeam1,ATeam2:Integer);overload;
  begin
    if ATeam1=0 then Exit;

    if Length(ABet)<12 then
      ABet:=ABet+StringOfChar(' ',12-Length(ABet));

    FGame.Situation.GameInfo.Add(Format(ABet+' %4d   %4d',[ATeam1,ATeam2]));
  end;

  procedure ShowResult(ABet:String;const ATeam1,ATeam2:Integer;const AAddBet:TAddBet);overload;
  begin
    if ATeam1=0 then Exit;

    if AAddBet.BetType=abtBet then
      ABet:=ABet+'(B)'
    else if AAddBet.BetType=abtContra then
      ABet:=ABet+'(C)';
    ShowResult(ABet,ATeam1,ATeam2);
  end;

var player:TPlayerCards;
  addInfo: string;
begin
  FGame.Situation.GameInfo.Add(         '=========================');

  if FGame.ActGame.TeamKind<>tkSinglePlayer then begin
    FGame.Situation.GameInfo.Add(         '            Team1  Team2');
    ShowResult('Spiel',FGame.Situation.Team1Results.Game,FGame.Situation.Team2Results.Game);
    ShowResult('Valat',FGame.Situation.Team1Results.Valat,FGame.Situation.Team2Results.Valat,FGame.Situation.AddBets.Valat);
    if FGame.Situation.Team1Results.ContraGame<>0 then begin
      if FGame.Situation.AddBets.ContraGame.BetType=abtContra then
        ShowResult('Re Spiel',FGame.Situation.Team1Results.ContraGame,FGame.Situation.Team2Results.ContraGame)
      else
        ShowResult('Contra Spiel',FGame.Situation.Team1Results.ContraGame,FGame.Situation.Team2Results.ContraGame)
    end;
    ShowResult(IntToStr(FGame.Situation.Team1Results.Minus10Count)+' Sack ',FGame.Situation.Team1Results.Minus10,FGame.Situation.Team2Results.Minus10,FGame.Situation.AddBets.Minus10);
    ShowResult('König Ult',FGame.Situation.Team1Results.KingUlt,FGame.Situation.Team2Results.KingUlt,FGame.Situation.AddBets.KingUlt);
    ShowResult('Pagat Ult',FGame.Situation.Team1Results.PagatUlt,FGame.Situation.Team2Results.PagatUlt,FGame.Situation.AddBets.PagatUlt);
    ShowResult('Vogel II',FGame.Situation.Team1Results.VogelII,FGame.Situation.Team2Results.VogelII,FGame.Situation.AddBets.VogelII);
    ShowResult('Vogel III',FGame.Situation.Team1Results.VogelIII,FGame.Situation.Team2Results.VogelIII,FGame.Situation.AddBets.VogelIII);
    ShowResult('Vogel IV',FGame.Situation.Team1Results.VogelIV,FGame.Situation.Team2Results.VogelIV,FGame.Situation.AddBets.VogelIV);
    ShowResult('Alle Könige',FGame.Situation.Team1Results.AllKings,FGame.Situation.Team2Results.AllKings,FGame.Situation.AddBets.AllKings);
    ShowResult('Trull',FGame.Situation.Team1Results.Trull,FGame.Situation.Team2Results.Trull,FGame.Situation.AddBets.Trull);
    ShowResult('König Fang',FGame.Situation.Team1Results.CatchKing,FGame.Situation.Team2Results.CatchKing,FGame.Situation.AddBets.CatchKing);
    ShowResult('Pagat Fang',FGame.Situation.Team1Results.CatchPagat,FGame.Situation.Team2Results.CatchPagat,FGame.Situation.AddBets.CatchPagat);
    ShowResult('XXI Fang',FGame.Situation.Team1Results.CatchXXI,FGame.Situation.Team2Results.CatchXXI,FGame.Situation.AddBets.CatchXXI);
    FGame.Situation.GameInfo.Add(         '=========================');
    ShowResult('Summe',FGame.Situation.Team1Results.Total,FGame.Situation.Team2Results.Total);

    if FGame.Situation.Doubles>0 then begin
      FGame.Situation.GameInfo.Add('');

      if FGame.Situation.Doubles=1 then
        FGame.Situation.GameInfo.Add('Im Radl x 2')
      else
        FGame.Situation.GameInfo.Add(Format('Im %d-fach Radl x %d',[FGame.Situation.Doubles,2*FGame.Situation.Doubles]));
      ShowResult('Totale',FGame.Situation.Team1Results.GrandTotal,FGame.Situation.Team2Results.GrandTotal);
    end;
  end
  else begin
    for player in FGame.Players do begin
      if player.Results<>0 then begin
        addInfo:='';
        if (FGame.ActGame.GameTypeid='TRISCH') then begin
          if player.Points>=POINTSTOWIN then
            addInfo:='(Bürgermeister)'
          else if player.Points=0 then
            addInfo:='(Jungfrau)'
          else if (player.Name=FGame.Situation.Gamer) and (player.Results<0) then
            addInfo:='(Vorhand)'
        end;

        FGame.Situation.GameInfo.Add(Format('%s       %4d  %s',
                   [player.Name+StringOfChar(' ',12-Length(player.Name)),player.Results,addInfo]));

      end;
    end;
    FGame.Situation.GameInfo.Add(         '=========================');
    if FGame.Situation.Doubles>0 then begin
      FGame.Situation.GameInfo.Add('');

      if FGame.Situation.Doubles=1 then
        FGame.Situation.GameInfo.Add(' Im Radl x 2')
      else
        FGame.Situation.GameInfo.Add(Format(' Im %d-fach Radl x %d',[FGame.Situation.Doubles,2*FGame.Situation.Doubles]));
    end;
  end;
end;

function TGameController.TrickBy(const ACard:TCardKey; const ALastRound:Integer; var AWinsByTeam:TTeam):Boolean;
var
  card: TCardThrown;
  round:TGameRound;
begin
  round:=FGame.Rounds.Items[ALastRound];
  AWinsByTeam:=FGame.TeamOf(round.Winner);

  card:=round.CardsThrown.Find(ACard);
  if Assigned(card) then begin
    if (card.PlayerName=round.Winner) then    // card itself tricks
      Result:=true
    else if FGame.TeamOf(card.PlayerName)=AWinsByTeam then  // partner has destroyed the trick
      result:=false
    else           // cath by other team
      Result:=True;
  end
  else
    Result:=false;
end;

procedure TGameController.CalcResults(AWinner:TTeam);

  function AddBet(AValue:Integer; AAddBet:TAddBet;AIsValat:Boolean):Integer;
  begin
    case AAddBet.BetType of
      abtBet:    Result:=AValue*2;
      abtContra: Result:=AValue*4;
     else        if not AIsValat then
                    Result:=AValue
                 else
                   Result:=0;
    end;
  end;

  function IsValat(var AWinsByTeam:TTeam):Boolean;
  var i: Integer;
  begin
    Result:=False;
    AWinsByTeam:=FGame.TeamOf(FGame.Rounds[FGame.TalonRounds].Winner);
    for i :=FGame.TalonRounds+1 to FGame.Rounds.Count-1 do begin
      if FGame.TeamOf(FGame.Rounds[i].Winner)<>AWinsByTeam then
        Exit;
    end;
    Result:=True;
  end;

  function CatchBy(const ACard:TCardKey; var AWinsByTeam:TTeam):Boolean;
  var round:TGameRound;
      card:TCardThrown;
  begin
    Result:=False;
    for round in FGame.Rounds do begin
      if round.CardsThrown.Exists(ACard) then begin
        card:=round.CardsThrown.Find(ACard);
        AWinsByTeam:=FGame.TeamOf(round.Winner);
        Result:=FGame.TeamOf(card.PlayerName)<>AWinsByTeam;
        Break;
      end;
    end;
  end;

  function BelongsTo(const ACard:TCardKey):TTeam;
  var round:TGameRound;
  begin
    Result:=ttTeam1;
    for round in FGame.Rounds do begin
      if round.CardsThrown.Exists(ACard) then begin
        Result:=FGame.TeamOf(round.Winner);
        Break;
      end;
    end;
  end;

  procedure CheckBet(var AResultTeam1:Smallint; const AConditionFullFilled:Boolean;
                     const AWinsByTeam:TTeam;const AValue:Integer;const AAddBet:TAddBet;const AIsValat:Boolean);
  begin
       if AConditionFullFilled then begin
         if AWinsByTeam=ttTeam1 then
           AResultTeam1:=AddBet(AValue,AAddBet,AIsValat)
         else
           AResultTeam1:=-AddBet(AValue,AAddBet,AIsValat);
       end
       else if AAddBet.BetType>abtNone then begin
         if AAddBet.Team=ttTeam1 then
           AResultTeam1:=-(AddBet(AValue,AAddBet,AIsValat))
         else
           AResultTeam1:=AddBet(AValue,AAddBet,AIsValat);
       end;

  end;

var contraGame:Integer;
    team1,team2:TGameResults;
    winsByTeam:TTeam;
    valat:Boolean;
    value: Smallint;
begin
  team1:=Default(TGameResults);
  team2:=Default(TGameResults);
  team1.Points:=FGame.Situation.Team1Results.Points;
  team2.Points:=FGame.Situation.Team2Results.Points;
  team1.Doubles:=FGame.Situation.Doubles;
  team2.Doubles:=FGame.Situation.Doubles;

  if FGame.ActGame.GameTypeid='63' then
    value:=6
  else
    value:=FGame.ActGame.Value;

  contraGame:=AddBet(value,FGame.Situation.AddBets.ContraGame,False)-value;
  case AWinner of
    ttTeam1: begin
               team1.Game:=value;
               team1.ContraGame:=contraGame;
            end;
    else     begin
               if FGame.ActGame.GameTypeid='63' then begin
                 team1.Game:=-value*2;
                 team1.ContraGame:=-contraGame*2;
               end
               else begin
                 team1.Game:=-value;
                 team1.ContraGame:=-contraGame;
               end;
             end;
  end;

  if FGame.ActGame.Positive then begin
     valat:=IsValat(winsByTeam);
     if valat then begin
       if winsByTeam=ttTeam1 then
         team1.Valat:=(AddBet(4,FGame.Situation.AddBets.Valat,False)-1)*team1.Game
       else
         team1.Valat:=-(AddBet(4,FGame.Situation.AddBets.Valat,False)-1)*team1.Game;
     end
     else if FGame.Situation.AddBets.Valat.BetType>abtNone then begin
       if FGame.Situation.AddBets.Valat.Team=ttTeam1 then
         team1.Valat:=-(AddBet(4,FGame.Situation.AddBets.Valat,False)-1)*team1.Game
       else
         team1.Valat:=(AddBet(4,FGame.Situation.AddBets.Valat,False)-1)*team1.Game;
     end;

     if not FGame.ActGame.JustColors then begin
       if FGame.Situation.Team1Results.Points>=POINTSTOWIN+20 then
         team1.Minus10Count:=2
       else if FGame.Situation.Team1Results.Points>=POINTSTOWIN+10 then
         team1.Minus10Count:=1
       else if FGame.Situation.Team1Results.Points<=POINTSTOWIN-20 then
         team1.Minus10Count:=-2
       else if FGame.Situation.Team1Results.Points<=POINTSTOWIN-10 then
         team1.Minus10Count:=-1;

       CheckBet(team1.Minus10,team1.Minus10Count>0 ,ttTeam1,Abs(team1.Minus10Count),FGame.Situation.AddBets.Minus10,valat);
       if FGame.ActGame.WinCondition<>wcT1Trick then
         CheckBet(team1.PagatUlt,TrickBy(T1,FGame.Rounds.Count-1,winsByTeam),winsByTeam,1,FGame.Situation.AddBets.PagatUlt,valat);
       if FGame.ActGame.WinCondition<>wcT2Trick then
         CheckBet(team1.VogelII,TrickBy(T2, FGame.Rounds.Count-2,winsByTeam),winsByTeam,2,FGame.Situation.AddBets.VogelII,valat);
       if FGame.ActGame.WinCondition<>wcT3Trick then
         CheckBet(team1.VogelIII,TrickBy(T3, FGame.Rounds.Count-3,winsByTeam),winsByTeam,3,FGame.Situation.AddBets.VogelIII,valat);
       if FGame.ActGame.WinCondition<>wcT4Trick then
         CheckBet(team1.VogelIV,TrickBy(T4, FGame.Rounds.Count-4,winsByTeam),winsByTeam,4,FGame.Situation.AddBets.VogelIV,valat);

       if (FGame.ActGame.TeamKind=tkPair) then
         CheckBet(team1.KingUlt,FGame.Rounds.Last.CardsThrown.Exists(FGame.Situation.KingSelected),
                  FGame.TeamOf(FGame.Rounds.Last.Winner),1,FGame.Situation.AddBets.KingUlt,valat);

       if not valat then begin
         if FGame.ActGame.TeamKind=tkPair then
           CheckBet(team1.CatchKing,CatchBy(FGame.Situation.KingSelected,winsByTeam),winsByTeam,1,FGame.Situation.AddBets.CatchKing,valat);
         CheckBet(team1.CatchPagat,CatchBy(T1,winsByTeam),winsByTeam,1,FGame.Situation.AddBets.CatchPagat,valat);
         CheckBet(team1.CatchXXI,CatchBy(T21,winsByTeam),winsByTeam,1,FGame.Situation.AddBets.CatchXXI,valat);
         winsByTeam:=BelongsTo(T1);
         CheckBet(team1.Trull,(BelongsTo(T21)=winsByTeam) and (BelongsTo(T22)=winsByTeam),winsByTeam,1,FGame.Situation.AddBets.Trull,valat);

         winsByTeam:=BelongsTo(HK);
         CheckBet(team1.AllKings,(BelongsTo(SK)=winsByTeam) and (BelongsTo(CK)=winsByTeam) and (BelongsTo(DK)=winsByTeam),winsByTeam,1,FGame.Situation.AddBets.AllKings,valat);
       end;
     end;
  end;

  team2.Game:=-team1.Game;
  team2.ContraGame:=-team1.ContraGame;
  team2.Minus10:=-team1.Minus10;
  team2.KingUlt:=-team1.KingUlt;
  team2.PagatUlt:=-team1.PagatUlt;
  team2.VogelII:=-team1.VogelII;
  team2.VogelIII:=-team1.VogelIII;
  team2.VogelIV:=-team1.VogelIV;
  team2.Trull:=-team1.Trull;
  team2.AllKings:=-team1.AllKings;
  team2.CatchKing:=-team1.CatchKing;
  team2.CatchPagat:=-team1.CatchPagat;
  team2.CatchXXI:=-team1.CatchXXI;
  team2.Valat:=-team1.Valat;

  if FGame.ActGame.TeamKind in [tkSolo,tkOuvert] then begin
    team1.Game:=team1.Game*3;
    team1.ContraGame:=team1.ContraGame*3;
    team1.Minus10:=team1.Minus10*3;
    team1.KingUlt:=team1.KingUlt*3;
    team1.PagatUlt:=team1.PagatUlt*3;
    team1.VogelII:=team1.VogelII*3;
    team1.VogelIII:=team1.VogelIII*3;
    team1.VogelIV:=team1.VogelIV*3;
    team1.Trull:=team1.Trull*3;
    team1.AllKings:=team1.AllKings*3;
    team1.CatchKing:=team1.CatchKing*3;
    team1.CatchPagat:=team1.CatchPagat*3;
    team1.CatchXXI:=team1.CatchXXI*3;
    team1.Valat:=team1.Valat*3;
  end;

  FGame.Situation.Team1Results:=team1;
  FGame.Situation.Team2Results:=team2;
end;


procedure TGameController.CalcSingleResults;
var loosers:TPlayers<TPlayerCards>;
    winners:TPlayers<TPlayerCards>;
    player:TPlayerCards;
    totalvalue:Integer;
begin
  if FGame.ActGame.GameTypeid='TRISCH' then begin    // single player count
    loosers:=FGame.PlayersTeam1;  // team1=loosers
    winners:=FGame.PlayersTeam2;  // team2=winners
    try
      totalvalue:=0;
      for player in loosers do begin
        if player.Points>=POINTSTOWIN then  // burgermaster pay twice
          player.Results:=-2*(4-loosers.Count)
        else
          player.Results:=-1*(4-loosers.Count);

        if FGame.Situation.Gamer=player.Name then  //gamer pay twice
          player.Results:=player.Results*2;

        { TODO : contra geht eig pro spieler }
        if FGame.Situation.AddBets.ContraGame.BetType=abtBet then
          player.Results:=player.Results*2;
        totalvalue:=totalvalue+player.Results;
      end;

      for player in winners do
        player.Results:=-Round(totalvalue/winners.Count);

    finally
      FreeAndNil(loosers);
      FreeAndNil(winners);
    end;
  end;
end;


function TGameController.CountTricks(const ARounds:TGameRounds; const AGamer:String):Integer;
var i:Integer;
begin
  Result:=0;
  for i:=0 to ARounds.Count-1 do begin
    if ARounds.Items[i].Winner=AGamer then
      Inc(Result);
  end;
end;

end.

