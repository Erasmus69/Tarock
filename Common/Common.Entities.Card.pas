unit Common.Entities.Card;

interface
uses
  Spring, Neon.Core.Attributes, System.Generics.Defaults,
  System.Generics.Collections,Graphics, System.JSON,  Neon.Core.Types,
  Neon.Core.Persistence;

type
  TCardType=(ctTarock,ctHeart,ctSpade,ctCross,ctDiamond);

  [NeonInclude(IncludeIf.Always)]
  TCardKey=(None,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,
             H1,H2,H3,H4,HB,HR,HD,HK,D1,D2,D3,D4,DB,DR,DD,DK,
             S7,S8,S9,S10,SB,SR,SD,SK,C7,C8,C9,C10,CB,CR,CD,CK);

  TCard=class(TObject)
  private
    FFold: Boolean;
    FID: TCardKey;
    FValue: Byte;
    FImageIndex: Integer;
    FCType: TCardType;
    FPoints: Byte;

  public
    property ID:TCardKey read FID write FID;
    property CType:TCardType read FCType write FCType;
    property Value:Byte read FValue write FValue;
    property Points:Byte read FPoints write FPoints;
    property ImageIndex:Integer read FImageIndex write FImageIndex;
    property Fold:Boolean read FFold write FFold;

    procedure Assign(const ASource:TCard);
    function Clone:TCard;
    function IsStronger(const ACard:TCard; const AColorGame:Boolean):Boolean;
  end;

  TCardsComparer=class(TComparer<TCard>)
    function Compare(const Left, Right: TCard): Integer; override;
  end;
  TCards=class(TObjectList<TCard>)
  private
    function GetUnFoldCount: Integer;
  public
    function AddItem(AID:TCardKey;ACType:TCardType;AValue:Byte;APoints:Byte;AImageIdx:Integer):TCard;
    function Clone:TCards;
    procedure Assign(const ASource:TCards);
    function Find(const AID:TCardKey):TCard;
    function Exists(const AID:TCardKey):Boolean;
    function ExistsUnfold(const AID: TCardKey): Boolean;
    function ExistsCardType(const ACType:TCardType):Boolean;
    function ExistsStronger(const ACard:TCard; const AColorGame:Boolean):Boolean;
    procedure Sort;
    property UnFoldCount:Integer read GetUnFoldCount;
  end;

  TCardKeySerializer=class(TCustomSerializer)
  protected
    class function GetTargetInfo: PTypeInfo; override;
 //   class function CanHandle(AType: PTypeInfo): Boolean; override;
  public
    function Serialize(const AValue: TValue; ANeonObject: TNeonRttiObject;  AContext: ISerializerContext): TJSONValue; override;
    function Deserialize(AValue:TJsonValue;const AData:TValue;ANeonObject: TNeonRttiObject; AContext:IDeserializerContext):TValue;override;
  end;

var ALLCARDS:TCards;

  procedure Initialize;
  procedure TearDown;

implementation
uses SysUtils;

procedure Initialize;
begin
  ALLCARDS:=TCards.Create;
  ALLCARDS.AddItem(T1,ctTarock,1,5,0);
  ALLCARDS.AddItem(T2,ctTarock,2,1,1);
  ALLCARDS.AddItem(T3,ctTarock,3,1,2);
  ALLCARDS.AddItem(T4,ctTarock,4,1,3);
  ALLCARDS.AddItem(T5,ctTarock,5,1,4);
  ALLCARDS.AddItem(T6,ctTarock,6,1,5);
  ALLCARDS.AddItem(T7,ctTarock,7,1,6);
  ALLCARDS.AddItem(T8,ctTarock,8,1,7);
  ALLCARDS.AddItem(T9,ctTarock,9,1,8);
  ALLCARDS.AddItem(T10,ctTarock,10,1,9);
  ALLCARDS.AddItem(T11,ctTarock,11,1,10);
  ALLCARDS.AddItem(T12,ctTarock,12,1,11);
  ALLCARDS.AddItem(T13,ctTarock,13,1,12);
  ALLCARDS.AddItem(T14,ctTarock,14,1,13);
  ALLCARDS.AddItem(T15,ctTarock,15,1,14);
  ALLCARDS.AddItem(T16,ctTarock,16,1,15);
  ALLCARDS.AddItem(T17,ctTarock,17,1,16);
  ALLCARDS.AddItem(T18,ctTarock,18,1,17);
  ALLCARDS.AddItem(T19,ctTarock,19,1,18);
  ALLCARDS.AddItem(T20,ctTarock,20,1,19);
  ALLCARDS.AddItem(T21,ctTarock,21,5,20);
  ALLCARDS.AddItem(T22,ctTarock,22,5,21);
  ALLCARDS.AddItem(H4,ctHeart,1,1,22);
  ALLCARDS.AddItem(H3,ctHeart,2,1,23);
  ALLCARDS.AddItem(H2,ctHeart,3,1,24);
  ALLCARDS.AddItem(H1,ctHeart,4,1,25);
  ALLCARDS.AddItem(HB,ctHeart,5,2,26);
  ALLCARDS.AddItem(HR,ctHeart,6,3,27);
  ALLCARDS.AddItem(HD,ctHeart,7,4,28);
  ALLCARDS.AddItem(HK,ctHeart,8,5,29);
  ALLCARDS.AddItem(D4,ctDiamond,1,1,30);
  ALLCARDS.AddItem(D3,ctDiamond,2,1,31);
  ALLCARDS.AddItem(D2,ctDiamond,3,1,32);
  ALLCARDS.AddItem(D1,ctDiamond,4,1,33);
  ALLCARDS.AddItem(DB,ctDiamond,5,2,34);
  ALLCARDS.AddItem(DR,ctDiamond,6,3,35);
  ALLCARDS.AddItem(DD,ctDiamond,7,4,36);
  ALLCARDS.AddItem(DK,ctDiamond,8,5,37);
  ALLCARDS.AddItem(C7,ctCross,1,1,38);
  ALLCARDS.AddItem(C8,ctCross,2,1,39);
  ALLCARDS.AddItem(C9,ctCross,3,1,40);
  ALLCARDS.AddItem(C10,ctCross,4,1,41);
  ALLCARDS.AddItem(CB,ctCross,5,2,42);
  ALLCARDS.AddItem(CR,ctCross,6,3,43);
  ALLCARDS.AddItem(CD,ctCross,7,4,44);
  ALLCARDS.AddItem(CK,ctCross,8,5,45);
  ALLCARDS.AddItem(S7,ctSpade,1,1,46);
  ALLCARDS.AddItem(S8,ctSpade,2,1,47);
  ALLCARDS.AddItem(S9,ctSpade,3,1,48);
  ALLCARDS.AddItem(S10,ctSpade,4,1,49);
  ALLCARDS.AddItem(SB,ctSpade,5,2,50);
  ALLCARDS.AddItem(SR,ctSpade,6,3,51);
  ALLCARDS.AddItem(SD,ctSpade,7,4,52);
  ALLCARDS.AddItem(SK,ctSpade,8,5,53);
