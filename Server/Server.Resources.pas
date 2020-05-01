unit Server.Resources;

interface

uses
  System.Generics.Collections
, WiRL.Core.Attributes
, WiRL.Core.MessageBody.Default
, WiRL.Core.Registry
, WiRL.Core.Validators
, WiRL.http.Accept.MediaType
, WiRL.http.Request
, WiRL.http.Response
, WiRL.Schemas.Swagger
, Common.Entities.Player
, Common.Entities.Card
, Common.Entities.Round
, Common.Entities.Bet
, Common.Entities.GameSituation
, Server.Entities.Game
, Server.WIRL.Response
;

type
  [Path('/v1')]
  TApiV1Resource = class
  private
    [Context] Request: TWiRLRequest;
    [Context] Response: TWiRLResponse;
  public
    [GET]
    [Produces(TMediaType.TEXT_PLAIN + TMediaType.WITH_CHARSET_UTF8)]
    function Info: string;

    [GET, Path('/gameinfo')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetGameSituation: TGameSituation<TPlayer>;

    [GET, Path('/players')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetPlayers: TPlayers<TPlayer>;

    [POST, Path('/players'),Produces(TMediaType.APPLICATION_JSON)]
    function RegisterPlayer([BodyParam]APlayer:TPlayers<TPlayer>):TBaseRESTResponse;

    [DELETE, Path('/players'),Produces(TMediaType.APPLICATION_JSON)]
    function DeletePlayer([BodyParam]APlayer:TPlayers<TPlayer>):TBaseRESTResponse;


    [GET, Path('/cards')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetAllCards: TCards;

    [POST, Path('/games')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function NewGame: TExtendedRESTResponse;

(*    [GET, Path('/games/{AGameID}')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetGame([PathParam]AGameID:String): TGame;          *)

    [GET, Path('/games/{AGameID}/cards/{AName}')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetPlayerCards([PathParam] AGameID:String;[PathParam] AName:String): TCards;

    [GET, Path('/bets')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetBets: TBets;

    [Path('/bets')]
    [POST, Consumes(TMediaType.APPLICATION_JSON), Produces(TMediaType.APPLICATION_JSON)]
    function NewBet([BodyParam]ABet: TBet): TBaseRESTResponse;

    [Path('/king/{ACard}')]
    [PUT, Produces(TMediaType.APPLICATION_JSON)]
    function SetKing([PathParam] ACard:Integer):TBaseRESTResponse;

    [Path('/changecards')]
    [PUT, Consumes(TMediaType.APPLICATION_JSON), Produces(TMediaType.APPLICATION_JSON)]
    function ChangeCards([BodyParam]ACards: TCards):TBaseRESTResponse;

    [GET, Path('/round')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetRound: TGameRound;

    [POST, Path('/round')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function NewRound: TBaseRESTResponse;

    [POST, Path('/gameinfo/{AMessage}')]
    procedure NewGameInfo([PathParam]AMessage:String);

    [PUT, Path('/round/{AName}/{ACard}')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function Turn([PathParam] AName:String; [PathParam] ACard:Integer): TBaseRESTResponse;

  end;

implementation

uses
  System.SysUtils
, System.JSON
, REST.JSon
, WiRL.http.Core
, WiRL.http.Accept.Language
, Server.Controller
, Server.Register
;

{ THelloWorldResource }

{======================================================================================================================}
function TApiV1Resource.Info: string;
{======================================================================================================================}
var
  lang: TAcceptLanguage;
begin
  lang := TAcceptLanguage.Create('it');
  try
    if Request.AcceptableLanguages.Contains(lang) then
      Result := 'WiRL Server Template - API v.1 (fai una get di /swagger per la documentazione OpenAPI)'
    else
      Result := 'WiRL Server Template - API v.1 (get /swagger for the OpenAPI documentation)';
  finally
    lang.Free;
  end;
end;

function TApiV1Resource.NewBet(ABet: TBet): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.NewBet(ABet);
end;

function TApiV1Resource.NewGame:TExtendedRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.NewGame;
end;

procedure TApiV1Resource.NewGameInfo(AMessage: String);
begin
  GetContainer.Resolve<IApiV1Controller>.NewGameInfo(AMessage);
end;

function TApiV1Resource.NewRound: TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.NewRound;
end;

function TApiV1Resource.RegisterPlayer([BodyParam]APlayer:TPlayers<TPlayer>):
    TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.RegisterPlayer(APlayer);
end;

function TApiV1Resource.SetKing(ACard: Integer): TBaseRESTResponse;
begin
  if (ACard<Ord(Low(TCardKey))) or (ACard>Ord(High(TCardKey))) then
    raise Exception.Create('Wrong CardValue');
  Result := GetContainer.Resolve<IApiV1Controller>.SetKing(TCardKey(ACard));
end;

function TApiV1Resource.Turn(AName:String; ACard:Integer): TBaseRESTResponse;
begin
  if (ACard<Ord(Low(TCardKey))) or (ACard>Ord(High(TCardKey))) then
    raise Exception.Create('Wrong CardValue');
  Result := GetContainer.Resolve<IApiV1Controller>.Turn(AName, TCardKey(ACard));
end;

function TApiV1Resource.ChangeCards(ACards: TCards): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.ChangeCards(ACards);
end;

function TApiV1Resource.DeletePlayer([BodyParam]APlayer:TPlayers<TPlayer>):
    TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.DeletePlayer(APlayer);
end;

function TApiV1Resource.GetAllCards: TCards;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetAllCards;
  if Assigned(Result) then
    Result:=Result.Clone;
end;

function TApiV1Resource.GetBets: TBets;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetBets;
  if Assigned(Result) then
    Result:=Result.Clone;
end;

function TApiV1Resource.GetGameSituation: TGameSituation<TPlayer>;
begin
  Result:=GetContainer.Resolve<IApiV1Controller>.GetGameSituation;
end;

function TApiV1Resource.GetPlayerCards(AGameID: String; AName: String): TCards;
begin
  Result:=GetContainer.Resolve<IApiV1Controller>.GetPlayerCards(AGameID,AName);
  if Assigned(Result) then
    Result:=Result.Clone;
end;

function TApiV1Resource.GetPlayers: TPlayers<TPlayer>;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetPlayers;
  if Assigned(Result) then
    Result:=Result.Clone<TPlayer>;
end;

function TApiV1Resource.GetRound: TGameRound;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetRound;
  if Assigned(Result) then
    Result:=Result.Clone;
end;

initialization
  TWiRLResourceRegistry.Instance.RegisterResource<TApiV1Resource>;

end.

