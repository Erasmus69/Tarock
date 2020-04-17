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
, Server.Entities.Card
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
    function GetCards: TCards;

    [POST, Path('/games')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function NewGame: TExtendedRESTResponse;

    [GET, Path('/games/{AGameID}')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetGame([PathParam]AGameID:String): TGame;

 (*   [GET, Path('/games/{AGameID}/cards{AName}')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetPlayerCards([PathParam] AGameID:TGUID;[PathParam] AName:String): TPlayerCards;   *)

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

function TApiV1Resource.GetGame(AGameID:String): TGame;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetGame(AGameID);
end;

function TApiV1Resource.RegisterPlayer(APlayer:TPlayers): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.RegisterPlayer(APlayer);
end;

function TApiV1Resource.DeletePlayer(APlayer: TPlayers): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.DeletePlayer(APlayer);
end;

function TApiV1Resource.GetCards: TCards;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetCards;
end;
(*
function TApiV1Resource.GetPlayerCards(AGameID: TGUID; AName: String): TPlayerCards;
begin
  Result:=GetContainer.Resolve<IApiV1Controller>.GetPlayerCards(AGameID,AName);
end; *)

function TApiV1Resource.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetPlayers;
end;

initialization
  TWiRLResourceRegistry.Instance.RegisterResource<TApiV1Resource>;

end.

