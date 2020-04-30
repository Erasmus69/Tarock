unit ConnectionErrorFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, Vcl.Menus, Vcl.StdCtrls,
  cxButtons;

type
  TfrmConnectionError = class(TForm)
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxButton1: TcxButton;
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConnectionError: TfrmConnectionError;

implementation

{$R *.dfm}

procedure TfrmConnectionError.cxButton1Click(Sender: TObject);
begin
  Halt;
end;

end.
