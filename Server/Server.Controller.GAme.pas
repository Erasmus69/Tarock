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
begin
  cards:=ALLCARDS.Clone;
  try
    IntShuffle(cards,FGame.Player1,12);
    IntShuffle(cards,FGame.Player2,12);
    IntShuffle(cards,FGame.Player3,12);
    IntShuffle(cards,FGame.Player4,12);
    IntShuffle(cards,FGame.Talon,6);
  finally
    cards.Free
  end;
end;

end.

