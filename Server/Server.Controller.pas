unit Server.Controller;

interface

uses
  System.Generics.Collections,
  System.JSON,
  Spring.Collections,
  Server.Entities,
  Server.WIRL.Response,
  Server.Entities.Card,
  Server.Entities.Game
;

type
  IApiV1Controller = interface
  ['{43B8C3AB-4848-41EE-AAF9-30DE019D0059}']
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame(AID:String):TGame;
    function GetPlayerCards(const AGameID:String;const APlayerName:String):TPlayerCards;

  end;

  TApiV1Controller = class(TInterfacedObject, IApiV1Controller)
  public
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame(AID:String):TGame;
    function GetPlayerCards(const AGameID:String;const APlayerName:String):TPlayerCards;

  end;

implementation

uses
  System.SysUtils
, Server.Repository
, Server.Register
;
{ TApiV1Controller }

function TApiV1Controller.GetCards: TCards;
begin
  Result := GetContainer.Resolve<IRepository>.GetCards;
end;

function TApiV1Controller.GetPlayerCards(const AGameID: String;const APlayerName: String): TPlayerCards;
var g:TGame;
begin
  g:=GetGame(AGameID);
  if Assigned(g) then
    Result:=g.FindPlayer(APlayerName)
  else
    raise Exception.Create('Error Message');
 //   result:=nil;
end;

function TApiV1Controller.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IRepository>.GetPlayers;
end;

function TApiV1Controller.NewGame: TExtendedRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewGame;
end;

function TApiV1Controller.GetGame(AID:String):TGame;
begin
  Result:=GetContainer.Resolve<IRepository>.GetGame(AID);
end;

function TApiV1Controller.RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.RegisterPlayer(APlayer);
end;


function TApiV1Controller.DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.DeletePlayer(APlayer);
end;

end.

