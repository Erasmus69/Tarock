unit Rest.Neon;

interface

uses
  REST.Client,
  REST.Types,

  System.Classes, System.Rtti,
  System.JSON,
     System.TypInfo,
  Classes.Entities,
  Common.Entities.Card,
  Neon.Core.Types
, Neon.Core.Persistence
, Neon.Core.Persistence.JSON;

type
  TNeonRESTClient = class(TRESTClient)
  private

    FRESTRequest: TCustomRESTRequest;
    FErrorMessage: String;
    function GetResponse: TCustomRESTResponse;
    function DoJsonToObject<T:Class, constructor>(const AJSONText: String): T;
  public
    constructor Create(ABaseApiURL: String);
    function GetObject<T:class, constructor>(const AResource:String):T;
    function PostEntity<T: class, constructor>(const AResource: string; AEntity: T): TJSONValue;

    class function SerializeObject(const AObject: TObject): TJSONValue;
    class procedure DeserializeObject(const AJSONValue: TJSONValue; AObject: TObject);

    property Request: TCustomRESTRequest read FRESTRequest;
    property Response: TCustomRESTResponse read GetResponse;
    property ErrorMessage: String read FErrorMessage;

    class function BuildSerializerConfig: INeonConfiguration;
  end;

implementation

uses
  IPPeerClient
, System.SysUtils
, Neon.Core.Utils
//,  Neon.Core.Serializers.RTL
, Neon.Core.Serializers.RTL;

const  REST_APP_PATH = '/rest/app/';

  {$REGION 'SubFunctions'}
  //----------------------------------------------------------------------------
  function GetRemoteURL: string;
  const
    URL = 'http://%s:%d/rest/app/v1/players';
  var
    IP: string;
    Port: Integer;
  begin
    IP := 'localhost';
    Port := 8080;

    Result := Format(URL, [IP, Port]);
  end;

(*  //----------------------------------------------------------------------------
  function SendCommand: TResultObject;
  var
    LJSONResponse: TJSONValue;
  begin
    Result := nil;
    LJSONResponse := nil;

    try try
      LJSONResponse := RESTClient.PostEntity<TCommandObject>('command', ACommand);
      if Assigned(LJSONResponse) then
        Result := TNeon.JSONToObject<TResultObject>(LJSONResponse, TNeonRESTClient.BuildSerializerConfig);
    finally
      if not LJSONResponse.GetOwned then
        LJSONResponse.Free;
    end;
    except
      on E: Exception do
        raise Exception.Create('TRESTExecutor.Execute :: Exception: ' + E.Message);
      // Result will be nil
    end;
  end;
  {$ENDREGION}

begin
  RESTClient := TNeonRESTClient.Create(GetRemoteURL);
  try
    Result := SendCommand;
  finally
    RESTClient.Free;
  end;
end;
*)

{$REGION 'TRDRESTClient'}

constructor TNeonRESTClient.Create(ABaseApiURL: String);
begin
  inherited Create(ABaseApiURL);

  Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  AcceptCharset := 'UTF-8, *;q=0.8';
  RaiseExceptionOn500 := False;
  SynchronizedEvents := False;

  FallbackCharsetEncoding := ''; // Workaround for TUTF8Encoding memory leak (Bug report RSP-17695 fixed in 10.2 Tokyo Release 1)

  FRESTRequest := TRESTRequest.Create(Self);
  Self.BaseURL:=Self.BaseURL+REST_APP_PATH;
end;


function TNeonRESTClient.PostEntity<T>(const AResource: string; AEntity: T): TJSONValue;
begin
  Result := nil;

  try
    Request.Method := rmPOST;
    Request.Resource :='v1/'+ AResource;
    Request.ClearBody;
    with TNeon.ObjectToJSON(AEntity, BuildSerializerConfig) do begin
      try
        Request.AddBody(ToJSON, ctAPPLICATION_JSON);
      finally
        Free;
      end;
    end;

    try
      Request.Execute;
    except
      on E: Exception do
        raise Exception.CreateFmt('RESTRequest execution failed with code %d: %s, %s', [Response.StatusCode, Response.StatusText, E.Message]);
    end;

    if Response.Status.Success then begin
      if Assigned(Response.JSONValue) then
        Result := Response.JSONValue
      else
        raise Exception.Create('RESTRequest failed: response is not a valid JSONValue');
    end
    else
      raise ERequestError.Create(Response.StatusCode, Format('%d: %s', [Response.StatusCode, Response.StatusText]), '');

  except
    on E: Exception do begin
      FErrorMessage := E.Message;
      raise;
    end;
  end;
end;


class function TNeonRESTClient.SerializeObject(const AObject: TObject): TJSONValue;
begin
  Result := TNeon.ObjectToJSON(AObject, BuildSerializerConfig);
end;

class procedure TNeonRESTClient.DeserializeObject(const AJSONValue: TJSONValue; AObject: TObject);
begin
  TNeon.JSONToObject(AObject, AJSONValue, BuildSerializerConfig);
end;

function TNeonRESTClient.DoJsonToObject<T>(const AJSONText: String): T;
begin
  if (AJSONText.Length > 0) then begin
    Result := TNeon.JSONToObject<T>(AJSONText,BuildSerializerConfig);
  end;
end;

function TNeonRESTClient.GetObject<T>(const AResource:String):T;
begin
  Result := nil;
  Request.Method := TRESTRequestMethod.rmGET;
  Request.Resource := 'v1/'+AResource;

  try
    Request.AddParameter('Content-Type','application/json',TRESTRequestParameterKind.pkHTTPHEADER,[TRESTRequestParameteroption.poDoNotEncode]);    Request.Execute;
    Result := DoJsonToObject<T>(Response.JSONText);
  except
    on E: Exception do
      raise Exception.CreateFmt('RESTRequest execution failed with code %d: %s, %s', [Response.StatusCode, Response.StatusText, E.Message]);
  end;
end;

function TNeonRESTClient.GetResponse: TCustomRESTResponse;
begin
  Result := Request.Response;
end;

class function TNeonRESTClient.BuildSerializerConfig: INeonConfiguration;
var
  neonMembers: TNeonMembersSet;
begin
  Result := TNeonConfiguration.Default;

  // Case settings
  Result.SetMemberCustomCase(nil);
  neonMembers := [TNeonMembers.Standard,TNeonMembers.Fields,TNeonMembers.Properties];
  Result.SetMembers(neonMembers);

  // Set Wirl server
  Result.SetMemberCase(TNeonCase.SnakeCase);
  Result.SetUseUTCDate(True);

  // F Prefix setting
  Result.SetIgnoreFieldPrefix(True);
  Result.SetVisibility([mvPublic, mvPublished]);


  Result.GetSerializers.RegisterSerializer(TGUIDSerializer);
 // Result.GetSerializers.RegisterSerializer(TCardKeySerializer);
end;

{$ENDREGION}

end.
