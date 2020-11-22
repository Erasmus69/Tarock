unit Server.Controller;

interface

uses
  System.Generics.Collections,
  System.JSON,
  Spring.Collections,
  Common.Entities.Player,
  Server.WIRL.Response,
  Common.Entities.Card,
  Common.Entities.Round,
  Common.Entities.Bet,
  Common.Entities.GameSituation,
  Server.Entities.Game
;

type
  IApiV1Controller = interface
  ['{43B8C3AB-4848-41EE-AAF9-30DE019D0059}']
    function GetPlayers:TPlayers<TPlayer>;
    function RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
    function DeletePlayer(const APlayerName:String):TBaseRESTResponse;

    function GetGameSituation: TGameSituation<TPlayer>;
    procedure NewGameInfo(const AMessage: String);

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetPlayerCards(AGameID:String; APlayerName:String):TCards;
    function GiveUp: TBaseRESTResponse;

    function GetBets:TBets;
    function NewBet(const AParam: TBet): TBaseRESTResponse;

    function SetKing(ACard: TCardKey): TBaseRESTResponse;
    function ChangeCards(ACards: TCards): TBaseRESTResponse;

    function GetRound:TGameRound;
    function NewRound: TBaseRESTResponse;
    function Turn(AName:String; ACard:TCardKey): TBaseRESTResponse;
  end;

  TApiV1Controller = class(TInterfacedObject, IApiV1Controller)
  public
    function GetPlayers:TPlayers<TPlayer>;
    function RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
    function DeletePlayer(const APlayerName:String):TBaseRESTResponse;

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame:TGame;
    function GetGameSituation: TGameSituation<TPlayer>;
    procedure NewGameInfo(const AMessage: String);
    function GiveUp: TBaseRESTResponse;

    function GetPlayerCards(AGameID:String; APlayerName:String):TCards;

    function GetBets:TBets;
    function NewBet(const AParam: TBet): TBaseRESTResponse;

    function SetKing(ACard: TCardKey): TBaseRESTResponse;
    function ChangeCards(ACards: TCards): TBaseRESTResponse;

    function GetRound:TGameRound;
    function NewRound: TBaseRESTResponse;
    function Turn(AName:String; ACard:TCardKey): TBaseRESTResponse;
  end;

implementation

uses
  System.SysUtils
, Server.Repository
, Server.Register
;
{ TApiV1Controller }

function TApiV1Controller.GetAllCards: TCards;
begin
  Result := GetContainer.Resolve<IRepository>.GetAllCards;
end;

function TApiV1Controller.GetBets: TBets;
begin
  Result := GetContainer.Resolve<IRepository>.GetBets;
end;

function TApiV1Controller.GetPlayerCards(AGameID: String; APlayerName: String): TCards;
var g:TGame;
    pc:TPlayerCards;
begin
  g:=GetGame;
  if Assigned(g) then begin
    pc:=g.FindPlayer(APlayerName);
    if Assigned(pc) then
      Result:=pc.Cards
    else
      raise Exception.Create('Player='+APlayerName+' not found');
  end
  else
    raise Exception.Create('Game ID='+AGameid+' not found');
end;

function TApiV1Controller.GetPlayers: TPlayers<TPlayer>;
begin
  Result := GetContainer.Resolve<IRepository>.GetPlayers;
end;

function TApiV1Controller.GetRound: TGameRound;
begin
  Result:=GetContainer.Resolve<IRepository>.GetRound;
end;

function TApiV1Controller.GiveUp: TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.GiveUp;
end;

function TApiV1Controller.NewBet(const AParam: TBet): TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewBet(AParam);
end;

function TApiV1Controller.NewGame: TExtendedRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewGame;
end;

procedure TApiV1Controller.NewGameInfo(const AMessage: String);
begin
  GetContainer.Resolve<IRepository>.NewGameInfo(AMessage);
end;

function TApiV1Controller.NewRound: TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewRound;
end;

function TApiV1Controller.GetGame:TGame;
begin
  Result:=GetContainer.Resolve<IRepository>.GetGame;
end;

function TApiV1Controller.GetGameSituation: TGameSituation<TPlayer>;
begin
  Result:=GetContainer.Resolve<IRepository>.GetGameSituation;
end;

function TApiV1Controller.RegisterPlayer(const APlayer:TPlayers<TPlayer>):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.RegisterPlayer(APlayer);
end;


function TApiV1Controller.SetKing(ACard: TCardKey): TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.SetKing(ACard);
end;

function TApiV1Controller.Turn(AName: String; ACard: TCardKey): TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.Turn(AName, ACard);
end;

function TApiV1Controller.ChangeCards(ACards: TCards): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IRepository>.ChangeCards(ACards);
end;

function TApiV1Controller.DeletePlayer(const APlayerName:String):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.DeletePlayer(APlayerName);
end;

end.

