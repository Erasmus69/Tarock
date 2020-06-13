unit Classes.CardControl;

interface
uses Classes,VCL.Controls,VCL.ExtCtrls,Common.Entities.Card;

var CARDHEIGHT:Integer=154;//256;
    CARDWIDTH:Integer=85;//141;
    CARDUPLIFT:Integer=30;
    CARDXOFFSET:Integer=90;

    SMALLCARDHEIGHT:Integer=115;//256;
    SMALLCARDWIDTH:Integer=63;//141;
    SMALLCARDXOFFSET:Integer=55;
type
  TCardControl=class(TImage)
  private
    FCard: TCard;
    FRemainUp: Boolean;
    FUp:Boolean;
    FLifted:Boolean;

    procedure SetUp(const Value: Boolean);
  protected
    procedure MouseDown(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
    procedure MouseUp(Button:TMouseButton;ShiftState:TShiftState;X,Y:Integer);override;
  public
    constructor Create(AOwner: TComponent; const ACard:TCard);
    property Card:TCard read FCard;
    property RemainUp:Boolean read FRemainUp write FRemainUp;
    property Up:Boolean read FUp write SetUp;
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
  Autosize:=False;
  Stretch:=True;
  Proportional:=True;
  FCard:=ACard;
end;

procedure TCardControl.MouseDown(Button: TMouseButton; ShiftState: TShiftState; X, Y: Integer);
begin
  inherited;
  if not Enabled then Exit;

  if FRemainUp then
    Up:=not FUp
  else begin
    Top:=Top-CARDUPLIFT;
    FLifted:=True;
  end;
end;

procedure TCardControl.MouseUp(Button: TMouseButton; ShiftState: TShiftState; X, Y: Integer);
begin
  inherited;
  if not RemainUp and Enabled and FLifted then
    Top:=Top+CARDUPLIFT;
end;

procedure TCardControl.SetUp(const Value: Boolean);
begin
  if not FRemainUp then Exit;

  if FUp<>Value then begin
    if FUp then
      Top:=Top+CARDUPLIFT
    else
      Top:=Top-CARDUPLIFT;
    FUp := Value;
  end;
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
