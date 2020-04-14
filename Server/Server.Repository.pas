unit Server.Repository;

interface

uses
  System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni, RDQuery, RDSQLConnection
, System.Generics.Collections
, System.JSON

, Spring
, Spring.Container.Common
, Spring.Collections
, Spring.Logging

, Server.Entities
, Server.WIRL.Response
;

type
  IRepository = interface
  ['{52DC4164-4347-4D49-9CB3-D19E910062D9}']
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
  end;

  TRepository = class(TInterfacedObject, IRepository)
  private
    FConnection: TRDSQLConnection;
    FQuery: TRDQuery;
    FLastError: String;
    FPlayers:TPlayers;
    FLogger: ILogger;
  public
    constructor Create;
    destructor Destroy; override;

    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;

    property LastError: String read FLastError;
    property Logger: ILogger read FLogger write FLogger;
  end;

implementation

uses
  Math
, Classes.Dataset.Helpers
, Server.Configuration
, Server.Register
;

{ TRepository }

{======================================================================================================================}
constructor TRepository.Create;
{======================================================================================================================}
var
  configuration: TConfiguration;
  compNameSuffix: String;
begin
  Logger := GetContainer.Resolve<ILogger>;
  Logger.Enter('TRepository.Create');

  configuration := GetContainer.Resolve<TConfiguration>;
  compNameSuffix := IntToStr(Integer(Pointer(TThread.Current))) + '_' + IntToStr(TThread.GetTickCount);

  FPlayers:=TPlayers.Create;
  FPlayers.Add(TPlayer.Create('ANDI'));
  FPlayers.Add(TPlayer.Create('LUKI'));

  Logger.Leave('TRepository.Create');
end;

{======================================================================================================================}
destructor TRepository.Destroy;
{======================================================================================================================}
begin
  Logger.Enter('TRepository.Destroy');
  FreeAndNil(FPlayers);

  inherited;
  Logger.Leave('TRepository.Destroy');
end;


function TRepository.GetPlayers: TPlayers;
begin
  Logger.Enter('TRepository.GetPlayers');
  Result:=Nil;
  try
    Result:=TPlayers.Create;
    Result.Clone(FPlayers);

  except
    on E: Exception do
      Logger.Error('TRepository.GetPlayers :: Exception: ' + E.Message);
  end;

  Logger.Leave('TRepository.GetPlayers');
end;

function TRepository.RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
var p:TPlayer;
begin
  Result:=nil;
  Logger.Enter('TRepository.RegisterPlayer');
  try
    for p in APlayer do begin
      if Assigned(FPlayers.Find(p.Name)) then begin
        Logger.Error('TRepository.RegisterPlayer :: Exception: ' + p.Name +' is just a registered Player');
        Result:=TBaseRESTResponse.BuildResponse(False,p.Name +' is just a registered Player')
      end
      else if FPlayers.Count>=4 then begin
        Logger.Error('TRepository.RegisterPlayer :: Exception: cannot accept more than 4 players');
        Result:=TBaseRESTResponse.BuildResponse(False,'Cannot accept more than 4 players')
      end
      else begin
        FPlayers.Add(TPlayer.Create(p.Name));
        Result:=TBaseRESTResponse.BuildResponse(True)
      end;
    end;
  finally
//    APlayer.Free;
  end;
  
  if Result=nil then
    Result:=TBaseRESTResponse.BuildResponse(True);

  Logger.Leave('TRepository.RegisterPlayer');
end;

function TRepository.DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
var p,p2:TPlayer;
begin
  Result:=nil;
  Logger.Enter('TRepository.DeletePlayer');
  
  for p in APlayer do begin
    p2:=FPlayers.Find(p.Name);
    if Assigned(p2) then begin
      FPlayers.Remove(p2);
      Result:=TBaseRESTResponse.BuildResponse(True);
    end
    else begin
      Result:=TBaseRESTResponse.BuildResponse(False,p.Name +' is not a registered Player');
      break;
    end
  end;


  if Result=nil then
    Result:=TBaseRESTResponse.BuildResponse(True);

  Logger.Leave('TRepository.DeletePlayer');
end;

end.
