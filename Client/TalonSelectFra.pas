unit TalonSelectFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, cxLabel, Vcl.ExtCtrls, Classes.CardControl;

type
  TfraTalonSelect = class(TFrame)
    pBackground: TPanel;
    pCards: TPanel;
    lCaption: TcxLabel;
    Panel2: TPanel;
    bOK: TcxButton;
    bLeft: TcxButton;
    bRight: TcxButton;
    procedure bLeftClick(Sender: TObject);
    procedure bRightClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FCards:TArray<TCardControl>;
    constructor Create(AOwner:TComponent); override;
  end;

implementation

uses
  Common.Entities.Card, TarockDM, Common.Entities.GameType, TarockFrm;

{$R *.dfm}

const CARDXOFFSET=90;

{ TfraTalonSelect }

procedure TfraTalonSelect.bLeftClick(Sender: TObject);
var i: Integer;
begin
  for i:=0 to 2 do
    FCards[i].Enabled:=True;
  for i:=3 to 5 do begin
    FCards[i].Enabled:=False;
    FCards[i].Up:=False;
  end;

  lCaption.Caption:='Wähle die 3 Karten, die du weglegen willst';
  bOK.Enabled:=True;
  dm.NewGameInfo(dm.MyName+' hat den linken Talon gewaehlt');
end;

procedure TfraTalonSelect.bOKClick(Sender: TObject);
var
  i: Integer;
  upCards: Integer;
  selectedCards:TCards;
  c:TCard;
  normalCards: Integer;
  selectedForbiddenCards:Integer;
begin
  selectedCards:=TCards.Create(true);
  try
    for I:=0 to 5 do begin
      if FCards[i].Up then
        selectedCards.Add(FCards[i].Card.Clone)
    end;

    for i:=0 to TfrmTarock(Owner).pMyCards.ControlCount-1 do begin
      if (TfrmTarock(Owner).pMyCards.Controls[i] is TCardControl) and TCardControl(TfrmTarock(Owner).pMyCards.Controls[i]).Up  then
        selectedCards.Add(TCardControl(TfrmTarock(Owner).pMyCards.Controls[i]).Card.Clone)
    end;

    if (dm.ActGame.Talon=tk3Talon) and (selectedCards.Count<>3) then begin
      Beep;
      ShowMessage('Du musst genau 3 Karten aus Talon oder Hand zur Ablage auswählen')
    end
    else if (dm.ActGame.Talon=tk6Talon) and (selectedCards.Count<>6) then begin
      Beep;
      ShowMessage('Du musst genau 6 Karten aus Talon oder Hand zur Ablage auswählen')
    end
    else begin
      for c in selectedcards do begin
        if c.ID in [HK,CK,DK,SK] then begin
          Beep;
          ShowMessage('Du darfst keine Könige ablegen');
          Exit;
        end
        else if c.ID in [T1,T21,T22] then begin
          Beep;
          ShowMessage('Du darfst kein Trullstück ablegen');
          Exit;
        end;
      end;

      if dm.ActGame.JustColors then begin
        selectedForbiddenCards:=0;
        for c in selectedCards do begin
          if c.CType<>ctTarock then begin
            Inc(selectedForbiddenCards);
            Break;
          end;
        end;
        if selectedForbiddenCards>0 then begin
          normalCards:=0;
          for c in dm.MyCards do begin
            if (c.CType=ctTarock) then
              Inc(normalCards);
          end;
          if normalcards>selectedCards.Count-selectedForbiddenCards then begin
            Beep;
            ShowMessage('Du darfst Farben erst ablegen, wenn du nicht genügend Tarock hast');
            Exit;
          end;
        end;
      end
      else begin
        selectedForbiddenCards:=0;
        for c in selectedCards do begin
          if c.CType=ctTarock then begin
            Inc(selectedForbiddenCards);
            Break;
          end;
        end;
        if selectedForbiddenCards>0 then begin
          normalCards:=0;
          for c in dm.MyCards do begin
            if (c.CType<>ctTarock) and not (c.Id in [HK,CK,DK,SK]) then
              Inc(normalCards);
          end;
          if normalcards>selectedCards.Count-selectedForbiddenCards then begin
            Beep;
            ShowMessage('Du darfst Tarock erst ablegen, wenn du nicht genügend normale Karten hast');
            Exit;
          end;
        end;
      end;

      for I:=0 to 5 do begin   // add talon cards for other team
        if not FCards[i].Enabled then begin
          c:=FCards[i].Card.Clone;
          c.Fold:=True;       // sign that belongs to other team
          selectedCards.Add(c)
        end;
      end;
      dm.LayDownCards(selectedCards);
    end;
  finally
    selectedCards.Free;
  end;
end;

procedure TfraTalonSelect.bRightClick(Sender: TObject);
var i: Integer;
begin
  for i:=0 to 2 do begin
    FCards[i].Enabled:=False;
    FCards[i].Up:=False;
  end;
  for i:=3 to 5 do
    FCards[i].Enabled:=True;
  bOK.Enabled:=True;
  dm.NewGameInfo(dm.MyName+' hat den rechten Talon gewaehlt');
end;

constructor TfraTalonSelect.Create(AOwner: TComponent);
var card:TCard;
    i: Integer;
    imgLeft: Integer;
begin
  inherited;
  imgLeft:=10;
  i:=-1;

  SetLength(FCards,6);
  for card in dm.GetCards('TALON') do begin
    Inc(i);
    if i=3 then
      imgLeft:=imgLeft+80;
    FCards[i]:=TCardControl.Create(Self,card);
    FCards[i].Parent:=pCards;
    dm.imCards.GetBitmap(card.ImageIndex,FCards[i].Picture.Bitmap);
    FCards[i].Top:=CARDUPLIFT+5;
    FCards[i].Left:=imgLeft;
    FCards[i].Remainup:=True;
    FCards[i].Enabled:=(dm.ActGame.Talon=tk6Talon) and (dm.MyName=dm.GameSituation.Gamer);
    FCards[i].Up:=False;
    imgLeft:=imgLeft+CARDXOFFSET;
  end;

  if dm.MyName=dm.GameSituation.Gamer then begin
    if dm.ActGame.Talon=tk3Talon then begin
      lCaption.Caption:='Wähle den Talon aus, den du willst';
      bOK.Enabled:=False;
    end
    else begin
      lCaption.Caption:='Der ganze Talon gehört dir. Wähle die 6 Karten, die du weglegen willst';
      bOK.Enabled:=True;
      bLeft.Visible:=False;
      bRight.Visible:=False;
    end;
  end
  else begin
    bLeft.Visible:=False;
    bRight.Visible:=False;
    bOK.Visible:=False;
    lCaption.Caption:='Der Talon';
  end;
end;

end.
