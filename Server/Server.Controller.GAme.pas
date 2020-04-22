unit Server.Controller.Game;

interface
uses Server.Entities.Game,
     Common.Entities.Card,
     Common.Entities.Round;

type
  TGameController=class
  private
    FGame:TGame;
    function DetermineWinner(ACards: TCardsThrown): String;
    procedure CheckGameTerminated;
  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
    function NewRound:String;
    function Turn(APlayer:String; ACard:TCardKey):String;
    function NextTurn(const ARound:TGameRound):String;
    procedure CloseRound;
  end;

implementation
uses System.SysUtils, System.Generics.Collections;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
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
      r.TurnOn:=FGame.Beginner;

    // reihenfolge der Spieler definieren
    for i := FGame.FindPlayer(r.TurnOn).Index to 3 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].PlayerName));
    for i := 0 to FGame.FindPlayer(r.TurnOn).Index-1 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].PlayerName));
    FGame.Rounds.Push(r);
  end;

  Result:=r.TurnOn;
end;

function TGameController.NextTurn(const ARound: TGameRound): String;
var actPlayer:TPlayerCards;
begin
  actPlayer:=FGame.FindPlayer(ARound.TurnOn);
  ARound.TurnOn:=FGame.Players[(actPlayer.Index+1) mod 4].PlayerName;
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

procedure TGameController.CheckGameTerminated;
begin
  if not FGame.Active then Exit;

  if FGame.PositiveGame and (FGame.Rounds.Count>=12) then
    FGame.Active:=False
  else if not FGame.PositiveGame then begin
//    if FGame.ActRound.Winner then

  end;

end;


end.

