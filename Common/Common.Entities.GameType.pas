unit Common.Entities.GameType;

interface
uses Spring.Collections.Dictionaries;

type
  TTeamKind=(tkPair,tkSolo,tkOuvert,tkAllOuvert,tkSinglePlayer);
  TTalon=(tkNoTalon,tk3Talon,tk6Talon);
  TWinCondition=(wc12Rounds,wc0Trick,wc1Trick,wc2Trick,wc3Trick,wcT1Trick,wcT2Trick,wcT3Trick,wcT4Trick);

  TGameType=class(TObject)
  private
    FPositive: Boolean;
    FValue: Smallint;
    FTeamKind: TTeamKind;
    FName: String;
    FGameTypeid: String;
    FByFirstPlayer: Boolean;
    FJustColors: Boolean;
    FTalon: TTalon;
    FWinCondition: TWinCondition;
  public
    property GameTypeid:String read FGameTypeid;
    property Name:String read FName;
    property ByFirstPlayer:Boolean read FByFirstPlayer;
    property Positive:Boolean read FPositive;
    property JustColors:Boolean read FJustColors;
    property Talon:TTalon read FTalon;
    property TeamKind:TTeamKind read FTeamKind;
    property Value:Smallint read FValue;
    property WinCondition:TWinCondition read FWinCondition;

    function Clone:TGameType;
  end;

  TGameTypes=class(TDictionary<String,TGameType>)
  public
    function AddItem(const AID:String; const AName:String; const AValue:Smallint; const APositive:Boolean=True;
                     const ATeamKind:TTeamKind=tkPair; const AByFirstPlayer:Boolean=False;
                     const ATalon:TTalon=tk3Talon; const AWinCondition:TWinCondition=wc12Rounds;const AJustColors:Boolean=False):TGameType;
    function Find(const AID:String):TGameType;
  end;

var ALLGAMES:TGameTypes;

  procedure Initialize;
  procedure TearDown;

implementation

{ TGameTypes }

function TGameTypes.AddItem(const AID:String; const AName:String; const
    AValue:Smallint; const APositive:Boolean=True; const
    ATeamKind:TTeamKind=tkPair; const AByFirstPlayer:Boolean=False; const
    ATalon:TTalon=tk3Talon; const AWinCondition:TWinCondition=wc12Rounds ;const AJustColors:Boolean=False): TGameType;
begin
  Result:=TGameType.Create;
  Result.FGameTypeID:=AID;
  REsult.FName:=AName;
  Result.FPositive:=APositive;
  Result.FTalon:=ATalon;
  Result.FJustColors:=AJustColors;
  Result.FTeamKind:=ATeamKind;
  Result.FByFirstPlayer:=AByFirstPlayer;
  Result.FValue:=AValue;
  Result.FWinCondition:=AWinCondition;
  Add(AID,Result);
end;

