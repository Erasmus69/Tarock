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

  public
    property Player:String read FPlayer write FPlayer;
    property GameTypeID:String read FGameTypeID write FGameTypeID;
//    [NeonIgnore]
    property AddBets:TAddBets read FAddBets write FAddBets;

    procedure Assign(const ASource:TBet);
  end;

  TBets=class(TObjectList<TBet>)
  public
    function Clone:TBets;
    function AllPassed:Boolean;
  end;

implementation

{ TBets }

function TBets.AllPassed: Boolean;
var
  itm: TBet;
begin
  result:=True;
  for itm in Self do begin
    if (itm.GameTypeID<>'HOLD') and (itm.GameTypeid<>'PASS') then begin
      Result:=False;
      Break;
    end;
  end;
end;

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
  AddBets:=ASource.AddBets;
end;

end.
