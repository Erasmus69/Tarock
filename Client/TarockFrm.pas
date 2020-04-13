unit TarockFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, CSEdit;

type
  TfrmTarock = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CSEdit1: TCSEdit;
    Memo1: TMemo;
    Label1: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure GetPlayers;
  public
    { Public declarations }
  end;

var
  frmTarock: TfrmTarock;

implementation
uses System.JSON,TarockDM,Classes.Entities;

{$R *.dfm}

procedure TfrmTarock.Button1Click(Sender: TObject);
var p:TPlayer;
    itm:TPlayer;
    response:TJSONValue;
begin
  if csEdit1.Text>'' then begin
    p:=TPlayer.Create;
    p.Name:=CSEdit1.Text;
    try
      response:=dm.RESTClient.PostEntity<TPlayer>('registerplayer',p);
      if response.GetValue<String>('status')<>'success' then
        Showmessage(response.GetValue<String>('message'));

    finally
      GetPlayers;
    end;
  end;
end;


procedure TfrmTarock.Button2Click(Sender: TObject);
begin
  GetPlayers
end;

procedure TfrmTarock.FormCreate(Sender: TObject);
begin
  GetPlayers;
end;

procedure TfrmTarock.GetPlayers;
var p:TPlayers;
    itm:TPlayer;
begin
  p:=dm.RESTClient.GetObject<TPlayers>('players');
  Memo1.Lines.Clear;
  for itm in p do
    Memo1.Lines.Add(itm.Name);
end;

end.
