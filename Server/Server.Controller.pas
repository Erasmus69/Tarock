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
    function RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;

    function GetMasters: TList<TMaster>;
    function GetMaster(const AMasterID: String): TMaster;
    function GetMasterDetails(const AMasterID: string): TList<TDetail>;
    function GetMasterDetail(const AMasterID, ADeviceID: string): TDetail;
  end;

  TApiV1Controller = class(TInterfacedObject, IApiV1Controller)
  public
    function GetPlayers:TPlayers;
    function RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;

    function GetMasters: TList<TMaster>;
    function GetMaster(const AMasterID: String): TMaster;
    function GetMasterDetails(const AMasterID: string): TList<TDetail>;
    function GetMasterDetail(const AMasterID, ADeviceID: string): TDetail;
  end;

implementation

uses
  System.SysUtils
, Server.Repository
, Server.Register
;
{ TApiV1Controller }

{======================================================================================================================}
function TApiV1Controller.GetMasters: TList<TMaster>;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IRepository>.GetMasters;
end;

function TApiV1Controller.GetPlayers: TPlayers;
begin
  Result := GetContainer.Resolve<IRepository>.GetPlayers;
end;

function TApiV1Controller.RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;
begin
  Result:=GetContainer.Resolve<IRepository>.RegisterPlayer(APlayer);
end;

{======================================================================================================================}
function TApiV1Controller.GetMaster(const AMasterID: String): TMaster;
{======================================================================================================================}
begin
  Result := GetContainer.Resolve<IRepository>.GetMaster(AMasterID);
end;

{======================================================================================================================}
function TApiV1Controller.GetMasterDetails(const AMasterID: string): TList<TDetail>;
{======================================================================================================================}
begin
  Result := TObjectList<TDetail>.Create;
end;

{======================================================================================================================}
function TApiV1Controller.GetMasterDetail(const AMasterID, ADeviceID: string): TDetail;
{======================================================================================================================}
begin
  Result := TDetail.Create;
end;

end.

