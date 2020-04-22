unit Server.Controller;

interface

uses
  System.Generics.Collections,
  System.JSON,
  Spring.Collections,
  Server.Entities,
  Server.WIRL.Response,
  Common.Entities.Card,
  Common.Entities.Round,
  Server.Entities.Game
;

type
  IApiV1Controller = interface
  ['{43B8C3AB-4848-41EE-AAF9-30DE019D0059}']
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetPlayerCards(AGameID:String; APlayerName:String):TCards;

    function GetRound:TGameRound;
    function NewRound: TBaseRESTResponse;
    function Turn(AName:String; ACard:TCardKey): TBaseRESTResponse;
  end;

  TApiV1Controller = class(TInterfacedObject, IApiV1Controller)
  public
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    function GetAllCards:TCards;
    function NewGame:TExtendedRESTResponse;
    function GetGame:TGame;
    function GetPlayerCards(AGameID:String; APlayerName:String):TCards;

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

function TApiV1Controller.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IRepository>.GetPlayers;
end;

function TApiV1Controller.GetRound: TGameRound;
begin
  Result:=GetContainer.Resolve<IRepository>.GetRound;
end;

function TApiV1Controller.NewGame: TExtendedRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewGame;
end;

function TApiV1Controller.NewRound: TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.NewRound;
end;

function TApiV1Controller.GetGame:TGame;
begin
  Result:=GetContainer.Resolve<IRepository>.GetGame;
end;

function TApiV1Controller.RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.RegisterPlayer(APlayer);
end;


function TApiV1Controller.Turn(AName: String; ACard: TCardKey): TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.Turn(AName, ACard);
end;

function TApiV1Controller.DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.DeletePlayer(APlayer);
end;

end.

