unit TarockDM;

interface

uses
  System.SysUtils, System.Classes, WiRL.Client.CustomResource,
  WiRL.Client.Resource, System.Net.HttpClient.Win, WiRL.http.Client,
  WiRL.Client.Application,  Rest.Neon,System.JSON,
  WiRL.Client.Resource.JSON, System.ImageList, Vcl.ImgList, Vcl.Controls,
  Common.Entities.Card, Common.Entities.Round,   dxGDIPlusClasses, cxClasses,
  cxGraphics,Common.Entities.GameType,Common.Entities.Player,Common.Entities.GameSituation,
  Classes.Entities,  Common.Entities.Bet;

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
    resNewBet: TWiRLClientResourceJSON;
    resBets: TWiRLClientResourceJSON;
    resSetKing: TWiRLClientResourceJSON;
    resChangeCards: TWiRLClientResourceJSON;
    resNewGameInfo: TWiRLClientResourceJSON;
    resUnregisterPlayer: TWiRLClientResourceJSON;
    resGiveup: TWiRLClientResourceJSON;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FDebugMode:Boolean;
    FUrl:String;
    FPlayers:TPlayers;
    FMyName: String;
    FMyCards:TCards;
    FGameSituation: TGameSituation<Common.Entities.Player.TPlayer>;
    FBets: TBets;
    FActGame: TGameType;
    FKingSelected: TCardKey;
    procedure FillBody(AContent: TMemoryStream; APatchData: TObject);
    function GetIAmBeginner: Boolean;
    function GetIsMyTurn: Boolean;
    function GetIAmGamer: Boolean;
    { Private declarations }

  public
    { Public declarations }

    RESTClient:TNeonRESTClient;
    function GetPlayers:TPlayers;
    function RegisterPlayer(const AName:String): Boolean;
    procedure UnRegisterPlayer;
    procedure ReactiveServerConnection;

    procedure StartNewGame;
    procedure GetMyCards;
    function GetCards(AName:String):TCards;
    procedure RefreshGameSituation;
    procedure NewGameInfo(const AMessage:String);

    procedure NewBet(const ABet:TBet);
    procedure GetBets;

    procedure SelectKing(const ACard:TCardKey);
    procedure LayDownCards(const ACards:TCards);

    function GetRound:TGameRound;
    function CanThrow(ACard:TCard;var AError:String):Boolean;
    procedure PutTurn(ACard:TCardKey);
    procedure NewRound;
    procedure GiveUp;

    property Players:TPlayers read FPlayers;
    property Bets:TBets read FBets;
    property MyName:String read FMyName write FMyName;
    property IAmBeginner:Boolean read GetIAmBeginner;
    property IsMyTurn:Boolean read GetIsMyTurn;
    property IAmGamer:Boolean read GetIAmGamer;
    property MyCards:TCards read FMyCards;
    property GameSituation: TGameSituation<Common.Entities.Player.TPlayer> read FGameSituation;
    property ActGame:TGameType read FActGame;
    property DebugMode:Boolean read FDebugMode;
    property KingSelected:TCardKey read FKingSelected write FKingSelected;
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
  TarockFrm, System.IniFiles, ConnectionErrorFrm, Vcl.Forms,
  WiRL.http.Client.Interfaces, WiRL.http.URL;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmTarock }

const URL='185.154.66.221:20000';

procedure TdmTarock.DataModuleCreate(Sender: TObject);
var
  ini: TInifile;
begin
  ini:=TInifile.Create('.\Tarock.ini');
  try
    FDebugMode:=ini.ReadInteger('Debug','Debug',0)=1;
    FUrl:=ini.ReadString('SERVER','URL',URL);

    RESTClient:=TNeonRESTClient.Create(FURL);
    WirlClient1.WirlEngineURL:='http://'+FURL+'/rest';
    WirlClient1.ConnectTimeout:=ini.ReadInteger('Server','ConnectTimeout',120000);
    WirlClient1.ReadTimeout:=ini.ReadInteger('Server','ReadTimeout',120000);

  finally
    ini.Free;
  end;
  Common.Entities.Card.Initialize;
  Common.Entities.GameType.Initialize;

end;

