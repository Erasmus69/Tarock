unit Common.Entities.Gamesituation;

interface
uses System.Generics.Collections,Common.Entities.Player,Common.Entities.GameType;

type
  TGameState=(gsNone,gsBidding,gsBet,gsPlaying);

  TGameSituation<T:TPlayer>=class(TObject)
  private
    FBeginner: String;
    FGame: TGameType;
    FPlayers: TPlayers<T>;
    FState: TGameState;
    FStarter: String;
  public
    property Beginner: String read FBeginner write FBeginner;
    property Game: TGameType read FGame write FGame;
    property Players: TPlayers<T> read FPlayers write FPlayers;
    property State: TGameState read FState write FState;
    property Starter: String read FStarter write FStarter;
    constructor Create;

    function Clone:TGameSituation<TPlayer>;
  end;

implementation

{ TGameSituation }

function TGameSituation<T>.Clone: TGameSituation<TPlayer>;
var itm:T;
    itm2:TPlayer;
begin
  Result:=TGameSituation<TPlayer>.Create;
  Result.Beginner:=FBeginner;
  Result.Starter:=FStarter;

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

end.
