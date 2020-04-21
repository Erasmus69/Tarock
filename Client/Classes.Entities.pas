unit Classes.Entities;

interface
uses cxLabel,Vcl.ExtCtrls,Generics.Collections;

type TBaseObjClass=class of TBaseObj;
     TBaseObj=Class(TObject)
     public
       constructor Create;
     end;

     TBoardPosition=(bpDown,bpLeft,bpUp,bpRight);

     TPlayer=class(TBaseObj)
     private
       FName:String;
       FPosition:TBoardPosition;
       FCardImage: TImage;
       FPlayerLabel: TcxLabel;
     public
       property Name:String read FName write FName;
       property Position:TBoardPosition read FPosition write FPosition;
       property PlayerLabel:TcxLabel read FPlayerLabel write FPlayerLabel;
       property CardImage:TImage read FCardImage write FCardImage;
     end;
     TPlayers=class(TObjectList<TPlayer>)
     public
       function Find(const APlayerName:String):TPlayer;
     end;

implementation


{ TBaseObj }

constructor TBaseObj.Create;
begin
  inherited;

end;

{ TPlayers }

function TPlayers.Find(const APlayerName: String): TPlayer;
var itm:TPlayer;
begin
  Result:=Nil;
  for itm in Self do begin
    if itm.Name=APlayerName then begin
      Result:=itm;
      Break;
    end;
  end;
end;

end.
