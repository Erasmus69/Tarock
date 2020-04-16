unit TarockDM;

interface

uses
  System.SysUtils, System.Classes, WiRL.Client.CustomResource,
  WiRL.Client.Resource, System.Net.HttpClient.Win, WiRL.http.Client,
  WiRL.Client.Application,  Rest.Neon,Classes.Entities, System.JSON,
  WiRL.Client.Resource.JSON, System.ImageList, Vcl.ImgList, Vcl.Controls,
  Server.Entities.Game,Server.Entities.Card, dxGDIPlusClasses, cxClasses,
  cxGraphics;

type
  TdmTarock = class(TDataModule)
    WiRLClientApplication1: TWiRLClientApplication;
    WiRLClient1: TWiRLClient;
    resPlayers: TWiRLClientResourceJSON;
    resCards: TWiRLClientResourceJSON;
    imCards: TImageList;
    resGames: TWiRLClientResourceJSON;
    imBackCards: TcxImageCollection;
    BackDown: TcxImageCollectionItem;
    BackRight: TcxImageCollectionItem;
    BackLeft: TcxImageCollectionItem;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FPlayers:TPlayers;
    FMyName: String;
    FActGame: TGame;
    FMyCards:TCards;
    procedure FillLicensePatchBody(AContent: TMemoryStream;
      APatchData: TObject);
    { Private declarations }

  public
    { Public declarations }

    RESTClient:TNeonRESTClient;
    function GetPlayers:TPlayers;
    procedure RegisterPlayer(const AName:String);
    procedure StartNewGame;
    function GetActGame:TGame;

    property Players:TPlayers read FPlayers;
    property MyName:String read FMyName write FMyName;
    property ActGame:TGame read FActGame;
    property MyCards:TCards read FMyCards;
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
  WiRL.Core.JSON,
  Math;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmTarock }

procedure TdmTarock.DataModuleCreate(Sender: TObject);
begin
  RESTClient:=TNeonRESTClient.Create('localhost:8080');
  Server.Entities.Card.Initialize;

end;

function TdmTarock.GetPlayers: TPlayers;
var response:String;
    myIndex:Integer;
    i:Integer;
begin
  resPlayers.GET;
  if resPlayers.ResponseAsString>'' then begin
     FreeAndNil(FPlayers);
     FPlayers := TPlayers.Create;
     RESTClient.DeserializeObject(resPlayers.Response, FPlayers);

     if FMyName>'' then begin
       // reorder to relative board order
       for i := 0 to FPlayers.Count-1 do begin
         if FPlayers[i].Name=FMyName then begin
           myindex:=i;
           break;
         end;
       end;

       for I := 0 to myindex-1 do
         FPlayers.Move(0,FPlayers.Count-1);

       for i := 0 to Min(FPlayers.Count-1,Ord(High(TBoardPosition))) do
         FPlayers.Items[i].Position:=TBoardPosition(i);
     end;
  end;
  Result:=FPlayers;
end;

procedure TdmTarock.DataModuleDestroy(Sender: TObject);
begin
  Server.Entities.Card.TearDown;
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

procedure TdmTarock.StartNewGame;
begin
  try
    resGames.POST(procedure (AContent: TMemoryStream)
      begin
      end
     );

//    if resGames.Response.GetValue<String>('status')<>'success' then
//     Showmessage(resGames.Response.GetValue<String>('message'));

  except
    on E: Exception do begin
      Showmessage(E.Message);
    end;
  end;

  GetActGame;
end;

function TdmTarock.GetActGame:TGame;
begin
  resGames.PathParamsValues.Clear;
  resGames.QueryParams.Clear;
  resGames.PathParamsValues.Values['AGameid'] :=TGUID.Empty.ToString;
  resGames.GET;

  if resGames.ResponseAsString>'' then begin
    FreeandNil(FActGame);
    FActGame:=TGame.Create;
    RESTClient.DeserializeObject(resGames.Response, FActGame);
  end;
  Result:=FActGame;

  if Assigned(FActGame) then begin
    if FActGame.Player1.PlayerName=FMyName then
      FMyCards:=FActGame.Player1.Cards
    else if FActGame.Player2.PlayerName=FMyName then
      FMyCards:=FActGame.Player2.Cards
    else if FActGame.Player3.PlayerName=FMyName then
      FMyCards:=FActGame.Player3.Cards
    else
      FMyCards:=FActGame.Player4.Cards
  end
  else
    FMyCards:=nil
end;

end.
