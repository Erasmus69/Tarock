unit Server.Entities.Game;

interface
uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections,
  Server.Entities.Card,
  Spring.Collections.Stacks;

type
  TTeam=(ttTeam1,ttTeam2);

  TPlayerCards=class
  private
    FPlayerName:String;
    FTeam: TTeam;

  //  [NeonInclude(Include.Always)]
    FCards: TCards;


  public
    property PlayerName:String read FPlayerName write FPlayerName;
    property Team:TTeam read FTeam write FTeam;
   // [NeonInclude(Include.Always)]
    property Cards:TCards read FCards write FCards;

    constructor Create(const AName:String='');
    destructor Destroy;override;
    procedure Assign(const ASource:TPlayerCards);
  end;
  TPlayersCards=class(TObjectList<TPlayerCards>);

  TGameRound=class
  public
//    property Beginner:String read FBeginner write FBeginner;
  end;

  TGameRounds=Spring.Collections.Stacks.TObjectStack<TGameRound>;

  TGame=class
  private
    FID:TGUID;
    FPlayers:TPlayersCards;
    FTalon:TPlayerCards;
    FActive: Boolean;
    FRounds: TGameRounds;

  public
//    [NeonInclude(Include.Always)]
    property ID:TGUID read FID write FID;
    property Active:Boolean read FActive write FActive;

    property Players:TPlayersCards read FPlayers write FPlayers;
    property Talon:TPlayerCards read FTalon write FTalon;
    [NeonIgnore]
    property Rounds:TGameRounds read FRounds write FRounds;

    constructor Create;
    destructor Destroy;override;
    function Clone:TGame;
    function FindPlayer(const APlayerName:String):TPlayerCards;
  end;
  TGames=Spring.Collections.Stacks.TObjectStack<TGame>;

implementation
uses SysUtils;

{ TGame }

function TGame.Clone: TGame;
var
  i: Integer;
begin
  Result:=TGame.Create;
  Result.FID:=FID;
  Result.FActive:=FActive;
  for i := 0 to Players.Count-1 do begin
  //  Result.Players.Add(TPlayerCards.Create);
    Result.Players[i].Assign(Players[i]);
  end;

  Result.Talon.Assign(Talon);
end;

constructor TGame.Create;
var i:Integer;
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FPlayers:=TPlayersCards.Create(True);
  for i:=0 to 3 do
   FPlayers.Add(TPlayerCards.Create);

  FTalon:=TPlayerCards.Create('TALON');

 // FRounds:=TGameRounds.Create;

  FActive:=True;
end;

destructor TGame.Destroy;
var i:Integer;
begin
  FreeAndNil(FPlayers);
  FreeAndNil(FTalon);

  FreeAndNil(FRounds);

  inherited;
end;


function TGame.FindPlayer(const APlayerName: String): TPlayerCards;
var itm:TPlayerCards;
begin
  Result:=Nil;
  if Uppercase(APlayerName)='TALON' then
    Result:=FTalon
  else begin
     for itm in FPlayers do begin
       if itm.Playername=APlayername then begin
         REsult:=itm;
         Break;
       end;
     end;

  end;
end;

{ TPlayerCards }

procedure TPlayerCards.Assign(const ASource: TPlayerCards);
begin
  FPlayerName:=ASource.PlayerName;
  FTeam:=ASource.Team;
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