function TdmTarock.GetPlayers: TPlayers;
var myIndex:Integer;
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
         if AnsiUpperCase(FPlayers[i].Name)=AnsiUpperCase(FMyName) then begin
           FMyName:=FPlayers[i].Name;
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
                     FPlayers.Items[i].CardPosition:=cpFirstPlayer;
                    end;
            bpUp:  begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clSecondPlayer;
                     FPlayers.Items[i].CardImage:=frmTarock.imgSecondCard;
                     FPlayers.Items[i].CardPosition:=cpSecondPlayer;
                   end;
            bpRight:begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clThirdPlayer;
                     FPlayers.Items[i].CardImage:=frmTarock.imgThirdCard;
                     FPlayers.Items[i].CardPosition:=cpThirdPlayer;
                   end;
            bpDown:begin
                     FPlayers.Items[i].PlayerLabel:=frmTarock.clME;
                     FPlayers.Items[i].CardImage:=frmTarock.imgMyCard;
                     FPlayers.Items[i].CardPosition:=cpMyCards;
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
    end;
  except
    on E:Exception do begin
 //     Showmessage(E.Message);
    end;

  end;
end;

procedure TdmTarock.GiveUp;
begin
  resGiveUp.PathParamsValues.Clear;
  resGiveUp.POST;

   if resGiveUp.Response.GetValue<String>('status')<>'success' then
      Showmessage(resGiveUp.Response.GetValue<String>('message'));
end;

procedure TdmTarock.LayDownCards(const ACards: TCards);
begin
  try
    resChangeCards.PUT(procedure (AContent: TMemoryStream)
          begin
            FillBody(AContent, ACards);
          end
        );
  except
    Raise;
  end;
end;

procedure TdmTarock.NewBet(const ABet:TBet);
begin
  try
    resNewBet.POST(procedure (AContent: TMemoryStream)
          begin
            FillBody(AContent, ABet);
          end
        );

    if resNewBet.Response.GetValue<String>('status')<>'success' then
      Showmessage(resNewBet.Response.GetValue<String>('message'));
 // except
 // end;
  finally
    ABet.Free;
  end;
end;

procedure TdmTarock.NewGameInfo(const AMessage: String);
begin
  resNewGameInfo.Resource:=Format('v1/gameinfo/%s',[AMessage]);
  resNewGameInfo.POST;
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
  resRoundPut.PathParamsValues.Clear;
  resRoundPut.Resource:=TWiRLURL.URLEncode(Format('v1/round/%s/%d',[FMyName,Ord(ACard)]));
  resRoundPut.PUT;

   (* if resRound.Response.GetValue<String>('status')<>'success' then
      Showmessage(resRound.Response.GetValue<String>('message'));     *)
end;

procedure TdmTarock.DataModuleDestroy(Sender: TObject);
begin
  Common.Entities.Card.TearDown;
  Common.Entities.GameType.TearDown;
  FreeAndNil(FMyCards);
end;

procedure TdmTarock.FillBody(AContent: TMemoryStream; APatchData: TObject);
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
    if FGameSituation.GameType>'' then
      FActGame:=ALLGAMES.Find(FGameSituation.GameType)
    else
      FActGame:=Nil;
  end;
end;

function TdmTarock.RegisterPlayer(const AName:String): Boolean;
var p:TPlayer;
    pl:TPlayers;
    msg:String;
begin
  pl:=TPlayers.Create;
  Result:=false;

  try
    p:=TPlayer.Create;
    p.Name:=AName;
    pl.Add(p);
    resPlayers.POST(procedure (AContent: TMemoryStream)
          begin
            FillBody(AContent, pl);
          end
    );
    if resPlayers.Response.GetValue<String>('status')<>'success' then begin
      msg:=resPlayers.Response.GetValue<String>('message');
      if Pos('is just a registered',msg)>0 then begin
        Showmessage('Willkommen zurück ' +AName);
        Result:=true;
      end
      else
        Showmessage(msg)
    end
    else
      Result:=true;

  finally
    FreeAndNil(pl);
  end;
end;

procedure TdmTarock.SelectKing(const ACard: TCardKey);
begin
  try
    resSetKing.PathParamsValues.Clear;
    resSetKing.Resource:=Format('v1/king/%d',[Ord(ACard)]);
    resSetKing.PUT();
  except
    on E: Exception do begin
      Showmessage(E.Message);
    end;
  end;
end;

procedure TdmTarock.StartNewGame;
begin
  FreeAndnil(FMyCards);
  FActGame:=Nil;

  resGames.POST(procedure (AContent: TMemoryStream)
    begin
    end
   );

 if resGames.Response.GetValue<String>('status')<>'success' then
   Showmessage(resGames.Response.GetValue<String>('message'));
end;

procedure TdmTarock.UnRegisterPlayer;
begin
  resUnregisterPlayer.PathParamsValues.Clear;
  resUnregisterPlayer.Resource:=Format('v1/players/%s',[MyName]);
  resUnregisterPlayer.DELETE();
end;

