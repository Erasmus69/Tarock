unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit, CSLabel, Vcl.ExtCtrls;

type
  TfrmTarock = class(TForm)
    Button1: TButton;
    CSEdit1: TCSEdit;
    Label1: TLabel;
    clFirstPlayer: TCSLabel;
    clSecondPlayer: TCSLabel;
    Button2: TButton;
    clThirdPlayer: TCSLabel;
    clME: TCSLabel;
    Button3: TButton;
    Image1: TImage;
    Image2: TImage;
    Button4: TButton;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure GetPlayers;
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Classes.Entities,Server.Entities.Card;

{$R *.dfm}


const
  CARDHEIGHT=256;
  CARDWIDTH=141;
  MYCARDMOSTTOP=435;
  MYCARDMOSTLEFT=35;
  MYCARDXOFFSET=60;
  MYCARDYOFFSET=10;

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


procedure TfrmTarock.Button2Click(Sender: TObject);
begin
  GetPlayers
end;

procedure TfrmTarock.Button3Click(Sender: TObject);
var i:Integer;
    imgLeft,imgTop:Integer;
    img:TImage;
    card:TCard;
begin
  imgLeft:=MYCARDMOSTLEFT;
  imgTop:=MYCARDMOSTTOP;

  for card in ALLCARDS.Values do begin
    if card.ImageIndex>=0 then begin
       img:=TImage.Create(Self);
       img.Parent:=Self;
       dm.imCards.GetBitmap(card.ImageIndex,img.Picture.Bitmap);
       img.Height:=CARDHEIGHT;
       img.Width:=CARDWIDTH;
       img.Top:=imgTop;
       img.Left:=imgLeft;
       imgLeft:=imgLeft+MYCARDXOFFSET;
       imgTop:=imgTop+MYCARDYOFFSET;
    end;

  end;
end;

procedure TfrmTarock.Button4Click(Sender: TObject);
begin
  dm.StartNewGame;
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
begin
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

end.
