unit Common.Entities.Card;

interface
uses
  Spring, Neon.Core.Attributes, System.Generics.Defaults,
  System.Generics.Collections,Graphics, System.JSON,  Neon.Core.Types,
  Neon.Core.Persistence;

type
  TCardType=(ctTarock,ctHeart,ctSpade,ctCross,ctDiamond);

  [NeonInclude(Include.Always)]
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

  public
    property ID:TCardKey read FID write FID;
    property CType:TCardType read FCType write FCType;
    property Value:Byte read FValue write FValue;
    property ImageIndex:Integer read FImageIndex write FImageIndex;
    property Fold:Boolean read FFold write FFold;

    procedure Assign(const ASource:TCard);
  end;

  TCardsComparer=class(TComparer<TCard>)
    function Compare(const Left, Right: TCard): Integer; override;
  end;
  TCards=class(TObjectList<TCard>)
  public
    function AddItem(AID:TCardKey;ACType:TCardType;AValue:Byte;AImageIdx:Integer=-1):TCard;
    function Clone:TCards;
    procedure Assign(const ASource:TCards);
    function Find(AID:TCardKey):TCard;
  end;

  TCardKeySerializer=class(TCustomSerializer)
  protected
    class function GetTargetInfo: PTypeInfo; override;
 //   class function CanHandle(AType: PTypeInfo): Boolean; override;
  public
    function Serialize(const AValue: TValue; AContext: ISerializerContext): TJSONValue; override;
    function Deserialize(AValue:TJsonValue;const AData:TValue; AContext:IDeserializerContext):TValue;override;
  end;

var ALLCARDS:TCards;

  procedure Initialize;
  procedure TearDown;

implementation
uses SysUtils;

procedure Initialize;
begin
  ALLCARDS:=TCards.Create;
  ALLCARDS.AddItem(T1,ctTarock,1,0);
  ALLCARDS.AddItem(T2,ctTarock,2,1);
  ALLCARDS.AddItem(T3,ctTarock,3,2);
  ALLCARDS.AddItem(T4,ctTarock,4,3);
  ALLCARDS.AddItem(T5,ctTarock,5,4);
  ALLCARDS.AddItem(T6,ctTarock,6,5);
  ALLCARDS.AddItem(T7,ctTarock,7,6);
  ALLCARDS.AddItem(T8,ctTarock,8,7);
  ALLCARDS.AddItem(T9,ctTarock,9,8);
  ALLCARDS.AddItem(T10,ctTarock,10,9);
  ALLCARDS.AddItem(T11,ctTarock,11,10);
  ALLCARDS.AddItem(T12,ctTarock,12,11);
  ALLCARDS.AddItem(T13,ctTarock,13,12);
  ALLCARDS.AddItem(T14,ctTarock,14,13);
  ALLCARDS.AddItem(T15,ctTarock,15,14);
  ALLCARDS.AddItem(T16,ctTarock,16,15);
  ALLCARDS.AddItem(T17,ctTarock,17,16);
  ALLCARDS.AddItem(T18,ctTarock,18,17);
  ALLCARDS.AddItem(T19,ctTarock,19,18);
  ALLCARDS.AddItem(T20,ctTarock,20,19);
  ALLCARDS.AddItem(T21,ctTarock,21,20);
  ALLCARDS.AddItem(T22,ctTarock,22,21);
  ALLCARDS.AddItem(H4,ctHeart,1,22);
  ALLCARDS.AddItem(H3,ctHeart,2,23);
  ALLCARDS.AddItem(H2,ctHeart,3,24);
  ALLCARDS.AddItem(H1,ctHeart,4,25);
  ALLCARDS.AddItem(HB,ctHeart,5,26);
  ALLCARDS.AddItem(HR,ctHeart,6,27);
  ALLCARDS.AddItem(HD,ctHeart,7,28);
  ALLCARDS.AddItem(HK,ctHeart,8,29);
  ALLCARDS.AddItem(D4,ctDiamond,1,30);
  ALLCARDS.AddItem(D3,ctDiamond,2,31);
  ALLCARDS.AddItem(D2,ctDiamond,3,32);
  ALLCARDS.AddItem(D1,ctDiamond,4,33);
  ALLCARDS.AddItem(DB,ctDiamond,5,34);
  ALLCARDS.AddItem(DR,ctDiamond,6,35);
  ALLCARDS.AddItem(DD,ctDiamond,7,36);
  ALLCARDS.AddItem(DK,ctDiamond,8,37);
  ALLCARDS.AddItem(C7,ctCross,1,38);
  ALLCARDS.AddItem(C8,ctCross,2,39);
  ALLCARDS.AddItem(C9,ctCross,3,40);
  ALLCARDS.AddItem(C10,ctCross,4,41);
  ALLCARDS.AddItem(CB,ctCross,5,42);
  ALLCARDS.AddItem(CR,ctCross,6,43);
  ALLCARDS.AddItem(CD,ctCross,7,44);
  ALLCARDS.AddItem(CK,ctCross,8,45);
  ALLCARDS.AddItem(S7,ctSpade,1,46);
  ALLCARDS.AddItem(S8,ctSpade,2,47);
  ALLCARDS.AddItem(S9,ctSpade,3,48);
  ALLCARDS.AddItem(S10,ctSpade,4,49);
  ALLCARDS.AddItem(SB,ctSpade,5,50);
  ALLCARDS.AddItem(SR,ctSpade,6,51);
  ALLCARDS.AddItem(SD,ctSpade,7,52);
  ALLCARDS.AddItem(SK,ctSpade,8,53);
end;

procedure TearDown;
begin
  ALLCARDS.Free;
  ALLCARDS:=nil;
end;

{ TCards }

function TCards.AddItem(AID: TCardKey; ACType: TCardType; AValue: Byte; AImageIdx:Integer): TCard;
begin
  Result:=TCard.Create;
  Result.ID:=AID;
  Result.CType:=ACType;
  Result.Value:=AValue;
  Result.ImageIndex:=AImageIdx;
  Result.Fold:=False;
  Add(Result);
end;

function TCards.Clone:TCards;
begin
  Result:=TCards.Create;
  Result.Assign(Self);
end;

function TCards.Find(AID: TCardKey): TCard;
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

procedure TCards.Assign(const ASource:TCards);
var itm:TCard;
begin
  for itm in ASource do
    AddItem(itm.ID,itm.CType,itm.Value,itm.ImageIndex);
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


{ TCardKeySerializer }

function TCardKeySerializer.Deserialize(AValue: TJsonValue; const AData: TValue; AContext: IDeserializerContext):TValue;
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

function TCardKeySerializer.Serialize(const AValue: TValue; AContext: ISerializerContext): TJSONValue;
begin
  Result:=TJSONNumber.Create(AValue.AsOrdinal);
end;

end.
