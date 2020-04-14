unit Classes.Entities;

interface
uses Generics.Collections, Neon.Core.Attributes;

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
     public
       [NeonInclude(Include.Always)]
       property Name:String read FName write FName;

       [NeonIgnore]
       property Position:TBoardPosition read FPosition write FPosition;
     end;
     TPlayers=TList<TPlayer>;

implementation


{ TBaseObj }

constructor TBaseObj.Create;
begin
  inherited;

end;

end.
