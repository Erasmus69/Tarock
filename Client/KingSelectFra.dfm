object fraKingSelect: TfraKingSelect
  Left = 0
  Top = 0
  Width = 373
  Height = 241
  TabOrder = 0
  object pBackground: TPanel
    Left = 0
    Top = 0
    Width = 373
    Height = 241
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkSoft
    BevelWidth = 2
    TabOrder = 0
    object pCards: TPanel
      Left = 4
      Top = 27
      Width = 361
      Height = 206
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
    end
    object cxLabel1: TcxLabel
      Left = 4
      Top = 4
      Align = alTop
      Caption = 'W'#228'hle einen K'#246'nig'
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
      AnchorX = 185
      AnchorY = 16
    end
  end
end
