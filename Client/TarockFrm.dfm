object frmTarock: TfrmTarock
  Left = 0
  Top = 0
  Caption = 'frmTarock'
  ClientHeight = 833
  ClientWidth = 1271
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
  object Button2: TButton
    Left = 992
    Top = 8
    Width = 104
    Height = 25
    Caption = 'Refresh Players'
    TabOrder = 0
  end
  object pBottom: TPanel
    Left = 0
    Top = 793
    Width = 1271
    Height = 40
    Align = alBottom
    TabOrder = 1
    object clME: TcxLabel
      Left = 1
      Top = 1
      Align = alClient
      Anchors = [akLeft, akTop, akBottom]
      Caption = 'clME'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -20
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      AnchorX = 636
      AnchorY = 20
    end
    object CSEdit1: TCSEdit
      Left = 16
      Top = 4
      TabOrder = 1
      Text = 'ANDI'
      Height = 25
      Width = 121
    end
    object Button1: TButton
      Left = 142
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Register'
      TabOrder = 2
      OnClick = Button1Click
    end
    object bStartGame: TButton
      Left = 896
      Top = 6
      Width = 75
      Height = 25
      Caption = 'StartGame'
      TabOrder = 3
      OnClick = BStartGameClick
    end
    object Button4: TButton
      Left = 1081
      Top = 5
      Width = 75
      Height = 25
      Caption = 'ShowTalon'
      TabOrder = 4
      OnClick = Button4Click
    end
    object bNewRound: TButton
      Left = 815
      Top = 6
      Width = 75
      Height = 25
      Caption = 'New Round'
      TabOrder = 5
      OnClick = bNewRoundClick
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 40
    Width = 40
    Height = 753
    Align = alLeft
    TabOrder = 2
    object clFirstPlayer: TcxLabel
      Left = 1
      Top = 1
      Align = alClient
      Caption = 'clFirstPlayer'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -20
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Properties.Angle = 90
      AnchorX = 20
      AnchorY = 377
    end
  end
  object pRight: TPanel
    Left = 1231
    Top = 40
    Width = 40
    Height = 753
    Align = alRight
    TabOrder = 3
    object clThirdPlayer: TcxLabel
      Left = 1
      Top = 1
      Align = alClient
      Caption = 'clThirdPlayer'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -20
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Properties.Angle = -90
      AnchorX = 20
      AnchorY = 377
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1271
    Height = 40
    Align = alTop
    TabOrder = 4
    object clSecondPlayer: TcxLabel
      Left = 1
      Top = 1
      Align = alClient
      Caption = 'clSecondPlayer'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -20
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      AnchorX = 636
      AnchorY = 20
    end
  end
  object pBoard: TPanel
    Left = 40
    Top = 40
    Width = 1191
    Height = 753
    Align = alClient
    TabOrder = 5
    object imgThirdCard: TImage
      Left = 686
      Top = 297
      Width = 85
      Height = 154
      Stretch = True
    end
    object imgMyCard: TImage
      Left = 566
      Top = 409
      Width = 85
      Height = 154
      Stretch = True
    end
    object imgFirstCard: TImage
      Left = 439
      Top = 297
      Width = 85
      Height = 154
      Stretch = True
    end
    object imgSecondCard: TImage
      Left = 566
      Top = 188
      Width = 85
      Height = 154
      Stretch = True
    end
    object pMyCards: TPanel
      Left = 1
      Top = 568
      Width = 1189
      Height = 184
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
    end
    object pTalon: TPanel
      Left = 274
      Top = 231
      Width = 637
      Height = 292
      TabOrder = 1
      Visible = False
    end
    object pFirstplayerCards: TPanel
      Left = 1
      Top = 41
      Width = 40
      Height = 527
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 2
    end
    object pThirdPlayerCards: TPanel
      Left = 1150
      Top = 41
      Width = 40
      Height = 527
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 3
    end
    object pSecondPlayerCards: TPanel
      Left = 1
      Top = 1
      Width = 1189
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 4
    end
  end
  object mGameInfo: TcxMemo
    Left = 992
    Top = 45
    Lines.Strings = (
      'mGameInfo')
    TabOrder = 6
    Height = 173
    Width = 233
  end
  object tRefresh: TTimer
    Enabled = False
    OnTimer = tRefreshTimer
    Left = 1064
    Top = 256
  end
end
