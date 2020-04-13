unit Classes.Entities;

interface
uses Generics.Collections, Neon.Core.Attributes;

type TBaseObjClass=class of TBaseObj;
     TBaseObj=Class(TObject)
     public
       constructor Create;
     end;

     TPlayer=class(TBaseObj)
     private
       FName:String;
     public
       [NeonInclude(Include.Always)]
       property Name:String read FName write FName;
     end;
     TPlayers=TList<TPlayer>;

implementation


{ TBaseObj }

constructor TBaseObj.Create;
begin
  inherited;

end;

end.
