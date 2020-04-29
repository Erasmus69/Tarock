unit Server.Repository;

interface

uses
 System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni, RDQuery, RDSQLConnection,
 System.Generics.Collections, System.JSON, Spring.Container.Common,
 Spring.Collections,
 Spring.Logging,

 Common.Entities.Player,
 Common.Entities.Card,
 Common.Entities.Round,
 Common.Entities.Bet,
 Server.Entities.Game,
 Common.Entities.GameSituation,
 Server.WIRL.Response,
 Server.Controller.Game;

type
  IRepository= interface
  ['{52DC4164-4347-4D49-9CB3-D19E910062D9}']
    function GetPlayers:TPlayers<TPlayer>;
    function RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame:TGame;
    function GetGameSituation: TGameSituation<TPlayer>;

    function GetBets:TBets;
    function NewBet(const AParam: TBet): TBaseRESTResponse;

    function GetRound:TGameRound;
    function NewRound: TBaseRESTResponse;
    function Turn(AName:String; ACard:TCardKey): TBaseRESTResponse;
  end;

  TRepository = class(TInterfacedObject, IRepository)
  private
    FLastError: String;
    FPlayers:TPlayers<TPlayer>;
    FGames:TGames;
    FGameController:TGameController;

    FLogger: ILogger;
    function GetActGame: TGame;

  public
    constructor Create;
    destructor Destroy; override;

    function GetPlayers:TPlayers<TPlayer>;
    function RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame:TGame;
    function GetGameSituation: TGameSituation<TPlayer>;

    function GetBets:TBets;
    function NewBet(const ABet: TBet): TBaseRESTResponse;

    function GetRound:TGameRound;
    function NewRound: TBaseRESTResponse;
    function Turn(AName:String; ACard:TCardKey): TBaseRESTResponse;

    property ActGame:TGame read GetActGame;
    property GameController:TGameController read FGameController;

    property LastError: String read FLastError;
    property Logger: ILogger read FLogger write FLogger;

  end;

implementation

uses
  Math
, Classes.Dataset.Helpers
, Server.Configuration
, Server.Register
;

{ TRepository }

{======================================================================================================================}
constructor TRepository.Create;
{======================================================================================================================}
var
  configuration: TConfiguration;
  compNameSuffix: String;
begin
  Logger := GetContainer.Resolve<ILogger>;
  Logger.Enter('TRepository.Create');

  configuration := GetContainer.Resolve<TConfiguration>;
  compNameSuffix := IntToStr(Integer(Pointer(TThread.Current))) + '_' + IntToStr(TThread.GetTickCount);

  FPlayers:=TPlayers<TPlayer>.Create(True);
  FPlayers.Add(TPlayer.Create('HANNES'));
  FPlayers.Add(TPlayer.Create('WOLFGANG'));
  FPlayers.Add(TPlayer.Create('LUKI'));
  FPlayers.Add(TPlayer.Create('ANDI'));
  FGames:=TGames.Create(True);
  Logger.Leave('TRepository.Create');
end;

{======================================================================================================================}
destructor TRepository.Destroy;
{======================================================================================================================}
begin
  Logger.Enter('TRepository.Destroy');
  FreeAndNil(FPlayers);
  FreeAndNil(FGames);
  FreeAndNil(FGameController);

  inherited;
  Logger.Leave('TRepository.Destroy');
end;


function TRepository.GetActGame: TGame;
begin
  Result:=FGames.PeekOrDefault;
end;

function TRepository.GetAllCards: TCards;
begin
  Result:=ALLCards;
end;

function TRepository.GetBets: TBets;
begin
  if Assigned(ActGame) then
    Result:=ActGame.Bets
  else
    Result:=Nil;
end;

function TRepository.GetGame: TGame;
var g:TGame;
begin
  g:=ActGame;
  if Assigned(g) then
    Result:=g
  else
    Result:=nil;
end;

function TRepository.GetGameSituation: TGameSituation<TPlayer>;
begin
  if Assigned(ActGame) then begin
    Result:=ActGame.Situation.Clone;
  end
  else
    Result:=nil;
end;

function TRepository.GetPlayers: TPlayers<TPlayer>;
begin
  Logger.Enter('TRepository.GetPlayers');
  Result:=Nil;
  try
    Result:=FPlayers;

  except
    on E: Exception do
      Logger.Error('TRepository.GetPlayers :: Exception: ' + E.Message);
  end;

  Logger.Leave('TRepository.GetPlayers');
end;

