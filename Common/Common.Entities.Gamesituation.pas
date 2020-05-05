unit Common.Entities.Gamesituation;

interface
uses System.Classes,System.Generics.Collections,Neon.Core.Attributes,Common.Entities.Player,
     Common.Entities.GameType,Common.Entities.Card,Common.Entities.Bet;

type
  TGameState=(gsNone,gsBidding,gsCallKing,gsGetTalon,gsFinalBet,gsPlaying,gsTerminated);

  TGameResults=record
    Game:Smallint;
    Minus10Count:Smallint;
    Minus110:Smallint;
    ContraGame:Smallint;
    KingUlt:Smallint;
    PagatUlt:Smallint;
    VogelII:Smallint;
    VogelIII:Smallint;
    VogelIV:Smallint;
    Trull:Smallint;
    CatchXXI:Smallint;
    Valat:Smallint;
  end;

  TGameSituation<T:TPlayer>=class(TObject)
  private
    FBeginner: String;
    FPlayers: TPlayers<T>;
    FState: TGameState;
    FTurnOn: String;
    FBestBet: Smallint;
    FGameType: String;
    FGamer: String;
    FKingSelected: TCardKey;
    FCardsLayedDown: TCards;
    FGameInfo: TStringList;
    FTeam1AddBets: TAddBets;
    FTeam2AddBets: TAddBets;
    FWinner: TTeam;
    FTeam2Results: TGameResults;
    FTeam1Results: TGameResults;
  public
    property Players: TPlayers<T> read FPlayers write FPlayers;
    property State: TGameState read FState write FState;
    property TurnOn:String read FTurnOn write FTurnOn;

    property Beginner: String read FBeginner write FBeginner;
    property GameType:String read FGameType write FGameType;
    property Team1AddBets:TAddBets read FTeam1AddBets write FTeam1AddBets;
    property Team2AddBets:TAddBets read FTeam2AddBets write FTeam2AddBets;
    property Gamer:String read FGamer write FGamer;
    property BestBet:Smallint read FBestBet write FBestBet;
    property KingSelected:TCardKey read FKingSelected write FKingSelected;
    property CardsLayedDown:TCards read FCardsLayedDown write FCardsLayedDown;
    property GameInfo:TStringList read FGameInfo write FGameInfo;
    property Team1Results:TGameResults read FTeam1Results write FTeam1Results;
    property Team2Results:TGameResults read FTeam2Results write FTeam2Results;


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
  Result.Gamer:=FGamer;
  Result.BestBet:=FBestBet;

  for itm in FPlayers do begin
    itm2:=TPlayer.Create(itm.Name);
    itm2.Assign(itm);
    Result.Players.Add(itm2);
  end;
  Result.GameType:=FGameType;
  Result.State:=FState;
  Result.GameInfo:=TStringList.Create;
  Result.GameInfo.Assign(FGameInfo);
  Result.Team1AddBets:=FTeam1AddBets;
  Result.Team2AddBets:=FTeam2AddBets;
  Result.Team1Results:=FTeam1Results;
  Result.Team2Results:=FTeam2Results;

  if Assigned(FCardsLayedDown) then
  //  Result.CardsLayedDown:=FCardsLayedDown.Clone
end;

constructor TGameSituation<T>.Create;
begin
  inherited Create;
  FPlayers:=TPlayers<T>.Create(True);
  FState:=gsNone;
  FGameInfo:=TStringList.Create;
end;

destructor TGameSituation<T>.Destroy;
begin
  FreeAndNil(FPlayers);
  FreeAndNil(FCardsLayedDown);
  FreeAndNil(FGameInfo);
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
