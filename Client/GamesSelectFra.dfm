object fraGameSelect: TfraGameSelect
  Left = 0
  Top = 0
  Width = 498
  Height = 400
  TabOrder = 0
  object pBackground: TPanel
    Left = 0
    Top = 0
    Width = 498
    Height = 400
    Align = alClient
    BevelInner = bvRaised
    BevelKind = bkSoft
    BevelWidth = 2
    TabOrder = 0
    object cxLabel1: TcxLabel
      Left = 4
      Top = 4
      Align = alTop
      Caption = 'M'#246'gliche Spiele'
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
      AnchorX = 247
      AnchorY = 16
    end
    object Panel1: TPanel
      Left = 4
      Top = 27
      Width = 486
      Height = 324
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        486
        324)
      object rdGames: TcxGrid
        Left = 8
        Top = 12
        Width = 465
        Height = 306
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        LookAndFeel.NativeStyle = False
        object gvGames: TcxGridTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnFiltering = False
          OptionsCustomize.ColumnGrouping = False
          OptionsCustomize.ColumnHidingOnGrouping = False
          OptionsCustomize.ColumnHorzSizing = False
          OptionsCustomize.ColumnMoving = False
          OptionsCustomize.ColumnSorting = False
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.GroupByBox = False
          Styles.Header = cxStyle2
          object gcID: TcxGridColumn
            Visible = False
            VisibleForCustomization = False
          end
          object gcName: TcxGridColumn
            Caption = 'Spiel'
            MinWidth = 200
            Styles.Header = cxStyle2
            Width = 200
          end
          object gcValue: TcxGridColumn
            Caption = 'Wert'
            DataBinding.ValueType = 'Integer'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            HeaderAlignmentHorz = taRightJustify
            SortIndex = 0
            SortOrder = soAscending
          end
        end
        object rdGamesLevel1: TcxGridLevel
          GridView = gvGames
        end
      end
    end
    object Panel2: TPanel
      Left = 4
      Top = 351
      Width = 486
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        486
        41)
      object bHold: TcxButton
        Left = 13
        Top = 2
        Width = 90
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Nehme Auf'
        TabOrder = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bHoldClick
      end
      object bBet: TcxButton
        Left = 204
        Top = 2
        Width = 90
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Lizitiere'
        TabOrder = 1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bBetClick
      end
      object bPass: TcxButton
        Left = 380
        Top = 2
        Width = 90
        Height = 33
        Anchors = [akLeft, akBottom]
        Caption = 'Passe'
        TabOrder = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = bPassClick
      end
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 16
    Top = 8
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor]
      Color = clScrollBar
    end
  end
end
