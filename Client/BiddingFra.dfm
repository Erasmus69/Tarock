object fraBidding: TfraBidding
  Left = 0
  Top = 0
  Width = 562
  Height = 274
  TabOrder = 0
  object pBackground: TPanel
    Left = 0
    Top = 0
    Width = 562
    Height = 274
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkSoft
    BevelWidth = 2
    TabOrder = 0
    object lCaption: TcxLabel
      Left = 4
      Top = 4
      Align = alTop
      Caption = 'M'#246'chtest du was bieten ?'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      AnchorX = 279
      AnchorY = 16
    end
    object bSack: TcxButton
      Left = 8
      Top = 54
      Width = 130
      Height = 33
      Caption = 'Sack'
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bKingUlt: TcxButton
      Left = 144
      Top = 54
      Width = 130
      Height = 33
      Caption = 'K'#246'nig Ult'
      SpeedButtonOptions.GroupIndex = 2
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bPagatUlt: TcxButton
      Left = 8
      Top = 93
      Width = 130
      Height = 33
      Caption = 'Pagat Ult'
      SpeedButtonOptions.GroupIndex = 5
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bVogel4: TcxButton
      Left = 416
      Top = 93
      Width = 130
      Height = 33
      Caption = 'Vogel IV'
      SpeedButtonOptions.GroupIndex = 14
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 4
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bGame: TcxButton
      Left = 8
      Top = 132
      Width = 130
      Height = 33
      Caption = 'Contra Spiel'
      SpeedButtonOptions.GroupIndex = 7
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 6
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bTrull: TcxButton
      Left = 416
      Top = 54
      Width = 130
      Height = 33
      Caption = 'Trull'
      SpeedButtonOptions.GroupIndex = 3
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 5
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bAllKings: TcxButton
      Left = 280
      Top = 54
      Width = 130
      Height = 33
      Caption = '4 K'#246'nige'
      SpeedButtonOptions.GroupIndex = 4
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 7
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bXXIFang: TcxButton
      Left = 416
      Top = 132
      Width = 130
      Height = 33
      Caption = 'XXI Fang'
      SpeedButtonOptions.GroupIndex = 10
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 8
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bValat: TcxButton
      Left = 416
      Top = 171
      Width = 130
      Height = 33
      Caption = 'Valat'
      SpeedButtonOptions.GroupIndex = 11
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 9
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bBet: TcxButton
      Left = 232
      Top = 204
      Width = 90
      Height = 33
      Caption = 'Fertig'
      Default = True
      TabOrder = 10
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = bBetClick
    end
    object bVogel3: TcxButton
      Left = 280
      Top = 93
      Width = 130
      Height = 33
      Caption = 'Vogel III'
      SpeedButtonOptions.GroupIndex = 13
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bVogel2: TcxButton
      Left = 144
      Top = 93
      Width = 130
      Height = 33
      Caption = 'Vogel II'
      SpeedButtonOptions.GroupIndex = 12
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 12
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bPagatFang: TcxButton
      Left = 280
      Top = 132
      Width = 130
      Height = 33
      Caption = 'Pagat Fang'
      SpeedButtonOptions.GroupIndex = 9
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bKingFang: TcxButton
      Left = 144
      Top = 132
      Width = 130
      Height = 33
      Caption = 'K'#246'nig Fang'
      SpeedButtonOptions.GroupIndex = 8
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 14
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
end
