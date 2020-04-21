unit Classes.CardControl;

interface
uses Classes,VCL.Controls,VCL.ExtCtrls,Common.Entities.Card;

const
  CARDHEIGHT=154;//256;
  CARDWIDTH=85;//141;
  CARDUPLIFT=30;

type
  TCardControl=class(TImage)
  private
    FCard: TCard;
  protected
    procedure MouseDown(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
    procedure MouseUp(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
  public
    constructor Create(AOwner:TComponent; const ACard:TCard);
    property Card:TCard read FCard;
  end;

  TBackCardKind=(bckDown,bckLeft,bckRight);
  TBackCardControl=class(TImage)
    constructor Create(AOwner:TComponent;AKind:TBackCardKind);
  end;

implementation
uses TarockDM;

{ TCardControl }

constructor TCardControl.Create(AOwner: TComponent; const ACard:TCard);
begin
  inherited Create(AOwner);
  Height:=CARDHEIGHT;
  Width:=CARDWIDTH;
  Stretch:=True;
  Proportional:=True;
  FCard:=ACard;
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
