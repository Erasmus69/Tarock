unit Server.Controller;

interface

uses
  System.Generics.Collections,
  System.JSON,
  Spring.Collections,
  Server.Entities,
  Server.WIRL.Response
;

type
  IApiV1Controller = interface
  ['{43B8C3AB-4848-41EE-AAF9-30DE019D0059}']
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
  end;

  TApiV1Controller = class(TInterfacedObject, IApiV1Controller)
  public
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
    function DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
  end;

implementation

uses
  System.SysUtils
, Server.Repository
, Server.Register
;
{ TApiV1Controller }

function TApiV1Controller.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IRepository>.GetPlayers;
end;

function TApiV1Controller.RegisterPlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.RegisterPlayer(APlayer);
end;


function TApiV1Controller.DeletePlayer(const APlayer:TPlayers):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.DeletePlayer(APlayer);
end;

end.

