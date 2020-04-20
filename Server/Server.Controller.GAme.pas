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
begin
  r:=FGame.Rounds.PeekOrDefault;
  if Assigned(r) and not r.Done then
    raise Exception.Create('Prior Round not closed yet')
  else begin
    r:=TGameRound.Create;
    FGame.Rounds.Push(r);

    r.TurnOn:=ABeginner;
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
  begin
    APlayerCards.Cards.Clear;

    for i:=1 to ACount do begin
      r:=Random(ACards.Count);
      itm:=ACards.Extract(ACards.Items[r]);
      APlayerCards.Cards.Add(itm);
    end;
    APlayerCards.Cards.Sort(TCardsComparer.Create)
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

  FGame.ActRound.ThrowCard(ACard);

  if FGame.ActRound.Done then
    Result:=NewRound(GetWinner(FGame.ActRound))
  else
    Result:=NextTurn(FGame.ActRound);
end;

function TGameController.GetWinner(ARound:TGameRound):String;
begin
  //ARound.Winner:='ANDI';
  // Team aktualisieren
  Result:='HANNES';
end;


end.

