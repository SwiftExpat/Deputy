object frmDeputyOptInstance: TfrmDeputyOptInstance
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Align = alClient
  TabOrder = 0
  object lblHeader: TLabel
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
        Control = llDocumentation
        Row = 0
      end
      item
        Column = 0
        Control = pnlOpenSource
        Row = 1
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
    object llDocumentation: TLinkLabel
      Left = 1
      Top = 1
      Width = 638
      Height = 29
      Align = alTop
      Caption = 
        'Documentation <a href="http://swiftexpat.com/deputy">Deputy Home' +
        'page</a> .'
      TabOrder = 0
      ExplicitWidth = 293
    end
    object pnlOpenSource: TPanel
      Left = 1
      Top = 225
      Width = 638
      Height = 223
      Align = alClient
      Caption = 'pnlOpenSource'
      ShowCaption = False
      TabOrder = 1
      object llOpenSourceAcknowledge: TLinkLabel
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 630
        Height = 29
        Align = alTop
        Caption = 
          'Deputy uses <a href="https://github.com/DelphiWorlds/TOTAL">TOTA' +
          'L</a>, a framework for experts, and <a href="https://github.com/' +
          'DelphiWorlds/Kastri">Kastri</a> .'
        TabOrder = 0
        ExplicitWidth = 450
      end
      object llOpenSourceCommit: TLinkLabel
        Left = 1
        Top = 36
        Width = 636
        Height = 29
        Align = alTop
        Caption = 'llOpenSourceCommit'
        TabOrder = 1
        ExplicitWidth = 174
      end
    end
  end
end
