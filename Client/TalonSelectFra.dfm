object fraTalonSelect: TfraTalonSelect
  Left = 0
  Top = 0
  Width = 659
  Height = 299
  TabOrder = 0
  object pBackground: TPanel
    Left = 0
    Top = 0
    Width = 659
    Height = 299
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkSoft
    BevelWidth = 2
    TabOrder = 0
    object pCards: TPanel
      Left = 4
      Top = 27
      Width = 647
      Height = 206
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
    end
    object lCaption: TcxLabel
      Left = 4
      Top = 4
      Align = alTop
      Caption = 'W'#228'hle den Talon aus, den du nehmen willst'
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
      AnchorX = 328
      AnchorY = 16
    end
    object Panel2: TPanel
      Left = 4
      Top = 233
      Width = 647
      Height = 58
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        647
        58)
      object bOK: TcxButton
        Left = 248
        Top = 14
        Width = 153
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Auswahl best'#228'tigen'
        TabOrder = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bOKClick
      end
      object bLeft: TcxButton
        Left = 112
        Top = 14
        Width = 90
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Links'
        SpeedButtonOptions.GroupIndex = 1
        TabOrder = 1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bLeftClick
      end
      object bRight: TcxButton
        Left = 447
        Top = 14
        Width = 90
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Rechts'
        SpeedButtonOptions.GroupIndex = 1
        TabOrder = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bRightClick
      end
    end
  end
end