procedure Initialize;
begin
  ALLGames:=TGameTypes.Create;
  ALLGames.AddItem('RUFER','Königrufer',1,True,tkPair,True);
  ALLGames.AddItem('TRISCH','Trischaken',1,False,tkSinglePlayer,True,tkNoTalon);
  ALLGames.AddItem('63','Sechser-Dreier',1,True,tkSolo,True,tk6Talon);

  ALLGames.AddItem('SUPRA','Solorufer',2,True,tkPair,False,tkNoTalon);
  ALLGames.AddItem('PICC','Piccolo',2,False,tkSolo,False,tkNoTalon,wc1Trick);
  ALLGames.AddItem('GRANDE','Zwiccolo',2,False,tkSolo,False,tkNoTalon,wc2Trick);
  ALLGames.AddItem('TRICC','Triccolo',2,False,tkSolo,False,tkNoTalon,wc3Trick);

  AllGames.AddItem('VOGEL1','Pagatrufer', 3,True,tkPair,False,tk3Talon,wcT1Trick);

  ALLGames.AddItem('BETTL','Bettel',4,False,tkSolo,False,tkNoTalon,wc0Trick);
  AllGames.AddItem('PICC_OU','Piccolo Ouvert',4,False,tkOuvert,False,tkNoTalon,wc1Trick);
  AllGames.AddItem('GRAND_OU','Zwiccolo Ouvert',4,False,tkOuvert,False,tkNoTalon,wc2Trick);
  AllGames.AddItem('TRICC_OU','Triccolo Ouvert',4,False,tkOuvert,False,tkNoTalon,wc3Trick);



  AllGames.AddItem('VOGEL2','Uhurufer',5,True,tkPair,False,tk3Talon,wcT2Trick);
  ALLGames.AddItem('FARB3','Farben-Dreier',5,True,tkSolo,False,tk3Talon,wc12Rounds,True);

  ALLGames.AddItem('SOLO','Dreier',6, True,tkSolo);
  ALLGames.AddItem('BETT_OU','Bettel Ouvert',6,False,tkOuvert,False,tkNoTalon,wc0Trick);
  AllGames.AddItem('PICC_POU','Piccolo Plauderer',6,False,tkAllOuvert,False,tkNoTalon,wc1Trick);
  AllGames.AddItem('GRAND_POU','Zwiccolo Plauderer',6,False,tkAllOuvert,False,tkNoTalon,wc2Trick);
  AllGames.AddItem('TRICCR_POU','Triccolo Plauderer',6,False,tkAllOuvert,False,tkNoTalon,wc3Trick);

  AllGames.AddItem('VOGEL3','Kakadurufer',7,True,tkPair,False,tk3Talon,wcT3Trick);
  AllGames.AddItem('SVOGEL1','Pagatdreier',8,True,tkSolo,False,tk3Talon,wcT1Trick);

  ALLGames.AddItem('BETT_POU','Bettel Plauderer',8,False,tkAllOuvert,False,tkNoTalon,wc0Trick);

  AllGames.AddItem('VOGEL4','Quapilrufer',9,True,tkPair,False,tk3Talon,wcT4Trick);

  AllGames.AddItem('SVOGEL2','Uhudreier',10,True,tkSolo,False,tk3Talon,wcT2Trick);
  ALLGames.AddItem('FARBSOLO','Farben-Solo',10,True,tkSolo,False,tkNoTalon,wc12Rounds,True);

  AllGames.AddItem('SVOGEL3','Kakadudreier',12,True,tkSolo,False,tk3Talon,wcT3Trick);
  ALLGames.AddItem('SOLLIS','Solo Dreier',12,True,tkSolo,False,tkNoTalon);

  AllGames.AddItem('SVOGEL4','Quapildreier',14,True,tkSolo,False,tk3Talon,wcT4Trick);
  (* Wiener VAriante
   ALLGames.AddItem('ENTRO','Entro (Königsrufer)',1,True,tkPair,True);
  ALLGames.AddItem('63','Sechser-Dreier',2,True,tkSolo,True);

  ALLGames.AddItem('SUPRA','Supra (Solorufer)',2,True,tkPair,False,tkNoTalon);
  ALLGames.AddItem('PICC','Piccolo',2,False,tkSolo);
  ALLGames.AddItem('GRANDE','Grande (Zwiccolo)',2,False,tkSolo);

  ALLGames.AddItem('BETTL','Bettel',3,False,tkSolo);
  AllGames.AddItem('VOGEL1','Vogel I (Besser Rufer)', 3);

  ALLGames.AddItem('SOLO','Solo (Dreier)',4,True,tkSolo);
  AllGames.AddItem('VOGEL2','Vogel II (Besser Rufer)',4);

  AllGames.AddItem('VOGEL3','Vogel III (Besser Rufer)',5);
  AllGames.AddItem('SVOGEL1','Solo Vogel I (Besser Dreier)',5,True,tkSolo);
  AllGames.AddItem('PICCOU','Piccolo Ouvert',5,False,tkOuvert);
  AllGames.AddItem('GRANDOU','Grande (Zwiccolo) Ouvert',5,False,tkOuvert);

  AllGames.AddItem('VOGEL4','Vogel IV (Besser Rufer)',6);
  AllGames.AddItem('SVOGEL2','Solo Vogel II (Besser Dreier)',6,True,tkSolo);
  ALLGames.AddItem('FARB3','Farben-Solo',6,True,tkSolo,False,tkNoTalon);
  ALLGames.AddItem('BETTOU','Bettel Ouvert',6,False,tkOuvert);

  AllGames.AddItem('SVOGEL3','Solo Vogel III (Besser Dreier)',7,True,tkSolo);

  ALLGames.AddItem('SOLLIS','Solissimo (Solo Dreier)',8,True,tkSolo,False,tkNoTalon);
  AllGames.AddItem('SVOGEL4','Solo Vogel IV (Besser Dreier)',8,True,tkSolo);
  *)
end;

procedure TearDown;
begin
  ALLGAMES.Free;
  ALLGAMES:=nil;
end;

function TGameTypes.Find(const AID: String): TGameType;
begin
  try
    Result:=GetItem(AID);
  except
    Result:=nil;
  end;
end;

{ TGameType }

function TGameType.Clone: TGameType;
begin
  Result:=TGameType.Create;
  Result.FGameTypeid:=FGameTypeId;
  Result.FName:=FName;
  Result.FByFirstPlayer:=FByFirstPlayer;
  Result.FPositive:=FPositive;
  Result.FJustColors:=FJustColors;
  Result.FTalon:=FTalon;
  Result.FTeamKind:=FTeamKind;
  Result.FValue:=FValue;
  Result.FWinCondition:=FWincondition;
end;

end.
