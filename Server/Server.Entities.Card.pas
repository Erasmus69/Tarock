unit Server.Entities.Card;

interface
uses
  Spring, Neon.Core.Attributes,
  System.Generics.Collections,Graphics;

type
  TCardType=(ctTarock,ctHeart,ctSpade,ctCross,ctDiamond);
  TCardKey=(T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,
             H1,H2,H3,H4,HB,HR,HD,HK,D1,D2,D3,D4,DB,DR,DD,DK,
             S7,S8,S9,S10,SB,SR,SD,SK,C7,C8,C9,C10,CB,CR,CD,CK);

  TCard=class(TObject)
    ID:TCardKey;
    CType:TCardType;
    Value:Byte;
    ImageIndex:Integer;
  end;

  TCards=class(TObjectDictionary<TCardKey,TCard>)
  public
    function AddItem(AID:TCardKey;ACType:TCardType;AValue:Byte;AImageIdx:Integer=-1):TCard;
    function Clone:TCards;
  end;

var ALLCARDS:TCards;

  procedure Initialize;
  procedure TearDown;

implementation

procedure Initialize;
begin
  ALLCARDS:=TCards.Create([doOwnsValues]);
  ALLCARDS.AddItem(T1,ctTarock,1,0);
  ALLCARDS.AddItem(T2,ctTarock,2);
  ALLCARDS.AddItem(T3,ctTarock,3);
  ALLCARDS.AddItem(T4,ctTarock,4);
  ALLCARDS.AddItem(T5,ctTarock,5);
  ALLCARDS.AddItem(T6,ctTarock,6);
  ALLCARDS.AddItem(T7,ctTarock,7);
  ALLCARDS.AddItem(T8,ctTarock,8);
  ALLCARDS.AddItem(T9,ctTarock,9);
  ALLCARDS.AddItem(T10,ctTarock,10);
  ALLCARDS.AddItem(T11,ctTarock,11);
  ALLCARDS.AddItem(T12,ctTarock,12);
  ALLCARDS.AddItem(T13,ctTarock,13);
  ALLCARDS.AddItem(T14,ctTarock,14);
  ALLCARDS.AddItem(T15,ctTarock,15);
  ALLCARDS.AddItem(T16,ctTarock,16);
  ALLCARDS.AddItem(T17,ctTarock,17);
  ALLCARDS.AddItem(T18,ctTarock,18);
  ALLCARDS.AddItem(T19,ctTarock,19);
  ALLCARDS.AddItem(T20,ctTarock,20);
  ALLCARDS.AddItem(T21,ctTarock,21,1);
  ALLCARDS.AddItem(T22,ctTarock,22,2);
  ALLCARDS.AddItem(H1,ctHeart,1);
  ALLCARDS.AddItem(H2,ctHeart,2);
  ALLCARDS.AddItem(H3,ctHeart,3);
  ALLCARDS.AddItem(H4,ctHeart,4);
  ALLCARDS.AddItem(HB,ctHeart,5);
  ALLCARDS.AddItem(HR,ctHeart,6);
  ALLCARDS.AddItem(HD,ctHeart,7);
  ALLCARDS.AddItem(HK,ctHeart,8);
  ALLCARDS.AddItem(D1,ctDiamond,1);
  ALLCARDS.AddItem(D2,ctDiamond,2);
  ALLCARDS.AddItem(D3,ctDiamond,3);
  ALLCARDS.AddItem(D4,ctDiamond,4);
  ALLCARDS.AddItem(DB,ctDiamond,5);
  ALLCARDS.AddItem(DR,ctDiamond,6);
  ALLCARDS.AddItem(DD,ctDiamond,7);
  ALLCARDS.AddItem(DK,ctDiamond,8);
  ALLCARDS.AddItem(S7,ctSpade,1);
  ALLCARDS.AddItem(S8,ctSpade,2);
  ALLCARDS.AddItem(S9,ctSpade,3);
  ALLCARDS.AddItem(S10,ctSpade,4);
  ALLCARDS.AddItem(SB,ctSpade,5,3);
  ALLCARDS.AddItem(SR,ctSpade,6,4);
  ALLCARDS.AddItem(SD,ctSpade,7,5);
  ALLCARDS.AddItem(SK,ctSpade,8,6);
  ALLCARDS.AddItem(C7,ctCross,1);
  ALLCARDS.AddItem(C8,ctCross,2);
  ALLCARDS.AddItem(C9,ctCross,3);
  ALLCARDS.AddItem(C10,ctCross,4);
  ALLCARDS.AddItem(CB,ctCross,5);
  ALLCARDS.AddItem(CR,ctCross,6);
  ALLCARDS.AddItem(CD,ctCross,7);
  ALLCARDS.AddItem(CK,ctCross,8);
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
  Add(AID,Result);
end;

function TCards.Clone:TCards;
var itm:TCard;
begin
  Result:=TCards.Create([doOwnsValues]);

  for itm in Values do
    Result.AddItem(itm.ID,itm.CType,itm.Value,itm.ImageIndex);
end;

end.
