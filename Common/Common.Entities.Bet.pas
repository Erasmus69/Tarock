unit Common.Entities.Bet;

interface
uses Neon.Core.Attributes,Generics.Collections;

type
  TAddBets=record
    Contra:Boolean;
    Minus10:Boolean;
    Trull:Boolean;
    PagatUlt:Boolean;
  end;

  TBet=class(TObject)
  private
    FPlayer: String;
    FGameTypeID: String;
    FAddBets: TAddBets;
    FTurnOn: String;
    FBestBet: Smallint;

  public
    property Player:String read FPlayer write FPlayer;
    property GameTypeID:String read FGameTypeID write FGameTypeID;
//    [NeonIgnore]
    property AddBets:TAddBets read FAddBets write FAddBets;
    property TurnOn:String read FTurnOn write FTurnOn;
    property BestBet:Smallint read FBestBet write FBestBet;

    procedure Assign(const ASource:TBet);
  end;

  TBets=class(TObjectList<TBet>)
  public
    function Clone:TBets;
  end;

implementation

{ TBets }

function TBets.Clone: TBets;
var bets:TBets;
    bet:TBet;
    i:Integer;
begin
  bets:=TBets.Create(True);
  for i:=0 to Count-1 do begin
    bet:=TBet.Create;
    bet.Assign(Items[i]);
    bets.Add(bet);
  end;
  Result:=bets;
end;

{ TBet }

procedure TBet.Assign(const ASource: TBet);
begin
  Player:=ASource.Player;
  GameTypeID:=ASource.GameTypeID;
  TurnOn:=ASource.TurnOn;
  BestBet:=ASource.BestBet;
  AddBets:=ASource.AddBets;
end;

end.
