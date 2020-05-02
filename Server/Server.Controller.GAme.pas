unit Server.Controller.Game;

interface
uses Server.Entities.Game,
     Common.Entities.Card,
     Common.Entities.Round,
     Common.Entities.Bet;

type
  TGameController=class
  private
    FGame:TGame;
    function DetermineWinner(ACards: TCardsThrown): String;
    function DetermineBetWinner:String;
    function CheckBetTerminated:Boolean;
    procedure CheckGameTerminated;
    function NextPlayer(const APlayerName: String): String;
    function PreviousPlayer(const APlayerName: String): String;
  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
    procedure SetKing(const ACard:TCardKey);
    procedure ChangeCards(const ACards:TCards);

    function NewBet(ABet:TBet):String;
    function FinalBet(const ABet: TBet): String;

    function NewRound:String;
    function Turn(APlayer:String; ACard:TCardKey):String;
    function NextTurn(const ARound:TGameRound):String;

    procedure CloseRound;
  end;

implementation
uses System.SysUtils, System.Generics.Collections,Common.Entities.GameType,
     Common.Entities.Player,Common.Entities.GameSituation, dialogs,
     System.Classes;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
  FGame.Situation.GameInfo.Clear;
  FGame.Situation.GameInfo.Add('Neues Spiel gestartet');
  FGame.Situation.GameInfo.Add(FGame.Situation.Beginner+' hat die Vorhand');
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

  function Match(ADest,ASource:TAddBets):TAddBets;
  begin
    if ASource.Minus10>ADest.Minus10 then
      ADest.Minus10:=ASource.Minus10;
    if ASource.Game>ADest.Game then
      ADest.Game:=ASource.Game;
    if ASource.AllKings>ADest.AllKings then
      ADest.AllKings:=ASource.AllKings;
    if ASource.KingUlt>ADest.KingUlt then
      ADest.KingUlt:=ASource.KingUlt;
    if ASource.PagatUlt>ADest.PagatUlt then
      ADest.PagatUlt:=ASource.PagatUlt;
    if ASource.VogelII>ADest.VogelII then
      ADest.VogelII:=ASource.VogelII;
    if ASource.VogelIII>ADest.VogelIII then
      ADest.VogelIII:=ASource.VogelIII;
    if ASource.VogelIV>ADest.VogelIV then
      ADest.VogelIV:=ASource.VogelIV;
    if ASource.Valat>ADest.Valat then
      ADest.Valat:=ASource.Valat;
    if ASource.Trull>ADest.Trull then
      ADest.Trull:=ASource.Trull;
    if ASource.CatchXXI>ADest.CatchXXI then
      ADest.CatchXXI:=ASource.CatchXXI;
    Result:=ADest;
  end;

  function AddInfo(const ASL:TStringList;const AMessage:String;const APlayer:String; const ABet:TAddBetType):String;
  var s:String;
  begin
    if ABet=abtBet then
      s:=APlayer+' sagt '+AMessage+' an'
    else if ABet=abtContra then
      s:=APlayer+' sagt contra '+AMessage
    else if ABet=abtRe then
      s:=APlayer+' sagt re '+AMessage
    else
      Exit;
    ASL.Add(s);
  end;

var player:TPlayerCards;
    addBets:TAddBets;
    sl:TStringList;
