unit KingSelectFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel,
  Vcl.ExtCtrls;

type
  TfraKingSelect = class(TFrame)
    pBackground: TPanel;
    pCards: TPanel;
    cxLabel1: TcxLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    procedure DoSelectCard(Sender:TObject);
  end;

implementation

uses
  TarockDM,Common.Entities.Card,Classes.CardControl;

{$R *.dfm}

{ TfraKingSelect }

constructor TfraKingSelect.Create(AOwner: TComponent);
  procedure CreateCard(const ACard:TCardKey;ALeft:Integer);
  var img:TCardControl;
  begin
    img:=TCardControl.Create(Self,ALLCARDS.Find(ACard));
    img.Parent:=pCards;
    img.Top:=CARDUPLIFT+5;
    img.Left:=ALeft+10;
    dm.imCards.GetBitmap(img.Card.ImageIndex,img.Picture.Bitmap);
    img.OnDblClick:=DoSelectCard;
  end;

begin
  inherited;
  CreateCard(HK,0);
  CreateCard(DK,CARDWIDTH*1);
  CreateCard(CK,CARDWIDTH*2);
  CreateCard(SK,CARDWIDTH*3);
end;

procedure TfraKingSelect.DoSelectCard(Sender: TObject);
begin
  dm.SelectKing(TCardControl(Sender).Card.ID);
end;

end.
