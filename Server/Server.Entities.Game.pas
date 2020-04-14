unit Server.Entities.Game;

interface
uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections,
  Server.Entities.Card;

  type

  TPlayerCards=class
  private
    FPlayerName:String;
    FCards: TCards;

  public
    property Cards:TCards read FCards write FCards;
    property  PlayerName:String read FPlayerName;
    constructor Create(const AName:String);
    destructor Destroy;override;
    procedure Shuffle(var ACards:TCards; const ACount:Integer);
  end;

  TGame=class
    FID:TGUID;
    FPlayer1:TPlayerCards;
    FPlayer2:TPlayerCards;
    FPlayer3:TPlayerCards;
    FPlayer4:TPlayerCards;
    FTalon:TPlayerCards;

    procedure Shuffle;
  public
    [NeonInclude(Include.Always)]
    property ID:TGUID read FID;

    constructor Create(const APlayer1,APlayer2,APlayer3,APlayer4:String);
    destructor Destroy;override;
  end;
  TGames=TObjectDictionary<TGUID,TGame>;

implementation
uses SysUtils;

{ TGame }

constructor TGame.Create(const APlayer1,APlayer2,APlayer3,APlayer4:String);
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FPlayer1:=TPlayerCards.Create(APlayer1);
  FPlayer2:=TPlayerCards.Create(APlayer2);
  FPlayer3:=TPlayerCards.Create(APlayer3);
  FPlayer4:=TPlayerCards.Create(APlayer4);
  FTalon:=TPlayerCards.Create('TALON');

  Shuffle;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(FPlayer1);
  FreeAndNil(FPlayer2);
  FreeAndNil(FPlayer3);
  FreeAndNil(FPlayer4);
  FreeAndNil(FTalon);
  inherited;
end;

procedure TGame.Shuffle;
var cards:TCards;
begin
  cards:=ALLCARDS.Clone;
  FPlayer1.Shuffle(cards,12);
  FPlayer2.Shuffle(cards,12);
  FPlayer3.Shuffle(cards,12);
  FPlayer4.Shuffle(cards,12);
  FTalon.Cards:=cards;  // get the rest
end;

{ TPlayerCards }

constructor TPlayerCards.Create(const AName: String);
begin
  inherited Create;
  FPlayerName:=AName;
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

procedure TPlayerCards.Shuffle(var ACards: TCards; const ACount: Integer);
var i,r:Integer;
    key:TCardKey;
    itm:TPair<TCardKey,TCard>;
begin
  FCards:=TCards.Create([doOwnsValues]);

  for i:=1 to ACount do begin
    r:=Random(ACards.Count);
    key:=ACards.Keys.ToArray[r];
    itm:=ACards.ExtractPair(key);
    FCards.Add(itm.Key,itm.Value);
  end;
end;

end.
