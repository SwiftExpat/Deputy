object frmDeputyOptInstance: TfrmDeputyOptInstance
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Align = alClient
  TabOrder = 0
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 634
    Height = 25
    Align = alTop
    Caption = 'Use the options to configure functionality of Deputy'
    ExplicitWidth = 414
  end
  object gpInstOptions: TGridPanel
    Left = 0
    Top = 31
    Width = 640
    Height = 449
    Align = alClient
    Caption = 'gpInstOptions'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = LinkLabel1
        Row = 0
      end>
    RowCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    ShowCaption = False
    TabOrder = 0
    object LinkLabel1: TLinkLabel
      Left = 1
      Top = 1
      Width = 638
      Height = 224
      Align = alClient
      Caption = 
        'Documentation <a href="http://swiftexpat.com/deputy">Deputy Home' +
        'page</a> .'
      TabOrder = 0
      OnLinkClick = LinkLabel1LinkClick
      ExplicitWidth = 293
      ExplicitHeight = 29
    end
  end
end
