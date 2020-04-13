object frmTarock: TfrmTarock
  Left = 0
  Top = 0
  Caption = 'frmTarock'
  ClientHeight = 341
  ClientWidth = 724
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
  object Button1: TButton
    Left = 294
    Top = 121
    Width = 75
    Height = 25
    Caption = 'Register'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 607
    Top = 52
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 1
    OnClick = Button2Click
  end
  object CSEdit1: TCSEdit
    Left = 168
    Top = 118
    TabOrder = 2
    Height = 25
    Width = 121
  end
  object Memo1: TMemo
    Left = 416
    Top = 54
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
end