begin
  if FGame.LastFinalBidder='' then
    FGame.LastFinalBidder:=PreviousPlayer(FGame.Situation.Gamer);

  player:=FGame.FindPlayer(ABet.Player);
  if not assigned(player) then
     raise Exception.Create('Unknown Player '+ABet.Player);

  if FGame.Situation.TurnOn<>ABet.Player then
    raise Exception.Create('Is not your turn');

  if player.Team=ttTeam1 then
    FGame.Situation.Team1AddBets:=Match(FGame.Situation.Team1AddBets,ABet.AddBets)
  else
    FGame.Situation.Team2AddBets:=Match(FGame.Situation.Team2AddBets,ABet.AddBets);

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
    AddInfo(sl,'XXI Fang',ABet.Player,ABet.AddBets.CatchXXI);
    AddInfo(sl,'Valat',ABet.Player,ABet.AddBets.Valat);
    AddInfo(sl,'Spiel',ABet.Player,ABet.AddBets.Game);
    if sl.Count>0 then begin
      FGame.LastFinalBidder:=PreviousPlayer(ABet.Player);
      FGame.Situation.GameInfo.AddStrings(sl);
    end
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
    NewRound;
  end
  else
    FGame.Situation.TurnOn:=NextPlayer(ABet.Player);

  Result:=FGame.Situation.TurnOn;
end;

function TGameController.NewRound:String;
var r:TGameRound;
  i: Integer;
begin
  r:=FGame.ActRound;
  if Assigned(r) and not r.Done then
    raise Exception.Create('Prior Round not closed yet')
  else begin
    r:=TGameRound.Create;
    if Assigned(FGame.ActRound) then
      r.TurnOn:=FGame.ActRound.Winner
    else
      r.TurnOn:=FGame.Situation.TurnOn;
    FGame.Situation.TurnOn:=r.TurnOn;

    // reihenfolge der Spieler definieren
    for i := FGame.FindPlayer(r.TurnOn).Index to 3 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].Name));
    for i := 0 to FGame.FindPlayer(r.TurnOn).Index-1 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].Name));
    FGame.Rounds.Push(r);
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
      else
        FGame.Situation.State:=gsFinalBet;
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

  if FGame.ActRound.Done then begin
    CloseRound;
    Result:='The Winner is '+FGame.ActRound.Winner
  end
  else
    Result:='Next Player is '+NextTurn(FGame.ActRound);
end;

procedure TGameController.CloseRound;
begin
  if FGame.ActRound.Done then
    FGame.ActRound.Winner:=DetermineWinner(FGame.ActRound.CardsThrown);

  CheckGameTerminated;
end;

function TGameController.DetermineBetWinner: String;
begin
  Result:=FGame.Bets.First.Player;
end;

function TGameController.DetermineWinner(ACards: TCardsThrown):String;
   function ActCardWins(const AActCard:TCard; const AFormerCard:TCard):Boolean;
    begin
      if not Assigned(AFormerCard) then
        Result:=True
      else if AActCard.CType=AFormerCard.CType then
        Result:=AActCard.Value>AFormerCard.Value
      else
        Result:=AActCard.CType=ctTarock
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
        player.Cards.AddItem(card.ID,card.CType,card.Value,card.ImageIndex);

      forMyTeam:=TGameRound.Create;
      if FGame.ActGame.Talon=tk3Talon then
        forOtherTeam:=TGameRound.Create
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
              FGame.Situation.CardsLayedDown.AddItem(laydown.ID,laydown.CType,laydown.Value,laydown.ImageIndex);
            end;
          end;
          laydown.Free;
        end;
      end;
      player.Cards.Sort;

      FGame.Rounds.Push(forMyTeam);
      if Assigned(forOtherTeam) then
        FGame.Rounds.Push(forOtherTeam);

      FGame.Situation.GameInfo.Add(FGame.Situation.Gamer+' liegt');
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

      if not FGame.ActGame.Positive then
        FGame.Situation.State:=gsFinalBet

      else if FGame.ActGame.Talon<>tkNoTalon then
        FGame.Situation.State:=gsGetTalon
      else
        FGame.Situation.State:=gsFinalBet
    end;
  end;
end;

procedure TGameController.CheckGameTerminated;
begin
  if not FGame.Active then Exit;

  if FGame.PositiveGame and (FGame.Rounds.Count>=12) then
    FGame.Active:=False
  else if not FGame.PositiveGame then begin
//    if FGame.ActRound.Winner then

  end;
  if not FGame.Active then
    FGame.Situation.State:=gsNone;
end;


end.

