unit Common.Entities.Gamesituation;

interface
uses System.Generics.Collections,Common.Entities.Player,Common.Entities.GameType;

type
  TGameState=(gsNone,gsBidding,gsBet,gsReadyToPlay,gsPlaying,gsTerminated);

  TGameSituation<T:TPlayer>=class(TObject)
  private
    FBeginner: String;
    FGame: TGameType;
    FPlayers: TPlayers<T>;
    FState: TGameState;
    FTurnOn: String;
    FBestBet: Smallint;
  public
    property Beginner: String read FBeginner write FBeginner;
    property Game: TGameType read FGame write FGame;
    property BestBet:Smallint read FBestBet write FBestBet;
    property Players: TPlayers<T> read FPlayers write FPlayers;
    property State: TGameState read FState write FState;
    property TurnOn:String read FTurnOn write FTurnOn;
    constructor Create;
    destructor Destroy;override;

    function Clone:TGameSituation<TPlayer>;
    function FirstPlayerGamesEnabled:Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TGameSituation }

function TGameSituation<T>.Clone: TGameSituation<TPlayer>;
var itm:T;
    itm2:TPlayer;
begin
  Result:=TGameSituation<TPlayer>.Create;
  Result.Beginner:=FBeginner;
  Result.TurnOn:=FTurnOn;
  Result.BestBet:=FBestBet;

  for itm in FPlayers do begin
    itm2:=TPlayer.Create(itm.Name);
    itm2.Assign(itm);
    Result.Players.Add(itm2);
  end;

  if Assigned(FGame) then
    Result.Game:=FGame.Clone;
  Result.State:=FState;
end;

constructor TGameSituation<T>.Create;
begin
  inherited Create;
  FPlayers:=TPlayers<T>.Create(True);
  FState:=gsNone;
end;

destructor TGameSituation<T>.Destroy;
begin
  FreeAndNil(FPlayers);
  inherited;
end;

function TGameSituation<T>.FirstPlayerGamesEnabled: Boolean;
var player:TPlayer;
begin
  if (State=gsBidding) then begin
    Result:=True;
    for player in Players do begin
      if (player.Name=Beginner) and (player.BetState<>btHold) then begin
         Result:=False;
         Break;
      end
      else if (player.Name<>Beginner) and (player.BetState<>btPass) then begin
        Result:=False;
        Break;
      end;
    end;
  end
  else
    result:=False;
end;

end.
