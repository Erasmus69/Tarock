unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit, CSLabel, Vcl.ExtCtrls,Server.Entities.Card, cxLabel;

type
  TCardPosition=(cpMyCards,cpTalon,cpFirstPlayer,cpSecondPlayer,cpThirdPlayer);

  TfrmTarock = class(TForm)
    Button2: TButton;
    pBottom: TPanel;
    clME: TcxLabel;
    pLeft: TPanel;
    clFirstPlayer: TcxLabel;
    pRight: TPanel;
    pTop: TPanel;
    pBoard: TPanel;
    pMyCards: TPanel;
    clThirdPlayer: TcxLabel;
    clSecondPlayer: TcxLabel;
    CSEdit1: TCSEdit;
    Button1: TButton;
    bStartGame: TButton;
    pTalon: TPanel;
    Button4: TButton;
    pFirstplayerCards: TPanel;
    pThirdPlayerCards: TPanel;
    pSecondPlayerCards: TPanel;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BStartGameClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure GetPlayers;
    procedure ShowCards(ACards:TCards; APosition:TCardPosition);
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Classes.Entities,Classes.CardControl;

{$R *.dfm}


const

  MYCARDMOSTTOP=410;
  MYCARDMOSTLEFT=20;
  CARDXOFFSET=90;
  BACKCARDXOFFSET=30;
  CARDYOFFSET=0;

procedure TfrmTarock.Button1Click(Sender: TObject);
begin
  if csEdit1.Text>'' then begin
    try
      dm.RegisterPlayer(CSEdit1.Text);
      dm.MyName:=CSEdit1.Text;
    finally
      GetPlayers;
    end;
  end;
end;

procedure TfrmTarock.Button4Click(Sender: TObject);
begin
  if pTalon.Visible then
    pTalon.Visible:=False
  else
    ShowCards(dm.ActGame.Talon.Cards,cpTalon);
end;

procedure TfrmTarock.bStartGameClick(Sender: TObject);
begin
  dm.StartNewGame;
  ShowCards(dm.MyCards,cpMyCards);
  ShowCards(dm.ActGame.Players[2].Cards,cpFirstPlayer);
  ShowCards(dm.ActGame.Players[2].Cards,cpSecondPlayer);
  ShowCards(dm.ActGame.Players[2].Cards,cpThirdPlayer);
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
begin
  dm.MyName:=CSEdit1.Text;
  GetPlayers;
end;

procedure TfrmTarock.GetPlayers;
var p:TPlayers;
    itm:TPlayer;
  i: Integer;
begin
  dm.GetPlayers;
  for itm in dm.Players do begin
    case itm.Position of
      bpLeft:clFirstPlayer.Caption:=itm.Name;
      bpUp:clSecondPlayer.Caption:=itm.Name;
      bpRight:clThirdPlayer.Caption:=itm.Name;
      bpDown:clME.Caption:=itm.Name;
    end;
  end;

end;

procedure TfrmTarock.ShowCards(ACards: TCards; APosition: TCardPosition);
var i:Integer;
    imgLeft,imgTop:Integer;
    img:TCardControl;
    card:TCard;
    cardParent:TPanel;
    backCardKind:TBackCardKind;
begin

  case APosition of
    cpMyCards:begin
                imgLeft:=(Width-((ACards.Count-1)*CARDXOFFSET)-CARDWIDTH) div 2;
                cardParent:=pMyCards
              end;
    cpTalon:  begin
                cardParent:=pTalon;
                imgLeft:=0;
                pTalon.Visible:=True;
              end;
    cpFirstPlayer:begin
                    cardParent:=pFirstPlayerCards;
                    backCardKind:=bckLeft;
                  end;
    cpSecondPlayer:begin
                    cardParent:=pSecondPlayerCards;
                    backCardKind:=bckDown;
                  end;
    cpThirdPlayer:begin
                    cardParent:=pThirdPlayerCards;
                    backCardKind:=bckRight;
                  end;
  end;

  if APosition in [cpMyCards,cpTalon] then begin
    for card in ACards do begin
      img:=TCardControl.Create(Self);
      img.Parent:=cardParent;
      dm.imCards.GetBitmap(card.ImageIndex,img.Picture.Bitmap);
      img.Top:=CARDUPLIFT;
      img.Left:=imgLeft;
      imgLeft:=imgLeft+CARDXOFFSET;
    end;
  end
  else if APosition=cpSecondPlayer then begin
    imgLeft:=(Width-((ACards.Count-1)*BACKCARDXOFFSET)-CARDWIDTH) div 2;
    for card in ACards do begin
      with TBackCardControl.Create(Self,backCardKind) do begin
        Parent:=cardParent;
        Top:=0;
        Left:=imgLeft;
      end;
      imgLeft:=imgLeft+BACKCARDXOFFSET;
    end;
  end
  else begin
    imgTop:=(pFirstPlayerCards.Height-((ACards.Count-1)*BACKCARDXOFFSET)-CARDWIDTH) div 2;
    for card in ACards do begin
      with TBackCardControl.Create(Self,backCardKind) do begin
        Parent:=cardParent;
        Top:=imgTop;
        Left:=0;
      end;
      imgTop:=imgTop+BACKCARDXOFFSET;
    end;
  end;
end;

end.
