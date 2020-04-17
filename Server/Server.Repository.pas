unit Server.Repository;

interface

uses
 System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni, RDQuery, RDSQLConnection,
 System.Generics.Collections, System.JSON, Spring.Container.Common,
 Spring.Collections,
 Spring.Logging,

 Server.Entities,
 Server.Entities.Card,
 Server.Entities.Game,
 Server.WIRL.Response,
 Server.Controller.Game
;

type
  IRepository = interface
  ['{52DC4164-4347-4D49-9CB3-D19E910062D9}']
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame(AID:String):TGame;
  end;

  TRepository = class(TInterfacedObject, IRepository)
  private
    FConnection: TRDSQLConnection;
    FQuery: TRDQuery;
    FLastError: String;
    FPlayers:TPlayers;
    FGames:TGames;
    FGameController:TGameController;

    FLogger: ILogger;
    function GetActGame: TGame;

  public
    constructor Create;
    destructor Destroy; override;

    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame(AID:String):TGame;

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

  FPlayers:=TPlayers.Create(True);
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
  Result:=FGames.Peek;
end;

function TRepository.GetCards: TCards;
begin
  Result:=ALLCards.Clone;
end;

function TRepository.GetGame(AID: String): TGame;
var g:TGame;
begin
  if FGames.Count=0 then
    g:=nil
  else// if (AID='0') or (AID='''0''')then
    g:=FGames.Peek ;
 (* else
    g:=nil;  *)
(*  else begin
    g:=FGames.First(function(const itm:TGame):Boolean begin
                           Result:=itm.ID.ToString=AID;
                         end);
  end; *)

  if Assigned(g) then
    Result:=g.Clone
  else
    Result:=nil;
end;

function TRepository.GetPlayers: TPlayers;
begin
  Logger.Enter('TRepository.GetPlayers');
  Result:=Nil;
  try
    Result:=FPlayers.Clone;

  except
    on E: Exception do
      Logger.Error('TRepository.GetPlayers :: Exception: ' + E.Message);
  end;

  Logger.Leave('TRepository.GetPlayers');
end;

function TRepository.NewGame: TExtendedRESTResponse;
var g:TGame;
    i:Integer;
begin
  if FPlayers.Count=4 then begin
    if (FGames.Count>0) and FGames.Peek.Active then
      Result:=TExtendedRESTResponse.BuildResponse(False,'A game is just active')
    else begin
      g:=TGame.Create;
      for i := 0 to 3 do
        g.Players[i].PlayerName:=FPlayers[i].Name;


      { TODO -oAP : rauszuwerfen }
      g.Players[0].Team:=ttTEam1;
      g.Players[2].Team:=ttTEam1;
      g.Players[1].Team:=ttTEam2;
      g.Players[3].Team:=ttTEam2;

      FGames.Push(g);
      Result:=TExtendedRESTResponse.BuildResponse(True);
      Result.Message:=g.ID.ToString;
      Result.ID:=g.ID;

      FreeAndNil(FGameController);
      FGameController:=TGameController.Create(g);
      FGameController.Shuffle;
    end;
  end
  else
    Result:=TExtendedRESTResponse.BuildResponse(False,'Needs 4 registered players to create a game');
end;

function TRepository.RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
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

function TRepository.DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
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
