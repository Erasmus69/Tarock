unit RegistrationFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, cxTextEdit, dxGDIPlusClasses, Vcl.ExtCtrls;

type
  TfrmRegistration = class(TForm)
    eName: TcxTextEdit;
    bRegister: TcxButton;
    Image1: TImage;
    procedure bRegisterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRegistration: TfrmRegistration;

implementation

uses
  TarockDM;

{$R *.dfm}

procedure TfrmRegistration.bRegisterClick(Sender: TObject);
begin
  if Trim(eName.Text)='' then Exit;
  
  Screen.Cursor:=crHourGlass;
  try
    dm.RegisterPlayer(eName.Text);
    dm.MyName:=eName.Text;
    ModalResult:=mrOk;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

end.
