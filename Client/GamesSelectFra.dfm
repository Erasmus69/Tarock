object fraGameSelect: TfraGameSelect
  Left = 0
  Top = 0
  Width = 498
  Height = 400
  TabOrder = 0
  DesignSize = (
    498
    400)
  object cxLabel1: TcxLabel
    Left = 0
    Top = 0
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
    AnchorX = 249
    AnchorY = 12
  end
  object bBet: TcxButton
    Left = 215
    Top = 352
    Width = 90
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Lizitieren'
    TabOrder = 1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = bBetClick
  end
  object rdGames: TcxGrid
    Left = 16
    Top = 40
    Width = 465
    Height = 306
    TabOrder = 2
    object gvGames: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
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
      object gcID: TcxGridColumn
        Visible = False
        VisibleForCustomization = False
      end
      object gcName: TcxGridColumn
        Caption = 'Spiel'
        MinWidth = 200
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
  object bHold: TcxButton
    Left = 16
    Top = 352
    Width = 90
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Nehme Auf'
    TabOrder = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = bHoldClick
  end
  object bPass: TcxButton
    Left = 391
    Top = 352
    Width = 90
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Passe'
    TabOrder = 4
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = bPassClick
  end
end
