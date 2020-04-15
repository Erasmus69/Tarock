unit Server.Entities.Game;

interface
uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections,
  Server.Entities.Card,
  Spring.Collections.Stacks;

  type

  TPlayerCards=class
  private

    FPlayerName:String;

  //  [NeonInclude(Include.Always)]
    FCards: TCards;

  public
    property  PlayerName:String read FPlayerName write FPlayerName;
   [NeonIgnore]
    property Cards:TCards read FCards;

    constructor Create(const AName:String='');
    destructor Destroy;override;
    procedure Assign(const ASource:TPlayerCards);
  end;

  TGame=class
  private
    FID:TGUID;
    FPlayer1:TPlayerCards;
    FPlayer2:TPlayerCards;
    FPlayer3:TPlayerCards;
    FPlayer4:TPlayerCards;
    FTalon:TPlayerCards;
    FActive: Boolean;
    procedure SetPlayer1(const Value: TPlayerCards);
    procedure SetPlayer2(const Value: TPlayerCards);
    procedure SetPlayer3(const Value: TPlayerCards);
    procedure SetPlayer4(const Value: TPlayerCards);
    procedure SetTalon(const Value: TPlayerCards);
  public
    [NeonInclude(Include.Always)]
    property ID:TGUID read FID;
    property Active:Boolean read FActive write FActive;

    [NeonInclude(Include.Always)]
    property Player1:TPlayerCards read FPlayer1 write SetPlayer1;
    property Player2:TPlayerCards read FPlayer2 write SetPlayer2;
    property Player3:TPlayerCards read FPlayer3 write SetPlayer3;
    property Player4:TPlayerCards read FPlayer4 write SetPlayer4;
    property Talon:TPlayerCards read FTalon write SetTalon;

    constructor Create;
    destructor Destroy;override;
    function Clone:TGame;
  end;
  TGames=Spring.Collections.Stacks.TObjectStack<TGame>;

implementation
uses SysUtils;

{ TGame }

function TGame.Clone: TGame;
begin
  Result:=TGame.Create;
  Result.FID:=FID;
  Result.FActive:=FActive;
  Result.Player1.Assign(Player1);
  Result.Player2.Assign(Player2);
  Result.Player3.Assign(Player3);
  Result.Player4.Assign(Player4);
  Result.Talon.Assign(Talon);
end;

constructor TGame.Create;
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FPlayer1:=TPlayerCards.Create;
  FPlayer2:=TPlayerCards.Create;
  FPlayer3:=TPlayerCards.Create;
  FPlayer4:=TPlayerCards.Create;
  FTalon:=TPlayerCards.Create('TALON');
  FActive:=True;
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


procedure TGame.SetPlayer1(const Value: TPlayerCards);
begin
  FreeAndNil(FPlayer1);
  FPlayer1 := Value;
end;

procedure TGame.SetPlayer2(const Value: TPlayerCards);
begin
  FreeAndNil(FPlayer2);
  FPlayer2 := Value;
end;

procedure TGame.SetPlayer3(const Value: TPlayerCards);
begin
  FreeAndNil(FPlayer3);
  FPlayer3 := Value;
end;

procedure TGame.SetPlayer4(const Value: TPlayerCards);
begin
  FreeAndNil(FPlayer4);
  FPlayer4 := Value;
end;

procedure TGame.SetTalon(const Value: TPlayerCards);
begin
  FreeAndNil(FTalon);
  FTalon := Value;
end;

{ TPlayerCards }

procedure TPlayerCards.Assign(const ASource: TPlayerCards);
begin
  FPlayerName:=ASource.PlayerName;
  FCards.Assign(ASource.Cards);
end;

constructor TPlayerCards.Create(const AName: String);
begin
  inherited Create;
  FPlayerName:=AName;
  FCards:=TCards.Create([doOwnsValues]);
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

end.
