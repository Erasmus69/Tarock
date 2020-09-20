unit TalonInfoFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, cxLabel, Vcl.ExtCtrls, Classes.CardControl,Common.Entities.Card;

type
  TfraTalonInfo = class(TFrame)
    pBackground: TPanel;
    pCards: TPanel;
    lCaption: TcxLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    FCards:TArray<TCardControl>;
    constructor Create(AOwner:TComponent); override;
    procedure ShowCards(const ACards:TCards);
  end;

implementation

uses
  TarockDM, Common.Entities.GameType, TarockFrm;

{$R *.dfm}

const CARDXOFFSET=45;

{ TfraTalonSelect }

constructor TfraTalonInfo.Create(AOwner: TComponent);

begin
  inherited;

end;

procedure TfraTalonInfo.ShowCards(const ACards: TCards);
var card:TCard;
    i: Integer;
    imgLeft: Integer;

begin
  imgLeft:=10;
  i:=-1;

  SetLength(FCards,6);
  for card in ACards do begin
    Inc(i);
    if i=3 then
      imgLeft:=imgLeft+20;
    FCards[i]:=TCardControl.Create(Self,card);
    FCards[i].Parent:=pCards;
    dm.imCards.GetBitmap(card.ImageIndex,FCards[i].Picture.Bitmap);
    FCards[i].Top:=5;
    FCards[i].Left:=imgLeft;
    FCards[i].Height:= FCards[i].Height div 2;
    FCards[i].Width:= FCards[i].Width div 2;
    FCards[i].Enabled:=False;
    FCards[i].Up:=False;
    imgLeft:=imgLeft+CARDXOFFSET;
  end;
  Show;
end;

end.
