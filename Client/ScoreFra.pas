unit ScoreFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel,
  Vcl.ExtCtrls;

type
  TfraScore = class(TFrame)
    pBackground: TPanel;
    clPlayer1: TcxLabel;
    clScore1: TcxLabel;
    clPlayer2: TcxLabel;
    clScore2: TcxLabel;
    clPlayer3: TcxLabel;
    clScore3: TcxLabel;
    clPlayer4: TcxLabel;
    clScore4: TcxLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
