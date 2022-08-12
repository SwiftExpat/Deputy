object frmDeputyOptInstance: TfrmDeputyOptInstance
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Align = alClient
  TabOrder = 0
  object gpInstOptions: TGridPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Align = alClient
    Caption = 'gpInstOptions'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = Label1
        Row = 0
      end
      item
        Column = 0
        Control = LinkLabel1
        Row = 1
      end>
    RowCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 224
    ExplicitWidth = 185
    ExplicitHeight = 41
    object Label1: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 632
      Height = 233
      Align = alClient
      Caption = 'Use the options to configure functionality of Deputy'
      ExplicitWidth = 414
      ExplicitHeight = 25
    end
    object LinkLabel1: TLinkLabel
      Left = 1
      Top = 240
      Width = 638
      Height = 239
      Align = alClient
      Caption = 
        'Documentation <a href="http://swiftexpat.com/deputy">Deputy Home' +
        'page</a> .'
      TabOrder = 0
      OnLinkClick = LinkLabel1LinkClick
      ExplicitLeft = 175
      ExplicitTop = 345
      ExplicitWidth = 293
      ExplicitHeight = 29
    end
  end
end
