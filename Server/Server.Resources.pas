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
, Server.Entities
, Common.Entities.Card
, Common.Entities.Round
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


    [GET, Path('/players')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetPlayers: TPlayers;

    [POST, Path('/players'),Produces(TMediaType.APPLICATION_JSON)]
    function RegisterPlayer([BodyParam]APlayer:TPlayers):TBaseRESTResponse;

    [DELETE, Path('/players'),Produces(TMediaType.APPLICATION_JSON)]
    function DeletePlayer([BodyParam]APlayer:TPlayers):TBaseRESTResponse;


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

    [GET, Path('/round')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetRound: TGameRound;

    [POST, Path('/round')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function NewRound: TBaseRESTResponse;


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

function TApiV1Resource.NewGame:TExtendedRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.NewGame;
end;

function TApiV1Resource.NewRound: TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.NewRound;
end;

function TApiV1Resource.RegisterPlayer(APlayer:TPlayers): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.RegisterPlayer(APlayer);
end;

function TApiV1Resource.Turn(AName:String; ACard:Integer): TBaseRESTResponse;
begin
  if (ACard<Ord(Low(TCardKey))) or (ACard>Ord(High(TCardKey))) then
    raise Exception.Create('Wrong CardValue');
  Result := GetContainer.Resolve<IApiV1Controller>.Turn(AName, TCardKey(ACard));
end;

function TApiV1Resource.DeletePlayer(APlayer: TPlayers): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.DeletePlayer(APlayer);
end;

function TApiV1Resource.GetAllCards: TCards;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetAllCards;
  if Assigned(Result) then
    Result:=Result.Clone;
end;

function TApiV1Resource.GetPlayerCards(AGameID: String; AName: String): TCards;
begin
  Result:=GetContainer.Resolve<IApiV1Controller>.GetPlayerCards(AGameID,AName);
  if Assigned(Result) then
    Result:=Result.Clone;
end;

function TApiV1Resource.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetPlayers;
  if Assigned(Result) then
    Result:=Result.Clone;
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

