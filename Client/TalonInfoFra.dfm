object fraTalonInfo: TfraTalonInfo
  Left = 0
  Top = 0
  Width = 300
  Height = 126
  TabOrder = 0
  object pBackground: TPanel
    Left = 0
    Top = 0
    Width = 300
    Height = 126
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object pCards: TPanel
      Left = 2
      Top = 22
      Width = 296
      Height = 102
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
    end
    object lCaption: TcxLabel
      Left = 2
      Top = 2
      Align = alTop
      Caption = 'Das war der Talon'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      AnchorX = 150
      AnchorY = 12
    end
  end
end
