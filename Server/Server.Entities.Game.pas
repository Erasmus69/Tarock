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
    property PlayerName:String read FPlayerName write FPlayerName;
    property Cards:TCards read FCards write FCards;

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

  public
//    [NeonInclude(Include.Always)]
    property ID:TGUID read FID write FID;
    property Active:Boolean read FActive write FActive;

    property Player1:TPlayerCards read FPlayer1 write FPlayer1;
    property Player2:TPlayerCards read FPlayer2 write FPlayer1;
    property Player3:TPlayerCards read FPlayer3 write FPlayer1;
    property Player4:TPlayerCards read FPlayer4 write FPlayer1;
    property Talon:TPlayerCards read FTalon write FTalon;

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
  FCards:=TCards.Create;
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

end.
