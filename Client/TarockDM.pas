unit TarockDM;

interface

uses
  System.SysUtils, System.Classes, WiRL.Client.CustomResource,
  WiRL.Client.Resource, System.Net.HttpClient.Win, WiRL.http.Client,
  WiRL.Client.Application,  Rest.Neon;

type
  TdmTarock = class(TDataModule)
    WiRLClientApplication1: TWiRLClientApplication;
    WiRLClient1: TWiRLClient;
    crPlayers: TWiRLClientResource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }

    RESTClient:TNeonRESTClient;
       function GetPlayers:String;

  end;

var
  dm:TdmTarock;

implementation
uses   {$IFDEF HAS_NETHTTP_CLIENT}
  WiRL.http.Client.NetHttp,
  {$ELSE}
  WiRL.http.Client.Indy,
  {$ENDIF}

  WiRL.Rtti.Utils,
  WiRL.Core.JSON;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmTarock }

procedure TdmTarock.DataModuleCreate(Sender: TObject);
begin
  RESTClient:=TNeonRESTClient.Create('localhost:8080');
end;

function TdmTarock.GetPlayers: String;
begin
  Result:=crPlayers.GETAsString()
end;

end.
