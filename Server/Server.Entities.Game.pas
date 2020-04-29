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
  Spring.Collections.Stacks;

type
  TTeam=(ttTeam1,ttTeam2);

  TPlayerCards=class(TPlayer)
  private
    FIndex: Integer;
    FTeam: TTeam;

    FCards: TCards;

  public
    property Index:Integer read FIndex;
    property Team:TTeam read FTeam write FTeam;

    property Cards:TCards read FCards write FCards;

    constructor Create(const AName:String; const AIndex:Integer);
    destructor Destroy;override;
    procedure Assign(const ASource:TPlayer);override;
  end;


  TGameRounds=Spring.Collections.Stacks.TObjectStack<TGameRound>;

  TGame=class
  private
    FID:TGUID;
    FTalon:TPlayerCards;
    FActive: Boolean;
    FRounds: TGameRounds;
    FPositiveGame: Boolean;
    FBets: TBets;
    FSituation: TGameSituation<TPlayerCards>;
    function GetActRound: TGameRound;
    function GetPlayers: TPlayers<TPlayerCards>;

    //function Clone:TGame;
  public
//    [NeonInclude(Include.Always)]
    property ID:TGUID read FID write FID;
    property Active:Boolean read FActive write FActive;

    property Players: TPlayers<TPlayerCards> read GetPlayers;
    property Talon:TPlayerCards read FTalon write FTalon;
    property Bets:TBets read FBets write FBets;

    property Rounds:TGameRounds read FRounds write FRounds;
    property ActRound:TGameRound read GetActRound;
    property PositiveGame:Boolean read FPositiveGame write FPositiveGame;
    property Situation:TGameSituation<TPlayerCards> read FSituation write FSituation;

    constructor Create(const APlayers:TPlayers<TPlayer>=nil);
    destructor Destroy;override;

    function FindPlayer(const APlayerName:String):TPlayerCards;
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
begin
  inherited Create;
  SysUtils.CreateGUID(FID);
  FSituation:=TGameSituation<TPlayerCards>.Create;

  for i:=0 to 3 do begin
    if Assigned(APlayers) then
      Players.Add(TPlayerCards.Create(APlayers[i].Name,i))
    else
      Players.Add(TPlayerCards.Create('',i))
  end;
  FTalon:=TPlayerCards.Create('TALON',-1);

  FBets:=TBets.Create(True);
  FRounds:=TGameRounds.Create;
  FPositiveGame:=True;
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
  Result:=FRounds.PeekOrDefault
end;

function TGame.GetPlayers: TPlayers<TPlayerCards>;
begin
  Result:=FSituation.Players;
end;

{ TPlayerCards }

procedure TPlayerCards.Assign(const ASource:TPlayer);
begin
  inherited Assign(ASource);
  if ASource is TPlayerCards then begin
    FIndex:=TPlayerCards(ASource).Index;
    FTeam:=TPlayerCards(ASource).Team;
    FCards.Assign(TPlayerCards(ASource).Cards);
  end;
end;

constructor TPlayerCards.Create(const AName:String; const AIndex:Integer);
begin
  inherited Create(AName);
  FIndex:=AIndex;

  FCards:=TCards.Create;
end;

destructor TPlayerCards.Destroy;
begin
  FreeAndNil(FCards);
  inherited;
end;

end.
