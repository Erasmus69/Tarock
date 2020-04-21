unit Common.Entities.Round;

interface
uses Neon.Core.Attributes,
     Generics.Collections,
     Common.Entities.Card;

type
  TCardThrown=class
  private
    FPlayerName:String;
    FCard:TCardKey;
  public
    property PlayerName:String read FPlayerName write FPlayerName;
    property Card:TCardKey read FCard write FCard;

    constructor Create(const AName:String);overload;
    procedure Assign(const ASource:TCardThrown);
  end;

  TGameRound=class
  private
    FCardsThrown: TObjectList<TCardThrown>;
    FTurnOn: String;
    function GetDone: Boolean;
  public
    property TurnOn:String read FTurnOn write FTurnOn;
     [NeonInclude(Include.Always)]
    property CardsThrown: TObjectList<TCardThrown> read FCardsThrown write FCardsThrown;
    [NeonIgnore]
    property Done:Boolean read GetDone;

    function Clone:TGameRound;
    procedure ThrowCard(APlayer:String; ACard:TCardKey);
    constructor Create;
    destructor Destroy;override;
  end;

implementation

{ TGameRound }

function TGameRound.Clone: TGameRound;
var i: Integer;
    c:TCardThrown;
begin
  result:=TGameRound.Create;
  Result.FTurnOn:=FTurnOn;
  for i :=0 to FCardsThrown.Count-1 do begin
    c:=TCardThrown.Create;
    c.Assign(FCardsThrown[i]);
    Result.FCardsThrown.Add(c);
  end;
end;

constructor TGameRound.Create;
begin
  inherited;
  FCardsThrown:=TObjectList<TCardThrown>.Create(True);
end;

destructor TGameRound.Destroy;
begin
  FCardsThrown.Free;
  inherited;
end;

function TGameRound.GetDone: Boolean;
var itm:TCardThrown;
begin
  Result:=True;
  for itm in FCardsThrown do begin
    if itm.Card=None then begin
      result:=False;
      Exit;
    end;
  end;
end;

procedure TGameRound.ThrowCard(APlayer:String; ACard: TCardKey);
var itm:TCardThrown;
begin
  for itm in FCardsThrown do begin
    if itm.PlayerName=APlayer then begin
      itm.Card:=ACard;
      Break;
    end;
  end
end;

{ TCardThrown }

procedure TCardThrown.Assign(const ASource: TCardThrown);
begin
  FPlayerName:=ASource.PlayerName;
  FCard:=ASource.Card;
end;

constructor TCardThrown.Create(const AName: String);
begin
  inherited Create;
  FPlayerName:=AName;
end;

end.
