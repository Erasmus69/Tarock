unit GamesSelectFra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.Menus,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator,
  cxTextEdit, cxGridCustomTableView, cxGridTableView, cxGridCustomView,
  cxClasses, cxGridLevel, cxGrid, Vcl.StdCtrls, cxButtons, cxLabel;

type
  TfraGameSelect = class(TFrame)
    cxLabel1: TcxLabel;
    bBet: TcxButton;
    rdGamesLevel1: TcxGridLevel;
    rdGames: TcxGrid;
    gvGames: TcxGridTableView;
    gcID: TcxGridColumn;
    gcName: TcxGridColumn;
    gcValue: TcxGridColumn;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
  end;

implementation
uses Generics.Collections,Common.Entities.GameType,TarockDM;

{$R *.dfm}

{ TfraGameSelect }

constructor TfraGameSelect.Create(AOwner: TComponent);
var r:Integer;
begin
  inherited;

  r:=0;
  gvGames.BeginUpdate;
  try
    ALLGAMES.ForEach(procedure (const AGame:TPair<String,TGameType>) begin
                       if not  AGame.Value.ByFirstPlayer and (AGame.Value.Value>dm.ActualBet) then begin
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
  bBet.Enabled:=dm.TurnOn=dm.MyName;

end;

end.
