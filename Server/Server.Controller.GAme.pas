unit Server.Controller.Game;

interface
uses Server.Entities.Game,
     Common.Entities.Card,
     Common.Entities.Round;

type
  TGameController=class
  private
    FGame:TGame;
    function GetWinner(ARound: TGameRound): String;

  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
    function NewRound(const ABeginner:String):String;
    function Turn(APlayer:String; ACard:TCardKey):String;
    function NextTurn(const ARound:TGameRound):String;
  end;

implementation
uses System.SysUtils, System.Generics.Collections;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
end;

function TGameController.NewRound(const ABeginner:String):String;
var r:TGameRound;
  i: Integer;
begin
  r:=FGame.Rounds.PeekOrDefault;
  if Assigned(r) and not r.Done then
    raise Exception.Create('Prior Round not closed yet')
  else begin
    r:=TGameRound.Create;
    r.TurnOn:=ABeginner;

    // reihenfolge der Spieler definieren
    for i := FGame.FindPlayer(ABeginner).Index to 3 do
      r.CardsThrown.Add(TCardThrown.Create(FGame.Players[i].PlayerName));
    for i := 0 to FGame.FindPlayer(ABeginner).Index-1 do
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

  if FGame.ActRound.Done then
    Result:='NONE' //NewRound(GetWinner(FGame.ActRound))
  else
    Result:=NextTurn(FGame.ActRound);
end;

function TGameController.GetWinner(ARound:TGameRound):String;
begin
  //ARound.Winner:='ANDI';
  // Team aktualisieren
  Result:='ANDI';
end;


end.

