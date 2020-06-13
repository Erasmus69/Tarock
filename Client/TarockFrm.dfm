object frmTarock: TfrmTarock
  Left = 0
  Top = 0
  Caption = 'Tarock'
  ClientHeight = 823
  ClientWidth = 1184
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    1184
    823)
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
    Top = 783
    Width = 1184
    Height = 40
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      1184
      40)
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
      AnchorX = 592
      AnchorY = 20
    end
    object bRegister: TButton
      Left = 142
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Register'
      TabOrder = 1
      OnClick = bRegisterClick
    end
    object bStartGame: TButton
      Left = 1098
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Starte Spiel'
      TabOrder = 2
      OnClick = BStartGameClick
    end
    object cbPlayers: TComboBox
      Left = 8
      Top = 5
      Width = 128
      Height = 21
      TabOrder = 3
      Text = 'cbPlayers'
      Items.Strings = (
        'ANDI'
        'HANNES'
        'WOLFGANG'
        'LUKI')
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 40
    Width = 40
    Height = 743
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
      AnchorY = 372
    end
  end
  object pRight: TPanel
    Left = 1144
    Top = 40
    Width = 40
    Height = 743
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
      AnchorY = 372
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1184
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
      AnchorX = 592
      AnchorY = 20
    end
  end
  object pBoard: TPanel
    Left = 40
    Top = 40
    Width = 1104
    Height = 743
    Align = alClient
    TabOrder = 5
    object pMyCards: TPanel
      Left = 1
      Top = 558
      Width = 1102
      Height = 184
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
    end
    object pFirstplayerCards: TPanel
      Left = 1
      Top = 1
      Width = 40
      Height = 557
      Align = alLeft
      BevelOuter = bvNone
      Color = clSkyBlue
      ParentBackground = False
      TabOrder = 1
    end
    object pThirdPlayerCards: TPanel
      Left = 1063
      Top = 1
      Width = 40
      Height = 557
      Align = alRight
      BevelOuter = bvNone
      Color = clGradientInactiveCaption
      ParentBackground = False
      TabOrder = 2
    end
    object pCenter: TPanel
      Left = 41
      Top = 1
      Width = 1022
      Height = 557
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 3
      object pThrowCards: TPanel
        Left = 257
        Top = 126
        Width = 512
        Height = 361
        BevelOuter = bvNone
        TabOrder = 0
        object imgFirstCard: TImage
          AlignWithMargins = True
          Left = 0
          Top = 53
          Width = 85
          Height = 154
          Proportional = True
          Stretch = True
        end
        object imgSecondCard: TImage
          AlignWithMargins = True
          Left = 148
          Top = 0
          Width = 85
          Height = 154
          Proportional = True
          Stretch = True
        end
        object imgMyCard: TImage
          AlignWithMargins = True
          Left = 148
          Top = 184
          Width = 85
          Height = 154
          Proportional = True
          Stretch = True
        end
        object imgThirdCard: TImage
          AlignWithMargins = True
          Left = 292
          Top = 53
          Width = 85
          Height = 154
          Proportional = True
          Stretch = True
        end
        object imgTalon: TImage
          AlignWithMargins = True
          Left = 420
          Top = 184
          Width = 85
          Height = 154
          Proportional = True
          Stretch = True
        end
      end
      object pSecondPlayerCards: TPanel
        Left = 0
        Top = 0
        Width = 1022
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
  end
  object mGameInfo: TcxMemo
    Left = 881
    Top = 39
    Anchors = [akTop, akRight]
    Lines.Strings = (
      'mGameInfo')
    ParentFont = False
    Properties.ScrollBars = ssVertical
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Courier New'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 6
    Height = 210
    Width = 263
  end
  object tRefresh: TTimer
    Enabled = False
    OnTimer = tRefreshTimer
    Left = 1064
    Top = 256
  end
end