function TRepository.GetRound: TGameRound;
var g:TGame;
begin
  g:=ActGame;
  if Assigned(g) then
    Result:=g.ActRound
  else
    raise Exception.Create('No active game');
end;

function TRepository.NewBet(const ABet: TBet): TBaseRESTResponse;
var s:String;
begin
  try
    if not Assigned(FGameController) then
      Result:=TBaseRESTResponse.BuildResponse(False,'No active Game')
    else begin
      s:=FGameController.NewBet(ABet);
      Result:=TBaseRESTResponse.BuildResponse(True);
      Result.Message:='Turn is on '+s;
    end;
  except
    on E:Exception do begin
      Result:=TBaseRESTResponse.BuildResponse(False,E.Message);
      Result.Message:=E.Message;
    end;
  end;
end;

function TRepository.NewGame: TExtendedRESTResponse;
var g:TGame;
begin
  if FPlayers.Count=4 then begin
    if Assigned(ActGame) and ActGame.Active then
      Result:=TExtendedRESTResponse.BuildResponse(False,'A game is just active')
    else begin
      g:=TGame.Create(FPlayers);

      { TODO -oAP : rauszuwerfen }
      g.Players[0].Team:=ttTEam1;
      g.Players[2].Team:=ttTEam1;
      g.Players[1].Team:=ttTEam2;
      g.Players[3].Team:=ttTEam2;
      g.Situation.Beginner:='ANDI';
      FGames.Push(g);

      Result:=TExtendedRESTResponse.BuildResponse(True);
      Result.Message:=g.Situation.Beginner;
      Result.ID:=g.ID;

      FreeAndNil(FGameController);
      FGameController:=TGameController.Create(g);
      FGameController.Shuffle;
      g.Situation.State:=gsBidding;
    end;
  end
  else
    Result:=TExtendedRESTResponse.BuildResponse(False,'Needs 4 registered players to create a game');
end;

function TRepository.NewRound: TBaseRESTResponse;
begin
  try
    if not Assigned(FGameController) then
      Result:=TBaseRESTResponse.BuildResponse(False,'No active Game')
    else begin
      FGameController.NewRound;
      Result:=TBaseRESTResponse.BuildResponse(True,'Beginner is '+ActGame.ActRound.TurnOn);
    end;
  except
    on E:Exception do
      Result:=TBaseRESTResponse.BuildResponse(False,E.Message)
  end;
end;

function TRepository.RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
var p:TPlayer;
begin
  Result:=nil;
  Logger.Enter('TRepository.RegisterPlayer');
  try
    for p in APlayer do begin
      if Assigned(FPlayers.Find(p.Name)) then begin
        Logger.Error('TRepository.RegisterPlayer :: Exception: ' + p.Name +' is just a registered Player');
        Result:=TBaseRESTResponse.BuildResponse(False,p.Name +' is just a registered Player')
      end
      else if FPlayers.Count>=4 then begin
        Logger.Error('TRepository.RegisterPlayer :: Exception: cannot accept more than 4 players');
        Result:=TBaseRESTResponse.BuildResponse(False,'Cannot accept more than 4 players')
      end
      else begin
        FPlayers.Add(TPlayer.Create(p.Name));
        Result:=TBaseRESTResponse.BuildResponse(True)
      end;
    end;
  finally
//    APlayer.Free;
  end;
  
  if Result=nil then
    Result:=TBaseRESTResponse.BuildResponse(True);

  Logger.Leave('TRepository.RegisterPlayer');
end;

function TRepository.Turn(AName: String; ACard: TCardKey): TBaseRESTResponse;
var nextTurnOn:String;
begin
  if not Assigned(FGameController) then
    Result:=TBaseRESTResponse.BuildResponse(False,'No active Game')
  else begin
    nextTurnOn:=FGameController.Turn(AName,ACard);
    Result:=TBaseRESTResponse.BuildResponse(True);
    Result.Message:=nextTurnOn
  end;
end;

function TRepository.DeletePlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
var p,p2:TPlayer;
begin
  Result:=nil;
  Logger.Enter('TRepository.DeletePlayer');

  for p in APlayer do begin
    p2:=FPlayers.Find(p.Name);
    if Assigned(p2) then begin
      FPlayers.Remove(p2);

      Result:=TBaseRESTResponse.BuildResponse(True);
    end
    else begin
      Result:=TBaseRESTResponse.BuildResponse(False,p.Name +' is not a registered Player');
      break;
    end
  end;

  if Result=nil then
    Result:=TBaseRESTResponse.BuildResponse(True);

  Logger.Leave('TRepository.DeletePlayer');
end;

end.
