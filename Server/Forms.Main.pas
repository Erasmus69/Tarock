unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.ExtCtrls

, Server.WiRL
;

type
  TFrmMain = class(TForm)
    TopPanel: TPanel;
    StartButton: TButton;
    StopButton: TButton;
    MainActionList: TActionList;
    StartServerAction: TAction;
    StopServerAction: TAction;
    laPortNumber: TLabel;
    edPortNumber: TEdit;
    procedure FormShow(Sender: TObject);
    procedure StartServerActionExecute(Sender: TObject);
    procedure StopServerActionExecute(Sender: TObject);
    procedure StartServerActionUpdate(Sender: TObject);
    procedure StopServerActionUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  Server.Configuration,
  Server.Register,
  Common.Entities.Card,
  Common.Entities.GameType;

{$R *.dfm}

{======================================================================================================================}
procedure TFrmMain.FormShow(Sender: TObject);
{======================================================================================================================}
begin
  edPortNumber.Text := GetContainer.Resolve<TConfiguration>.ServerPort.ToString;
end;

{======================================================================================================================}
procedure TFrmMain.StartServerActionExecute(Sender: TObject);
{======================================================================================================================}
var
  serverREST: TServerREST;
begin
  serverREST := GetContainer.Resolve<TServerREST>;
  serverREST.Active := True;

  Common.Entities.Card.Initialize;
  Common.Entities.GameType.Initialize;
  Caption := 'Server started';
end;

{======================================================================================================================}
procedure TFrmMain.StartServerActionUpdate(Sender: TObject);
{======================================================================================================================}
begin
//  StartServerAction.Enabled := not Assigned(WorkerThread);
end;

{======================================================================================================================}
procedure TFrmMain.StopServerActionExecute(Sender: TObject);
{======================================================================================================================}
var
  serverREST: TServerREST;
begin
  serverREST := GetContainer.Resolve<TServerREST>;
  serverREST.Active := False;
  Common.Entities.Card.TearDown;
  Common.Entities.GameType.TearDown;
  Caption := 'Server stopped';
end;

{======================================================================================================================}
procedure TFrmMain.StopServerActionUpdate(Sender: TObject);
{======================================================================================================================}
begin
//  StopServerAction.Enabled := Assigned(WorkerThread);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
