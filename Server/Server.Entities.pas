unit Server.Entities;

interface

uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections
;

type
  TPlayer=class
  private
    FName:String;
  public
    constructor Create(const AName:String);
    destructor Destroy;override;
    function ToString:String;override;

    [NeonInclude(Include.Always)]
    property Name:String read FName write FName;
  end;

  TPlayers=class(TObjectList<TPlayer>)
  public
    function Clone:TPlayers;
    function Find(AName:String):TPlayer;
  end;

implementation

uses
  System.SysUtils
;


{ TPlayer }

constructor TPlayer.Create(const AName: String);
begin
  inherited Create;
  FName:=AName;
end;

destructor TPlayer.Destroy;
begin
  inherited;
end;

function TPlayer.ToString: String;
const
  FMT = 'Name: %s';
begin
  Result := Format(FMT, [FName]);
end;

{ TPlayers }

function TPlayers.Clone: TPlayers;
var p:TPlayer;
begin
  Result:=TPlayers.Create;
  for p in Self do
    Result.Add(TPlayer.Create(p.Name));
end;

function TPlayers.Find(AName: String): TPlayer;
var itm:TPlayer;
begin
  Result:=nil;
  AName:=Uppercase(AName);
  for itm in Self do begin
    if Uppercase(itm.Name)=AName then begin
      Result:=itm;
      Break;
    end;
  end;
end;

end.
