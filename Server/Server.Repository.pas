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
    function RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;
    function GetMasters: TList<TMaster>;
    function GetMaster(const AMasterID: String): TMaster;
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
    function RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;


    function GetMasters: TList<TMaster>;
    function GetMaster(const AMasterID: String): TMaster;

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
//  FPlayers.Add(TPlayer.Create('ANDI'));
//  FPlayers.Add(TPlayer.Create('LUKI'));

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


{$REGION 'EXAMPLES'}
{======================================================================================================================}
function TRepository.GetMasters: TList<TMaster>;
{======================================================================================================================}

  {--------------------------------------------------------------------------------------------------------------------}
  function OpenDataSet: Boolean;
  {--------------------------------------------------------------------------------------------------------------------}
  const
    SQL_TEXT = 'SELECT * FROM MASTERS';
  begin
    FQuery.Close;
    FQuery.SQL.Text := SQL_TEXT;
//    FQuery.Open;
//    Result := not FQuery.Eof;
    Result := False;
  end;

  {--------------------------------------------------------------------------------------------------------------------}
  procedure CloseDataSet;
  {--------------------------------------------------------------------------------------------------------------------}
  begin
    FQuery.Close;
  end;

  {--------------------------------------------------------------------------------------------------------------------}
  function GetNextEntity: TMaster;
  {--------------------------------------------------------------------------------------------------------------------}
  var
    fieldValues: TFieldsValueReader;
  begin
    Result := nil;

    if not FQuery.Eof then begin

      fieldValues.Query := FQuery;

      Result := TMaster.Create;
      Result.ID := fieldValues.FieldAsStr('ID');
      Result.Description := fieldValues.FieldAsStr('DESCRIPTION');

      FQuery.Next;
    end;
  end;


  {--------------------------------------------------------------------------------------------------------------------}

  function BuildList: TList<TMaster>;
  {--------------------------------------------------------------------------------------------------------------------}
  var
    licenseList: TList<TMaster>;
    license: TMaster;
  begin
    licenseList := TObjectList<TMaster>.Create;
    try
      if OpenDataSet then
        repeat
          license := GetNextEntity;
          if not Assigned(license) then
            Break;
          licenseList.Add(license)
        until False;
    finally
      CloseDataSet;
    end;

    Result := licenseList;
  end;

begin
  Result:=nil;
  Logger.Enter('TRepository.GetMasters');

  try
    Result := BuildList;
    Logger.Info('TRepository.GetMasters :: found for %d masters', [Result.Count]);
  except
    on E: Exception do
      Logger.Error('TRepository.GetMasters :: Exception: ' + E.Message);
  end;

  Logger.Leave('TRepository.GetMasters');
end;


{======================================================================================================================}
function TRepository.GetMaster(const AMasterID: String): TMaster;
{======================================================================================================================}

{$REGION 'Inner functions'}
  {--------------------------------------------------------------------------------------------------------------------}
  function OpenDataSet: Boolean;
  {--------------------------------------------------------------------------------------------------------------------}
  const
    SQL_TEXT =  'SELECT M.*, D.* ' +
                '  FROM MASTERS M ' +
                ' INNER JOIN DETAILS D ' +
                '    ON D.ID = M.ID ' +
                '   AND M.ID = :ID';
  begin
    FQuery.Close;
    FQuery.SQL.Text := SQL_TEXT;
    FQuery.ParamByName('ID').Value := AMasterID;
//    FQuery.Open;
//    Result := not FQuery.Eof;
    Result := False;
  end;

  {--------------------------------------------------------------------------------------------------------------------}
  procedure CloseDataSet;
  {--------------------------------------------------------------------------------------------------------------------}
  begin
    FQuery.Close;
  end;

  {--------------------------------------------------------------------------------------------------------------------}
  function GetNextEntity: TMaster;
  {--------------------------------------------------------------------------------------------------------------------}
  var
    fieldValues: TFieldsValueReader;
    detail: TDetail;
    detailArray: TArray<TDetail>;
    I: Integer;
  begin
    fieldValues.Query := FQuery;

    Result := TMaster.Create;
    Result.ID := fieldValues.FieldAsStr('ID');
    Result.Description := fieldValues.FieldAsStr('DESCRIPTION');

    I := 0;
    while not FQuery.Eof do begin
      detail := TDetail.Create;
      detail.ID := fieldValues.FieldAsStr('ID');
      detail.DetailName := fieldValues.FieldAsStr('DETAILNAME');

      SetLength(detailArray, I + 1);
      detailArray[I] := detail;
      Inc(I);

      FQuery.Next;
    end;
    Result.Details := detailArray;

  end;
{$ENDREGION}

begin
  Logger.Enter('TRepository.GetMaster');

  Result := nil;
  try try
    if OpenDataSet then
      Result := GetNextEntity
    else
      Logger.Info('TRepository.GetMaster :: nothing found for ID %s', [AMasterID]);
  finally
    CloseDataSet;
  end
  except
    on E: Exception do
      Logger.Error('TRepository.GetMaster :: Exception: ' + E.Message);
  end;

  Logger.Leave('TRepository.GetMaster');
end;

{$ENDREGION}

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

function TRepository.RegisterPlayer(const APlayer:TPlayer):TBaseRESTResponse;
begin
  if Assigned(FPlayers.Find(APlayer.Name)) then begin
    Logger.Error('TRepository.RegisterPlayer :: Exception: ' + APlayer.Name +' is just a registered Player');
    Result:=TBaseRESTResponse.BuildResponse(False,APlayer.Name +' is just a registered Player')
  end
  else if FPlayers.Count>=4 then begin
    Logger.Error('TRepository.RegisterPlayer :: Exception: cannot accept more than 4 players');
    Result:=TBaseRESTResponse.BuildResponse(False,'Cannot accept more than 4 players')
  end
  else begin
    FPlayers.Add(TPlayer.Create(APlayer.Name));
    Result:=TBaseRESTResponse.BuildResponse(True)
  end;
end;

end.
