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

  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
    function NewBet(ABet:TBet):String;
    function NewRound:String;
    function Turn(APlayer:String; ACard:TCardKey):String;
    function NextTurn(const ARound:TGameRound):String;
    procedure CloseRound;
  end;

implementation
uses System.SysUtils, System.Generics.Collections,Common.Entities.GameType,
     Common.Entities.Player,Common.Entities.GameSituation;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
end;

function TGameController.NewBet(ABet: TBet):String;

  procedure InsertBet(const ABet:TBet; ABestBet:SmallInt);
  var newBet:TBet;
  begin
    newBet:=TBet.Create;
    newBet.Assign(ABet);
    newBet.BestBet:=ABestBet;
    FGame.Bets.Add(newBet);
  end;

var actBet:TBet;
    value:Integer;
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
    actBet:=FGame.Bets.Last;

    if actBet.TurnOn<>ABet.Player then
      raise Exception.Create('Is not your turn')
    else if ABet.GameTypeID='HOLD' then
      raise Exception.Create('Just first bet can be a HOLD')
    else if player.BetState=btPass then
      raise Exception.Create('You cannot bet anymore')

    else if ABet.GameTypeID='PASS' then
      InsertBet(ABet,actBet.BestBet)
    else begin
      if (value>actBet.BestBet) or ((value=actBet.BestBet) and (ABet.Player=FGame.Situation.Beginner)) then begin
        InsertBet(ABet,value);
        player.BetState:=btBet;
      end
      else
        raise Exception.Create('Your bet must be higher than actual one')
    end;
  end
  else if ABet.Player<>FGame.Situation.Beginner then
    raise Exception.Create('Is not your turn')
  else begin
    InsertBet(ABet,value);
    if ABet.GameTypeID='HOLD' then
      player.BetState:=btHold;
  end;

  if ABet.GameTypeID='PASS' then
    player.BetState:=btPass;

  if not CheckBetTerminated then begin
    actPlayer:=ABet.Player;
    for i := 1 to 4 do begin
      ABet.TurnOn:=NextPlayer(actPlayer);

      if FGame.FindPlayer(ABet.TurnOn).BetState<>btPass then
        Break
      else
        actPlayer:=ABet.TurnOn;
    end;
  end
  else
    ABet.TurnOn:='NONE';

  FGame.Bets.Last.TurnOn:=ABet.TurnOn;
  Result:=ABet.TurnOn;
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
      r.TurnOn:=FGame.Situation.Starter;

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

procedure TGameController.Shuffle;

  procedure IntShuffle(var ACards: TCards; const APlayerCards:TPlayerCards; const ACount: Integer);
  var i,r:Integer;
      itm:TCard;
      comp:TCardsComparer;
  begin
    APlayerCards.Cards.Clear;

    for i:=1 to ACount do begin
      r:=Random(ACards.Count);
      itm:=ACards.Extract(ACards.Items[r]);
      APlayerCards.Cards.Add(itm);
    end;
    comp:=TCardsComparer.Create;
    try
      APlayerCards.Cards.Sort(comp)
    finally
      comp.Free;
    end;
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

function TGameController.CheckBetTerminated: Boolean;
var passed:Smallint;
    player:TPlayerCards;
    winningPlayer:String;
begin
  Result:=False;
  passed:=0;
  for player in FGame.Players do begin
    if player.BetState=btPass then
      Inc(passed);
  end;

  winningPlayer:='';
  if passed=3 then begin
    for player in FGame.Players do begin
      if player.BetState=btBet then begin
        winningPlayer:=player.Name;
        Result:=True;
        Break;
      end;
    end;
  end;

  if Result then begin
    FGame.Situation.Starter:=winningPlayer;//DetermineBetWinner;
    FGame.Situation.State:=gsBet;
   // FGame.Beginner:=winningPlayer;
    NewRound;
    FGame.Situation.State:=gsPlaying;
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

