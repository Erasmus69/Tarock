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

    [POST, Path('/registerplayer'),Produces(TMediaType.APPLICATION_JSON)]
    function RegisterPlayer([BodyParam]APlayer:TPlayer):TBaseRESTResponse;

    [GET, Path('/masters')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function GetMasters: TList<TMaster>;

    [GET, Path('/masters/{AMasterID}'), Produces(TMediaType.APPLICATION_JSON)]
    function GetMaster([PathParam] AMasterID: string): TMaster;

    [GET, Path('/masters/{AMasterID}/details'), Produces(TMediaType.APPLICATION_JSON)]
    function GetMasterDetails([PathParam] AMasterID: string): TList<TDetail>;

    [GET, Path('/masters/{AMasterID}/details/{ADeviceID}'), Produces(TMediaType.APPLICATION_JSON)]
    function GetMasterDetail([PathParam] AMasterID: string; [PathParam] ADeviceID: string): TDetail;
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

function TApiV1Resource.RegisterPlayer(APlayer:TPlayer): TBaseRESTResponse;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.RegisterPlayer(APlayer);
end;

{======================================================================================================================}
function TApiV1Resource.GetMasters: TList<TMaster>;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetMasters;
end;

function TApiV1Resource.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetPlayers;
end;

{======================================================================================================================}
function TApiV1Resource.GetMaster(AMasterID: string): TMaster;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetMaster(AMasterID);
end;

{======================================================================================================================}
function TApiV1Resource.GetMasterDetails(AMasterID: string): TList<TDetail>;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetMasterDetails(AMasterID);
end;

{======================================================================================================================}
function TApiV1Resource.GetMasterDetail(AMasterID, ADeviceID: string): TDetail;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IApiV1Controller>.GetMasterDetail(AMasterID, ADeviceID);
end;

initialization
  TWiRLResourceRegistry.Instance.RegisterResource<TApiV1Resource>;

end.

