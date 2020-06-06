unit Common.Entities.Player;

interface

uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections;

type
  TBetState=(btNone,btBet,btPass,btHold);
  TTeam=(ttTeam1,ttTeam2,ttNone);

  TPlayer=class
  private
    FName:String;
    FScore: Integer;
    FBetState: TBetState;
    FTeam: TTeam;
  public
    constructor Create(const AName:String);overload;
   // constructor Create;
    destructor Destroy;override;
    function ToString:String;override;

    [NeonInclude(Include.Always)]
    property Name:String read FName write FName;
    property BetState:TBetState read FBetState write FBetState;
    property Score: Integer read FScore write FScore;
    property Team:TTeam read FTeam write FTeam;

    procedure Assign(const ASource:TPlayer);virtual;
  end;

  TPlayers<T:TPlayer>=class(TObjectList<T>)
  public

    function Clone<T2:TPlayer, constructor>:TPlayers<T2>;
    function Find(AName:String):T;
  end;

implementation

uses
  System.SysUtils
;


{ TPlayer }

procedure TPlayer.Assign(const ASource: TPlayer);
begin
  FName:=ASource.Name;
  FScore:=ASource.Score;
  FBetState:=ASource.BetState;
  FTeam:=ASource.FTeam;
end;

constructor TPlayer.Create(const AName: String);
begin
  inherited Create;
  FName:=AName;
  FBetState:=btNone;
  FScore:=0;
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

function TPlayers<T>.Clone<T2>: TPlayers<T2>;
var p:T;
    p2:T2;
begin
  Result:=TPlayers<T2>.Create;
  for p in Self do begin
    p2:=T2.Create;
    p2.Assign(p);
    Result.Add(p2)
  end;
end;

function TPlayers<T>.Find(AName: String): T;
var itm:T;
begin
  Result:=nil;
  AName:=AnsiUppercase(AName);
  for itm in Self do begin
    if AnsiUppercase(itm.Name)=AName then begin
      Result:=itm;
      Break;
    end;
  end;
end;

end.
