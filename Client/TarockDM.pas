unit TarockDM;

interface

uses
  System.SysUtils, System.Classes, WiRL.Client.CustomResource,
  WiRL.Client.Resource, System.Net.HttpClient.Win, WiRL.http.Client,
  WiRL.Client.Application,  Rest.Neon,System.JSON,
  WiRL.Client.Resource.JSON, System.ImageList, Vcl.ImgList, Vcl.Controls,
  Common.Entities.Card, Common.Entities.Round,   dxGDIPlusClasses, cxClasses,
  cxGraphics,Common.Entities.GameType,Common.Entities.Player,Common.Entities.GameSituation,
  Classes.Entities;

type
  TdmTarock = class(TDataModule)
    WiRLClientApplication1: TWiRLClientApplication;
    WiRLClient1: TWiRLClient;
    resPlayers: TWiRLClientResourceJSON;
    resCards: TWiRLClientResourceJSON;
    imCards: TImageList;
    resPlayerCards: TWiRLClientResourceJSON;
    imBackCards: TcxImageCollection;
    BackDown: TcxImageCollectionItem;
    BackRight: TcxImageCollectionItem;
    BackLeft: TcxImageCollectionItem;
    resGames: TWiRLClientResourceJSON;
    resRoundPut: TWiRLClientResourceJSON;
    resRoundGet: TWiRLClientResourceJSON;
    resRoundPost: TWiRLClientResourceJSON;
    resGameSituation: TWiRLClientResourceJSON;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FPlayers:TPlayers;
    FMyName: String;
    FMyCards:TCards;
    FTurnOn: String;
    FBeginner: String;
    FActualBet: Smallint;
    FGameSituation: TGameSituation<Common.Entities.Player.TPlayer>;
    procedure FillPlayerPatchBody(AContent: TMemoryStream; APatchData: TObject);
    { Private declarations }

  public
    { Public declarations }

    RESTClient:TNeonRESTClient;
    function GetPlayers:TPlayers;
    procedure RegisterPlayer(const AName:String);
    procedure StartNewGame;
    procedure GetMyCards;
    function GetCards(AName:String):TCards;
    procedure RefreshGameSituation;
    function GetRound:TGameRound;
    procedure PutTurn(ACard:TCardKey);
    procedure NewRound;

    property Players:TPlayers read FPlayers;
    property MyName:String read FMyName write FMyName;
    property TurnOn:String read FTurnOn;
    property Beginner:String read FBeginner;
    property MyCards:TCards read FMyCards;
    property ActualBet:Smallint read FActualBet;
    property GameSituation: TGameSituation<Common.Entities.Player.TPlayer> read FGameSituation;
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
  Math,
  TarockFrm;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmTarock }

procedure TdmTarock.DataModuleCreate(Sender: TObject);
begin
  RESTClient:=TNeonRESTClient.Create('localhost:8080');
  Common.Entities.Card.Initialize;
  Common.Entities.GameType.Initialize;

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

       for i := 0 to Min(FPlayers.Count-1,Ord(High(TBoardPosition))) do begin
         FPlayers.Items[i].Position:=TBoardPosition(i);
         case FPlayers.Items[i].Position of
            bpLeft:begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clFirstPlayer;
                     FPlayers.Items[i].CardImage:=frmTarock.imgFirstCard;
                    end;
            bpUp:  begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clSecondPlayer;
                     FPlayers.Items[i].CardImage:=frmTarock.imgSecondCard;
                   end;
            bpRight:begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clThirdPlayer;
                     FPlayers.Items[i].CardImage:=frmTarock.imgThirdCard;
                   end;
            bpDown:begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clME;
                     FPlayers.Items[i].CardImage:=frmTarock.imgMyCard;
                   end;
          end;
       end;
     end;
  end;
  Result:=FPlayers;
end;

function TdmTarock.GetRound: TGameRound;
begin
  Result:=Nil;
  try
    resRoundGET.GET;
    if resRoundGET.ResponseAsString>'' then begin
      Result:=TGameRound.Create;
      RESTClient.DeserializeObject(resRoundGET.Response, Result);
      FTurnOn:=Result.TurnOn;
    end;
  except
    on E:Exception do begin
 //     Showmessage(E.Message);
    end;

  end;
end;

procedure TdmTarock.NewRound;
begin
 // try
    resRoundPost.PathParamsValues.Clear;
    resRoundPost.POST;

   if resRoundPost.Response.GetValue<String>('status')<>'success' then
      Showmessage(resRoundPost.Response.GetValue<String>('message'));
 // except
 // end;
end;

procedure TdmTarock.PutTurn(ACard: TCardKey);
begin
  try
    resRoundPut.PathParamsValues.Clear;
    resRoundPut.Resource:=Format('v1/round/%s/%d',[FMyName,Ord(ACard)]);
    resRoundPut.PUT;

   (* if resRound.Response.GetValue<String>('status')<>'success' then
      Showmessage(resRound.Response.GetValue<String>('message'));     *)
  except
  end;
end;

procedure TdmTarock.DataModuleDestroy(Sender: TObject);
begin
  Common.Entities.Card.TearDown;
  Common.Entities.GameType.TearDown;
  FreeAndNil(FMyCards);
end;

procedure TdmTarock.FillPlayerPatchBody(AContent: TMemoryStream; APatchData: TObject);
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

procedure TdmTarock.RefreshGameSituation;
begin
  resGameSituation.GET;

  if resGameSituation.ResponseAsString>'' then begin
    FreeAndNil(FGameSituation);
    FGameSituation:=TGameSituation<Common.Entities.Player.TPlayer>.Create;

    RESTClient.DeserializeObject(resGameSituation.Response, FGameSituation);
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
            FillPlayerPatchBody(AContent, pl);
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

   if resGames.Response.GetValue<String>('status')<>'success' then
     Showmessage(resGames.Response.GetValue<String>('message'))
   else begin
     FBeginner:=resGames.Response.GetValue<String>('message');
     FTurnOn:=FBeginner;
     FActualBet:=0;
   end;
  except
    on E: Exception do begin
      Showmessage(E.Message);
    end;
  end;
end;

function TdmTarock.GetCards(AName:String):TCards;
begin
  Result:=Nil;
  resPlayerCards.PathParamsValues.Clear;
  resPlayerCards.QueryParams.Clear;
//  resPlayerCards.PathParamsValues.Values['AGameid'] :='0';
//  resPlayerCards.PathParamsValues.Values['AName'] :=FMyNAme;
  resPlayerCards.Resource:='v1/games/0/cards/'+AName;
  resPlayerCards.GET;

  if resPlayerCards.ResponseAsString>'' then begin
    result:=TCards.Create;
    RESTClient.DeserializeObject(resPlayerCards.Response, result);
  end;
end;

procedure TdmTarock.GetMyCards;
begin
  FreeandNil(FMyCards);
  FMyCards:=GetCards(FMyName);
end;


end.
