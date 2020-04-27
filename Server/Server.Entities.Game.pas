unit Server.Entities.Game;

interface
uses
  Spring, Neon.Core.Attributes,
  Generics.Collections,
  Server.Entities,
  Common.Entities.Card,
  Common.Entities.Round,
  Common.Entities.Bet,
  Spring.Collections.Stacks;

type
  TTeam=(ttTeam1,ttTeam2);
  TBetState=(btNone,btBet,btPass,btHold);

  TPlayerCards=class
  private
    FPlayerName:String;
    FIndex: Integer;
    FTeam: TTeam;

  //  [NeonInclude(Include.Always)]
    FCards: TCards;
    FScore:Integer;
    FBetState: TBetState;

  public
    property Index:Integer read FIndex;
    property PlayerName:String read FPlayerName;
    property Team:TTeam read FTeam write FTeam;
   // [NeonInclude(Include.Always)]
    property Cards:TCards read FCards write FCards;
    property BetState:TBetState read FBetState write FBetState;
 //   property Score read FScore write FScore;

    constructor Create(const AName:String; const AIndex:Integer);
    destructor Destroy;override;
    procedure Assign(const ASource:TPlayerCards);
  end;
  TPlayersCards=class(TObjectList<TPlayerCards>);


  TGameRounds=Spring.Collections.Stacks.TObjectStack<TGameRound>;

  TGame=class
  private
    FID:TGUID;
    FPlayers:TPlayersCards;
    FTalon:TPlayerCards;
    FActive: Boolean;
    FRounds: TGameRounds;
    FBeginner: String;
    FPositiveGame: Boolean;
    FBets: TBets;
    FStarter: String;
    function GetActRound: TGameRound;

  public
//    [NeonInclude(Include.Always)]
    property ID:TGUID read FID write FID;
    property Active:Boolean read FActive write FActive;

    property Players:TPlayersCards read FPlayers write FPlayers;
    property Talon:TPlayerCards read FTalon write FTalon;
    property Bets:TBets read FBets write FBets;

    property Rounds:TGameRounds read FRounds write FRounds;
    property ActRound:TGameRound read GetActRound;
    property Beginner:String read FBeginner write FBeginner;
    property Starter:String read FStarter write FStarter;
    property PositiveGame:Boolean read FPositiveGame write FPositiveGame;

    constructor Create(const APlayers:TPlayers=nil);
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

constructor TGame.Create(const APlayers:TPlayers);
var i:Integer;
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FPlayers:=TPlayersCards.Create(True);

  for i:=0 to 3 do begin
    if Assigned(APlayers) then
      FPlayers.Add(TPlayerCards.Create(APlayers[i].Name,i))
    else
      FPlayers.Add(TPlayerCards.Create('',i))
  end;
  FTalon:=TPlayerCards.Create('TALON',-1);

  FBets:=TBets.Create(True);
  FRounds:=TGameRounds.Create;
  FPositiveGame:=True;
  FActive:=True;
end;

destructor TGame.Destroy;
var i:Integer;
begin
  FreeAndNil(FPlayers);
  FreeAndNil(FTalon);
  FreeAndNil(FBets);
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
         Result:=itm;
         Break;
       end;
     end;
  end;
end;

function TGame.GetActRound: TGameRound;
begin
  Result:=FRounds.PeekOrDefault
end;

{ TPlayerCards }

procedure TPlayerCards.Assign(const ASource: TPlayerCards);
begin
  FIndex:=ASource.Index;
  FPlayerName:=ASource.PlayerName;
  FTeam:=ASource.Team;
  FCards.Assign(ASource.Cards);
end;

constructor TPlayerCards.Create(const AName:String; const AIndex:Integer);
begin
  inherited Create;
  FPlayerName:=AName;
  FIndex:=AIndex;
  FBetState:=btNone;

  FCards:=TCards.Create;
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

end.
