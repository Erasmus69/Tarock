unit TarockDM;

interface

uses
  System.SysUtils, System.Classes, WiRL.Client.CustomResource,
  WiRL.Client.Resource, System.Net.HttpClient.Win, WiRL.http.Client,
  WiRL.Client.Application,  Rest.Neon,Classes.Entities, System.JSON,
  WiRL.Client.Resource.JSON;

type
  TdmTarock = class(TDataModule)
    WiRLClientApplication1: TWiRLClientApplication;
    WiRLClient1: TWiRLClient;
    resPlayers: TWiRLClientResourceJSON;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure FillLicensePatchBody(AContent: TMemoryStream;
      APatchData: TObject);
    { Private declarations }

  public
    { Public declarations }

    RESTClient:TNeonRESTClient;
    function GetPlayers:TPlayers;
    procedure RegisterPlayer(const AName:String);

  end;

var
  dm:TdmTarock;

implementation
uses   {$IFDEF HAS_NETHTTP_CLIENT}
  WiRL.http.Client.NetHttp,
  {$ELSE}
  WiRL.http.Client.Indy,
  {$ENDIF}
  dialogs,
  WiRL.Rtti.Utils,
  WiRL.Core.JSON;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmTarock }

procedure TdmTarock.DataModuleCreate(Sender: TObject);
begin
  RESTClient:=TNeonRESTClient.Create('localhost:8080');
end;

function TdmTarock.GetPlayers: TPlayers;
var response:String;
begin
  Result:=nil;

  resPlayers.GET;
  if resPlayers.ResponseAsString>'' then begin
     Result := TPlayers.Create;
     RESTClient.DeserializeObject(resPlayers.Response, Result);
  end;
end;

procedure TdmTarock.FillLicensePatchBody(AContent: TMemoryStream; APatchData: TObject);
var
  jsonValue: TJSONValue;
  content: TStringList;
begin
  jsonValue := nil;
  content := TStringList.Create;
  try
    jsonValue := RESTClient.SerializeObject(APatchData);
    content.Text := TJSONHelper.ToJSON(jsonValue);
    content.SaveToStream(AContent);

    AContent.Seek(0, soFromBeginning);
  finally
    jsonValue.Free;
    content.Free;
  end;
end;

procedure TdmTarock.RegisterPlayer(const AName: String);
var p:TPlayer;
    pl:TPlayers;
begin
  pl:=TPlayers.Create;

  try
    p:=TPlayer.Create;
    p.Name:=AName;
    pl.Add(p);

    try
      resPlayers.POST(procedure (AContent: TMemoryStream)
          begin
            FillLicensePatchBody(AContent, pl);
          end
        );

      if resPlayers.Response.GetValue<String>('status')<>'success' then
        Showmessage(resPlayers.Response.GetValue<String>('message'));

    except
      on E: Exception do begin
        Showmessage(E.Message);
      end;
    end;
  finally
    FreeAndNil(pl);
  end;
end;

end.
