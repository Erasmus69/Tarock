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
    function ToString:String;override;

    [NeonInclude(Include.Always)]
    property Name:String read FName write FName;
  end;

  TPlayers=class(TList<TPlayer>)
  public
    procedure Clone(const ASource:TPlayers);
    function Find(AName:String):TPlayer;
  end;

  TDetail = class;

  TMaster = class
  private
    FID: String;
    FDescription: String;
    FDetails: TArray<TDetail>;
  public
    function ToString: String; override;

    property ID: String read FID write FID;
    property Description: String read FDescription write FDescription;
    property Details: TArray<TDetail> read FDetails write FDetails;
  end;

  TDetail = class(TObject)
  private
    FID: String;
    FDetailName: String;
  public
    function ToString: String; override;

    property ID: String read FID write FID;
    property DetailName: String read FDetailName write FDetailName;
  end;

implementation

uses
  System.SysUtils
;

{ TMaster }

{======================================================================================================================}
function TMaster.ToString: String;
{======================================================================================================================}
const
  FMT = 'ID: %s|Description: %s';
begin
  Result := Format(FMT, [
    ID,
    Description
  ]);
end;

{ TDetail }

{======================================================================================================================}
function TDetail.ToString: String;
{======================================================================================================================}
const
  FMT = 'ID: %s|DetailName: %s';
begin
  Result := Format(FMT, [
    ID,
    DetailName
  ]);
end;

{ TPlayer }

constructor TPlayer.Create(const AName: String);
begin
  inherited Create;
  FName:=AName;
end;

function TPlayer.ToString: String;
const
  FMT = 'Name: %s';
begin
  Result := Format(FMT, [FName]);
end;

{ TPlayers }

procedure TPlayers.Clone(const ASource: TPlayers);
var p:TPlayer;
begin
  for p in ASource do
    Add(TPlayer.Create(p.Name));
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