end;

procedure TearDown;
begin
  ALLCARDS.Free;
  ALLCARDS:=nil;
end;

{ TCards }

function TCards.AddItem(AID:TCardKey;ACType:TCardType;AValue:Byte;APoints:Byte; AImageIdx:Integer): TCard;
begin
  Result:=TCard.Create;
  Result.ID:=AID;
  Result.CType:=ACType;
  Result.Value:=AValue;
  Result.Points:=APoints;
  Result.ImageIndex:=AImageIdx;
  Result.Fold:=False;
  Add(Result);
end;

function TCards.Clone:TCards;
begin
  Result:=TCards.Create(True);
  Result.Assign(Self);
end;

function TCards.Exists(const AID: TCardKey): Boolean;
begin
  Result:=Assigned(Find(AID));
end;

function TCards.ExistsUnfold(const AID: TCardKey): Boolean;
var itm:TCard;
begin
  itm:=Find(AID);
  Result:=Assigned(itm) and not itm.Fold;
end;

function TCards.ExistsCardType(const ACType: TCardType): Boolean;
var itm:TCard;
begin
  Result:=False;
  for itm in Self do begin
    if not itm.Fold and (itm.CType=ACType) then begin
      Result:=True;
      Exit;
    end;
  end;
end;

function TCards.ExistsStronger(const ACard: TCard; const AColorGame:Boolean): Boolean;
var itm:TCard;
begin
  Result:=False;
  for itm in Self do begin
    if not itm.Fold and itm.IsStronger(ACard,AColorGame) then begin
      Result:=True;
      Break;
    end;
  end;
end;

function TCards.Find(const AID:TCardKey): TCard;
var itm:TCard;
begin
  Result:=nil;
  for itm in Self do begin
    if itm.ID=AID then begin
      Result:=itm;
      Break;
    end;
  end;
end;

function TCards.GetUnFoldCount: Integer;
var
  itm: TCard;
begin
  Result:=0;
  for itm in Self do
    if not itm.Fold then
      Inc(Result);
end;

procedure TCards.Sort;
var comp:TCardsComparer;
begin
  comp:=TCardsComparer.Create;
  try
    inherited Sort(comp)
  finally
    comp.Free;
  end;
end;

procedure TCards.Assign(const ASource:TCards);
var itm:TCard;
begin
  for itm in ASource do begin
    AddItem(itm.ID,itm.CType,itm.Value,itm.Points,itm.ImageIndex).Fold:=itm.Fold;
  end;
end;

{ TCardsComparer }

function TCardsComparer.Compare(const Left, Right: TCard): Integer;
begin
  if Ord(Left.CType)=Ord(Right.CType) then begin
    Result:=Left.Value-Right.Value
  end
  else
    Result:=Ord(Left.CType)-Ord(Right.CType);
end;

{ TCard }

procedure TCard.Assign(const ASource: TCard);
begin
  FID:=ASource.FID;
  FCType:=ASource.FCType;
  FValue:=ASource.FValue;
  FImageIndex:=ASource.FImageIndex;
  FFold:=ASource.FFold;
end;


function TCard.Clone: TCard;
begin
  Result:=TCard.Create;
  Result.Assign(Self);
end;

function TCard.IsStronger(const ACard: TCard; const AColorGame:Boolean): Boolean;
begin
  if CType=ACard.CType then
    Result:=Value>ACard.Value
  else if not AColorGame then
    Result:=CType=ctTarock
  else
    Result:=false;
end;

{ TCardKeySerializer }

function TCardKeySerializer.Deserialize(AValue:TJsonValue;const AData:TValue;
    ANeonObject: TNeonRttiObject; AContext:IDeserializerContext): TValue;
var cd:TCardKey;
begin
  inherited;
  cd:=TCardKey(StrToInt(AValue.ToString));
  Result:= TValue.From<TCardKey>(cd)
end;

class function TCardKeySerializer.GetTargetInfo: PTypeInfo;
begin
  Result := TypeInfo(TCardKey);
end;

function TCardKeySerializer.Serialize(const AValue: TValue; ANeonObject:  TNeonRttiObject; AContext: ISerializerContext): TJSONValue;
begin
  Result:=TJSONNumber.Create(AValue.AsOrdinal);
end;

end.
