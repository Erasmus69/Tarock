object frmTarock: TfrmTarock
  Left = 0
  Top = 0
  Caption = 'frmTarock'
  ClientHeight = 742
  ClientWidth = 1104
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 416
    Top = 38
    Width = 35
    Height = 13
    Caption = 'Players'
  end
  object clFirstPlayer: TCSLabel
    Left = 0
    Top = 25
    Width = 33
    Height = 667
    Caption = 'clFirstPlayer'
    Properties.Alignment.Horz = taCenter
  end
  object clSecondPlayer: TCSLabel
    Left = 0
    Top = 0
    Width = 1104
    Align = alTop
    Caption = 'clSecondPlayer'
    Properties.Alignment.Horz = taCenter
  end
  object clThirdPlayer: TCSLabel
    Left = 1072
    Top = 25
    Width = 32
    Height = 692
    Align = alRight
    Caption = 'clThirdPlayer'
    Properties.Alignment.Horz = taCenter
  end
  object clME: TCSLabel
    Left = 0
    Top = 717
    Width = 1104
    Align = alBottom
    Caption = 'clME'
    Properties.Alignment.Horz = taCenter
  end
  object Image1: TImage
    Left = 38
    Top = 436
    Width = 141
    Height = 256
    Visible = False
  end
  object Image2: TImage
    Left = 85
    Top = 456
    Width = 141
    Height = 256
    Visible = False
  end
  object Button1: TButton
    Left = 992
    Top = 39
    Width = 75
    Height = 25
    Caption = 'Register'
    TabOrder = 0
    OnClick = Button1Click
  end
  object CSEdit1: TCSEdit
    Left = 866
    Top = 36
    TabOrder = 1
    Height = 25
    Width = 121
  end
  object Button2: TButton
    Left = 992
    Top = 8
    Width = 104
    Height = 25
    Caption = 'Refresh Players'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 592
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 992
    Top = 70
    Width = 75
    Height = 25
    Caption = 'Start Game'
    TabOrder = 4
    OnClick = Button4Click
  end
end
