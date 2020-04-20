unit Common.Entities.Round;

interface
uses Neon.Core.Attributes,
     Common.Entities.Card;

type
  TGameRound=class
  private
    FCardsThrown: TArray<TCardKey>;
    FTurnOn: String;
    function GetDone: Boolean;
  public
    property TurnOn:String read FTurnOn write FTurnOn;
     [NeonInclude(Include.Always)]
    property CardsThrown: TArray<TCardKey> read FCardsThrown write FCardsThrown;
    [NeonIgnore]
    property Done:Boolean read GetDone;

    function Clone:TGameRound;
    procedure ThrowCard(ACard:TCardKey);
  end;

implementation

{ TGameRound }

function TGameRound.Clone: TGameRound;
var i: Integer;
begin
  result:=TGameRound.Create;
  Result.FTurnOn:=FTurnOn;
  SetLength(Result.FCardsThrown,Length(FCardsThrown));
  for i :=0 to High(FCardsThrown) do
    Result.FCardsThrown[i]:=FCardsThrown[i];
end;

function TGameRound.GetDone: Boolean;
begin
  Result:=Length(FCardsThrown)>=4
end;

procedure TGameRound.ThrowCard(ACard: TCardKey);
begin
  SetLength(FCardsThrown,Length(FCardsThrown)+1);
  FCardsThrown[High(FCardsThrown)]:=ACard;
end;

end.
