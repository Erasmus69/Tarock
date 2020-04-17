unit Server.Controller.Game;

interface
uses Server.Entities.Game;

type
  TGameController=class
  private
    FGame:TGame;

  public
    constructor Create(AGame:TGame);
    procedure Shuffle;
  end;

implementation
uses System.Generics.Collections,Server.Entities.Card;

constructor TGameController.Create(AGame: TGame);
begin
  inherited Create;
  FGame:=AGame;
end;

procedure TGameController.Shuffle;


  procedure IntShuffle(var ACards: TCards; const APlayerCards:TPlayerCards; const ACount: Integer);
  var i,r:Integer;
      key:TCardKey;
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

end.

