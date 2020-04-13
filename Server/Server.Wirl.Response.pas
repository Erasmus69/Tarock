unit Server.Wirl.Response;

interface
type
  TBaseRESTResponse = class
  private
    FMessage: String;
    FStatus: String;
    FHTTPStatusCode: Integer;
  public
    property Status: String read FStatus write FStatus;
    [NeonIgnore]
    property HTTPStatusCode: Integer read FHTTPStatusCode write FHTTPStatusCode;
    property Message: String read FMessage write FMessage;

    class function BuildResponse(const ASuccess:Boolean; const AErrorMessage:String=''): TBaseRESTResponse;
  end;

  TExtendedRESTResponse = class(TBaseRESTResponse)
  type
    TDataRec = record
      SomeString: String;
      SomeInt: Integer;
    end;
  public
    [NeonInclude(Include.Always)]
    Data: TDataRec;
  end;


implementation
uses WiRL.http.Core;

class function TBaseRESTResponse.BuildResponse(const ASuccess:Boolean; const AErrorMessage:String):TBaseRESTResponse;
begin
  Result := TBaseRESTResponse.Create;
  if ASuccess then begin
    Result.Status := 'success';
    Result.HTTPStatusCode := TWiRLHttpStatus.OK;
    Result.Message := 'OK';
  end
  else begin
    Result.Status := 'fail';
    Result.HTTPStatusCode := TWiRLHttpStatus.BAD_REQUEST;
    Result.Message := AErrorMessage;
  end;
end;


end.
