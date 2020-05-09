unit Server.Entities.Game;

interface
uses
  Spring, Neon.Core.Attributes,
  Generics.Collections,
  Common.Entities.Player,
  Common.Entities.Card,
  Common.Entities.Round,
  Common.Entities.Bet,
  Common.Entities.GameSituation,
  Common.Entities.GameType,
  Spring.Collections.Stacks;

type
  TPlayerCards=class(TPlayer)
  private
    FIndex: Integer;
    FCards: TCards;

  public
    property Index:Integer read FIndex;


    property Cards:TCards read FCards write FCards;

    constructor Create(const AName:String; const AIndex:Integer; const AScore:Integer);
    destructor Destroy;override;
    procedure Assign(const ASource:TPlayer);override;
  end;


  TGameRounds=Spring.Collections.TList<TGameRound>;

  TGame=class
  private
    FID:TGUID;
    FTalon:TPlayerCards;
    FActive: Boolean;
    FRounds: TGameRounds;
    FBets: TBets;
    FSituation: TGameSituation<TPlayerCards>;
    FActGame: TGameType;
    FLastFinalBidder: String;
    FTalonRounds: Integer;
    function GetActRound: TGameRound;
    function GetPlayers: TPlayers<TPlayerCards>;
    function GetPlayersTeam1: String;
    function GetPlayersTeam2: String;

    //function Clone:TGame;
  public
//    [NeonInclude(Include.Always)]
    property ID:TGUID read FID write FID;
    property Active:Boolean read FActive write FActive;

    property Players: TPlayers<TPlayerCards> read GetPlayers;
    property Talon:TPlayerCards read FTalon write FTalon;
    property Bets:TBets read FBets write FBets;
    property LastFinalBidder:String read FLastFinalBidder write FLastFinalBidder;

    property Rounds:TGameRounds read FRounds write FRounds;
    property ActRound:TGameRound read GetActRound;
    property TalonRounds:Integer read FTalonRounds write FTalonRounds;
    property Situation:TGameSituation<TPlayerCards> read FSituation write FSituation;
    property ActGame:TGameType read FActGame write FActGame;
    property PlayersTeam1:String read GetPlayersTeam1;
    property PlayersTeam2:String read GetPlayersTeam2;

    constructor Create(const APlayers:TPlayers<TPlayer>=nil);
    destructor Destroy;override;

    function FindPlayer(const APlayerName:String):TPlayerCards;
    function TeamOf(const APlayerName:String):TTeam;
  end;
  TGames=Spring.Collections.Stacks.TObjectStack<TGame>;

implementation
uses SysUtils;

{ TGame }
 (*
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
         *)
constructor TGame.Create(const APlayers:TPlayers<TPlayer>=nil);
var i:Integer;
    player:TPlayer;
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FSituation:=TGameSituation<TPlayerCards>.Create;

  for i:=0 to 3 do begin
    if Assigned(APlayers) then
      Players.Add(TPlayerCards.Create(APlayers[i].Name,i,APlayers[i].Score))
    else
      Players.Add(TPlayerCards.Create('',i,0))
  end;
  FTalon:=TPlayerCards.Create('TALON',-1,0);
  for player in APlayers do
    player.BetState:=btNone;

  FBets:=TBets.Create(True);
  FRounds:=TGameRounds.Create;
  FActive:=True;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(FSituation);
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
     for itm in Players do begin
       if itm.Name=APlayername then begin
         Result:=itm;
         Break;
       end;
     end;
  end;
end;

function TGame.GetActRound: TGameRound;
begin
  if FRounds.Count=0 then
    Result:=Nil
  else
    Result:=FRounds.Last
end;

function TGame.GetPlayers: TPlayers<TPlayerCards>;
begin
  Result:=FSituation.Players;
end;

function TGame.GetPlayersTeam1: String;
var player:TPlayer;
begin
  Result:='';
  for player in FSituation.Players do begin
    if player.Team=ttTeam1 then
      Result:=','+player.Name
  end;
  if Length(Result)>0 then
    Result:=Copy(Result,2,Length(Result));
end;

function TGame.GetPlayersTeam2: String;
var player:TPlayer;
begin
  Result:='';
  for player in FSituation.Players do begin
    if player.Team=ttTeam2 then
      Result:=Result+','+player.Name
  end;
  if Length(Result)>0 then
    Result:=Copy(Result,2,Length(Result));
end;

function TGame.TeamOf(const APlayerName: String): TTeam;
begin
   Result:=Players.Find(APlayerName).Team
end;

{ TPlayerCards }

procedure TPlayerCards.Assign(const ASource:TPlayer);
begin
  inherited Assign(ASource);
  if ASource is TPlayerCards then begin
    FIndex:=TPlayerCards(ASource).Index;
    FCards.Assign(TPlayerCards(ASource).Cards);
  end;
end;

constructor TPlayerCards.Create(const AName:String; const AIndex:Integer; const AScore:Integer);
begin
  inherited Create(AName);
  FIndex:=AIndex;
  Score:=AScore;

  FCards:=TCards.Create;
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

end.
