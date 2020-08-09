unit RegistrationFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, cxTextEdit, dxGDIPlusClasses, Vcl.ExtCtrls, cxLabel;

type
  TfrmRegistration = class(TForm)
    eName: TcxTextEdit;
    bRegister: TcxButton;
    Image1: TImage;
    lVersion: TcxLabel;
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
  TarockDM, WiRL.http.Client.Interfaces;

{$R *.dfm}

procedure TfrmRegistration.bRegisterClick(Sender: TObject);
begin
  if Trim(eName.Text)='' then Exit;
  
  Screen.Cursor:=crHourGlass;
  try
    while true do begin
      try
        if dm.RegisterPlayer(eName.Text) then
          Break
        else
          Exit;
      except
        on E:EWiRLSocketException do
           dm.ReactiveServerConnection;
        else Raise;
      end;
    end;

    dm.MyName:=eName.Text;
    ModalResult:=mrOk;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

end.
