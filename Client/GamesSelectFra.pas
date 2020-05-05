unit GamesSelectFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator,
  cxTextEdit, cxGridCustomTableView, cxGridTableView, cxGridCustomView,
  cxClasses, cxGridLevel, cxGrid, Vcl.StdCtrls, cxButtons, cxLabel, Vcl.ExtCtrls;

type
  TfraGameSelect = class(TFrame)
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    pBackground: TPanel;
    rdGames: TcxGrid;
    gvGames: TcxGridTableView;
    gcID: TcxGridColumn;
    gcName: TcxGridColumn;
    gcValue: TcxGridColumn;
    rdGamesLevel1: TcxGridLevel;
    cxLabel1: TcxLabel;
    bPass: TcxButton;
    bBet: TcxButton;
    bHold: TcxButton;
    procedure bBetClick(Sender: TObject);
    procedure bHoldClick(Sender: TObject);
    procedure bPassClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    procedure CheckMyTurn;
    procedure RefreshGames;

  end;

implementation
uses Generics.Collections,Common.Entities.GameType,TarockDM,Common.Entities.Bet;

{$R *.dfm}

{ TfraGameSelect }

procedure TfraGameSelect.bBetClick(Sender: TObject);
var b:TBet;
begin
  if gvGames.DataController.FocusedRecordIndex>=0 then begin
    b:=TBet.Create;
    b.Player:=dm.MyName;
    b.GameTypeID:=gvGames.DataController.Values[gvGames.DataController.FocusedRecordIndex,gcId.Index];

    dm.NewBet(b);
  end;
end;

constructor TfraGameSelect.Create(AOwner: TComponent);
begin
  inherited;
  RefreshGames;
  bHold.Visible:=dm.IAmBeginner;
  CheckMyTurn;
end;

procedure TfraGameSelect.RefreshGames;
var r:Integer;
    showFirstPlays,show63:Boolean;
begin
  r:=0;
  showFirstPlays:=dm.IAmBeginner and dm.GameSituation.FirstPlayerGamesEnabled;
  show63:=dm.IAmBeginner and (not Assigned(dm.Bets) or (dm.Bets.Count=0));

  gvGames.BeginUpdate;
  try
    ALLGAMES.ForEach(procedure (const AGame:TPair<String,TGameType>) begin
                       if (not  AGame.Value.ByFirstPlayer or (showFirstPlays and (AGame.Key<>'63')) or
                          ((AGame.Key='63') and show63)) and
                          ((AGame.Value.Value>dm.GameSituation.BestBet) or ((AGame.Value.Value=dm.GameSituation.BestBet) and dm.IAmBeginner)) then begin
                          inc(r);
                          gvGames.DataController.RecordCount:=r;
                          gvGames.DataController.Values[r-1,gcID.Index]:=AGame.Value.GameTypeid;
                          gvGames.DataController.Values[r-1,gcName.Index]:=AGame.Value.Name;
                          gvGames.DataController.Values[r-1,gcValue.Index]:=AGame.Value.Value;
                        end;
                     end);
  finally
    gvGames.EndUpdate;
  end;
end;

procedure TfraGameSelect.bHoldClick(Sender: TObject);
var b:TBet;
begin
  b:=TBet.Create;
  b.Player:=dm.MyName;
  b.GameTypeid:='HOLD';
  dm.NewBet(b);
end;

procedure TfraGameSelect.bPassClick(Sender: TObject);
var b:TBet;
begin
  b:=TBet.Create;
  b.Player:=dm.MyName;
  b.GameTypeid:='PASS';
  dm.NewBet(b);
end;

procedure TfraGameSelect.CheckMyTurn;
begin
  bBet.Enabled:=dm.GameSituation.TurnOn=dm.MyName;
  bHold.Enabled:=bBet.Enabled and Assigned(dm.Bets) and (dm.Bets.Count=0);
  bPass.Enabled:=bBet.Enabled;
end;

end.
