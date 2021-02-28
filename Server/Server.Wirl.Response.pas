unit Server.Wirl.Response;

interface
uses Neon.Core.Attributes;

type
  TBaseRESTResponse = class
  private
    FMessage: String;
    FStatus: String;
    FHTTPStatusCode: Integer;

    class procedure IntBuildResponse(AResponse:TBaseRESTResponse;const ASuccess:Boolean; const AErrorMessage:String='');
  public
    property Status: String read FStatus write FStatus;
    [NeonIgnore]
    property HTTPStatusCode: Integer read FHTTPStatusCode write FHTTPStatusCode;
    property Message: String read FMessage write FMessage;

    class function BuildResponse(const ASuccess:Boolean; const AErrorMessage:String=''): TBaseRESTResponse;
  end;

  TExtendedRESTResponse = class(TBaseRESTResponse)
  public
    [NeonInclude(IncludeIf.Always)]
    ID:TGUID;
    SomeString: String;
    SomeInt: Integer;
    class function BuildResponse(const ASuccess:Boolean; const AErrorMessage:String=''): TExtendedRESTResponse;
  end;


implementation
uses WiRL.http.Core;

class function TBaseRESTResponse.BuildResponse(const ASuccess:Boolean; const AErrorMessage:String):TBaseRESTResponse;
begin
  Result := TBaseRESTResponse.Create;
  IntBuildResponse(REsult,ASuccess,AErrorMessage);
end;

class procedure TBaseRESTResponse.IntBuildResponse(AResponse: TBaseRESTResponse;
  const ASuccess: Boolean; const AErrorMessage: String);
begin
  if ASuccess then begin
    AResponse.Status := 'success';
    AResponse.HTTPStatusCode := TWiRLHttpStatus.OK;
    AResponse.Message := 'OK';
  end
  else begin
    AResponse.Status := 'fail';
    AResponse.HTTPStatusCode := TWiRLHttpStatus.BAD_REQUEST;
    AResponse.Message := AErrorMessage;
  end;
end;

class function TExtendedRESTResponse.BuildResponse(const ASuccess:Boolean; const AErrorMessage:String=''): TExtendedRESTResponse;
begin
  Result := TExtendedRESTResponse.Create;
  IntBuildResponse(REsult,ASuccess,AErrorMessage);
end;

end.
