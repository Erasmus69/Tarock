unit Classes.CardControl;

interface
uses Classes,VCL.Controls,VCL.ExtCtrls;

const
  CARDHEIGHT=154;//256;
  CARDWIDTH=85;//141;
  CARDUPLIFT=30;

type
  TCardControl=class(TImage)
  protected
    procedure MouseDown(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
    procedure MouseUp(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
  public
    constructor Create(AOwner:TComponent);override;
  end;

  TBackCardKind=(bckDown,bckLeft,bckRight);
  TBackCardControl=class(TImage)
    constructor Create(AOwner:TComponent;AKind:TBackCardKind);
  end;

implementation
uses TarockDM;

{ TCardControl }

constructor TCardControl.Create(AOwner: TComponent);
begin
  inherited;
  Height:=CARDHEIGHT;
  Width:=CARDWIDTH;
  Stretch:=True;
  Proportional:=True;
end;

procedure TCardControl.MouseDown(Button: TMouseButton; ShiftState: TShiftState; X, Y: Integer);
begin
  inherited;
  Top:=Top-CARDUPLIFT;
end;

procedure TCardControl.MouseUp(Button: TMouseButton; ShiftState: TShiftState; X, Y: Integer);
begin
  inherited;
  Top:=Top+CARDUPLIFT;
end;

{ TBackCardControl }

constructor TBackCardControl.Create(AOwner: TComponent; AKind: TBackCardKind);
begin
  inherited Create(AOwner);
  Stretch:=True;
//  Proportional:=True;

  case AKind of
    bckDown:begin
              Width:=CARDWIDTH;
              HEight:=30;
              Picture.Assign(dm.imBackCards.Items[0].Picture)
            end;
    bckRight:begin
              Width:=30;
              HEight:=CARDWIDTH;
              Picture.Assign(dm.imBackCards.Items[1].Picture)
            end;
    bckLeft:begin
              Width:=30;
              HEight:=CARDWIDTH;
              Picture.Assign(dm.imBackCards.Items[2].Picture)
            end;
  end;
end;

end.