procedure TdmTarock.GetBets;
begin
  resBets.PathParamsValues.Clear;
  resBets.QueryParams.Clear;
  resBets.GET;

  if resBets.ResponseAsString>'' then begin
    FreeAndNil(FBets);
    FBets:=TBets.Create;
    RESTClient.DeserializeObject(resBets.Response, FBets);
  end;

end;

function TdmTarock.GetCards(AName:String):TCards;
begin
  Result:=Nil;
  resPlayerCards.PathParamsValues.Clear;
  resPlayerCards.QueryParams.Clear;
//  resPlayerCards.PathParamsValues.Values['AGameid'] :='0';
//  resPlayerCards.PathParamsValues.Values['AName'] :=FMyNAme;

  resPlayerCards.Resource:=TWiRLURL.URLEncode('v1/games/0/cards/'+AName);
  resPlayerCards.GET;

  if resPlayerCards.ResponseAsString>'' then begin
    result:=TCards.Create;
    RESTClient.DeserializeObject(resPlayerCards.Response, result);
  end;
end;

function TdmTarock.GetIAmBeginner: Boolean;
begin
  Result:=GameSituation.Beginner=MyName;
end;

function TdmTarock.GetIAmGamer: Boolean;
begin
  Result:=FGameSituation.Gamer=MyName;
end;

function TdmTarock.GetIsMyTurn: Boolean;
begin
  Result:=FGameSituation.TurnOn=MyName
end;

procedure TdmTarock.GetMyCards;
begin
  FreeandNil(FMyCards);
  FMyCards:=GetCards(FMyName);
end;


procedure TdmTarock.ReactiveServerConnection;
var frm:TfrmConnectionError;
  i: Integer;
begin
  frm:=TfrmConnectionError.Create(Self);
  try
    frm.Show;
    Application.ProcessMessages;
    while True do begin
      Sleep(500);
      Application.ProcessMessages;

      try
        dm.RefreshGameSituation;
        Break;
      except
        on E: EWiRLSocketException do
        else
          Raise;
      end;
    end;
  finally
    FreeAndNil(frm);
  end;
end;

function TdmTarock.CanThrow(ACard: TCard; var AError: String): Boolean;
var r:TGameRound;
    firstCard,highestThrownCard,card:TCard;
    i:Integer;
begin
  Result:=False;

  r:=dm.GetRound;

  try
    if FActGame.JustColors and (ACard.CType=ctTarock) and Assigned(r) and (r.CardsThrown[0].Card=none) then begin  // on justcolor tarock can thrown at last
      if FMyCards.ExistsCardType(ctHeart) or FMyCards.ExistsCardType(ctCross) or
         FMyCards.ExistsCardType(ctDiamond) or FMyCards.ExistsCardType(ctSpade) then begin
        AError:='Tarock können erst ausgespielt werden, wenn keine Farben mehr auf der Hand sind';
        Exit;
      end;
    end;

    if Assigned(r) and (r.CardsThrown[0].Card<>None) then begin
      firstCard:=ALLCARDS.Find(r.CardsThrown[0].Card);

      if FMyCards.ExistsCardType(firstCard.CType) then begin
        if ACard.CType<>firstCard.CType then begin
          if firstCard.CType=ctTarock then
            AError:='Es besteht Tarockwang'
          else
            AError:='Es besteht Farbzwang';
          Exit;
        end
      end
      else if (FMyCards.ExistsCardType(ctTarock) and (ACard.CType<>ctTarock)) then begin
        AError:='Es besteht Tarockzwang';
        Exit;
      end;

      if not FActGame.Positive then begin
        highestThrownCard:=firstCard;

        for i:=1 to r.CardsThrown.Count-1 do begin
          if r.CardsThrown[i].Card<>None then begin
            card:=ALLCARDS.Find(r.CardsThrown[i].Card);
            if card.IsStronger(highestThrownCard,FActGame.JustColors) then
              highestThrownCard:=card;
          end;
        end;

        if highestThrownCard.IsStronger(ACard,True) then begin
          if FMyCards.ExistsStronger(highestThrownCard,True) then begin
            AError:='Es besteht Stichzwang';
            Exit;
          end
          else if r.CardsThrown.Exists(T22) and r.CardsThrown.Exists(T21) and
                 (ACard.ID<>T1) and FMyCards.ExistsUnFold(T1) then begin // whole Trull present
            AError:='Es besteht Stichzwang';
            Exit;
          end;
        end;
      end;
    end;
  finally
    r.free;
  end;
// pagat als letzten ,

  AError:='';
  Result:=True;
end;

end.
