object DeputyUpdates: TDeputyUpdates
  Left = 0
  Top = 0
  Caption = 'Deputy Updates'
  ClientHeight = 424
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object gpUpdates: TGridPanel
    Left = 0
    Top = 0
    Width = 618
    Height = 132
    Align = alTop
    Caption = 'gpUpdates'
    ColumnCollection = <
      item
        Value = 25.974025974025970000
      end
      item
        Value = 31.168831168831170000
      end
      item
        Value = 14.285714285714290000
      end
      item
        Value = 28.571428571428570000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = lblHdrItem
        Row = 0
      end
      item
        Column = 1
        Control = lblHdrVerCurr
        Row = 0
      end
      item
        Column = 3
        Control = lblHdrUpdate
        Row = 0
      end
      item
        Column = 2
        Control = lblHdrVerAvail
        Row = 0
      end
      item
        Column = 0
        Control = lblDeputy
        Row = 1
      end
      item
        Column = 0
        Control = lblCaddie
        Row = 2
      end
      item
        Column = 0
        Control = lblDemoFMX
        Row = 3
      end
      item
        Column = 0
        Control = lblDemoVCL
        Row = 4
      end
      item
        Column = 1
        Control = lblDeputyInst
        Row = 1
      end
      item
        Column = 2
        Control = lblDeputyAvail
        Row = 1
      end
      item
        Column = 3
        Control = btnUpdateDeputy
        Row = 1
      end
      item
        Column = 1
        Control = lblCaddieInst
        Row = 2
      end
      item
        Column = 2
        Control = lblCaddieAvail
        Row = 2
      end
      item
        Column = 3
        Control = btnUpdateCaddie
        Row = 2
      end
      item
        Column = 1
        Control = lblDemoFmxInst
        Row = 3
      end
      item
        Column = 2
        Control = lblDemoFMXAvail
        Row = 3
      end
      item
        Column = 3
        Control = btnUpdateDemoFMX
        Row = 3
      end
      item
        Column = 1
        Control = lblDemoVCLInst
        Row = 4
      end
      item
        Column = 2
        Control = lblDemoVCLAvail
        Row = 4
      end
      item
        Column = 3
        Control = bntUpdateDemoVCL
        Row = 4
      end
      item
        Column = 0
        Control = lblHdrUpdateRefresh
        Row = 5
      end
      item
        Column = 1
        Control = lblUpdateRefresh
        Row = 5
      end>
    RowCollection = <
      item
        Value = 19.847349113286680000
      end
      item
        Value = 15.464092102564930000
      end
      item
        Value = 15.632262927820000000
      end
      item
        Value = 19.942616389030450000
      end
      item
        Value = 18.735897562942610000
      end
      item
        Value = 10.377781904355340000
      end>
    ShowCaption = False
    TabOrder = 0
    object lblHdrItem: TLabel
      Left = 1
      Top = 1
      Width = 160
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Item'
      ExplicitWidth = 24
      ExplicitHeight = 15
    end
    object lblHdrVerCurr: TLabel
      Left = 161
      Top = 1
      Width = 192
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Current Version'
      ExplicitWidth = 81
      ExplicitHeight = 15
    end
    object lblHdrUpdate: TLabel
      Left = 441
      Top = 1
      Width = 176
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Update'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblHdrVerAvail: TLabel
      Left = 353
      Top = 1
      Width = 88
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Available Version'
      ExplicitWidth = 89
      ExplicitHeight = 15
    end
    object lblDeputy: TLabel
      Left = 1
      Top = 24
      Width = 160
      Height = 19
      Align = alClient
      Alignment = taCenter
      Caption = 'Deputy'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblCaddie: TLabel
      Left = 1
      Top = 43
      Width = 160
      Height = 18
      Align = alClient
      Alignment = taCenter
      Caption = 'Caddie'
      ExplicitTop = 52
      ExplicitWidth = 37
      ExplicitHeight = 15
    end
    object lblDemoFMX: TLabel
      Left = 1
      Top = 61
      Width = 160
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'FMX Demo'
      ExplicitTop = 75
      ExplicitWidth = 59
      ExplicitHeight = 15
    end
    object lblDemoVCL: TLabel
      Left = 1
      Top = 85
      Width = 160
      Height = 22
      Align = alClient
      Alignment = taCenter
      Caption = 'VCL Demo'
      ExplicitTop = 98
      ExplicitWidth = 56
      ExplicitHeight = 15
    end
    object lblDeputyInst: TLabel
      Left = 161
      Top = 24
      Width = 192
      Height = 19
      Align = alClient
      Alignment = taCenter
      Caption = 'DeputyInst'
      ExplicitWidth = 57
      ExplicitHeight = 15
    end
    object lblDeputyAvail: TLabel
      Left = 353
      Top = 24
      Width = 88
      Height = 19
      Align = alClient
      Alignment = taCenter
      Caption = 'deputyavail'
      ExplicitWidth = 61
      ExplicitHeight = 15
    end
    object btnUpdateDeputy: TButton
      AlignWithMargins = True
      Left = 444
      Top = 27
      Width = 170
      Height = 13
      Align = alClient
      Caption = 'Update Deputy'
      TabOrder = 0
      ExplicitHeight = 22
    end
    object lblCaddieInst: TLabel
      Left = 161
      Top = 43
      Width = 192
      Height = 18
      Align = alClient
      Alignment = taCenter
      Caption = 'caddieInst'
      ExplicitTop = 52
      ExplicitWidth = 54
      ExplicitHeight = 15
    end
    object lblCaddieAvail: TLabel
      Left = 353
      Top = 43
      Width = 88
      Height = 18
      Align = alClient
      Alignment = taCenter
      Caption = 'CaddieAvail'
      ExplicitTop = 52
      ExplicitWidth = 63
      ExplicitHeight = 15
    end
    object btnUpdateCaddie: TButton
      AlignWithMargins = True
      Left = 444
      Top = 46
      Width = 170
      Height = 12
      Align = alClient
      Caption = 'Update Caddie'
      TabOrder = 1
      ExplicitTop = 55
      ExplicitHeight = 17
    end
    object lblDemoFmxInst: TLabel
      Left = 161
      Top = 61
      Width = 192
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'fmxInst'
      ExplicitTop = 75
      ExplicitWidth = 40
      ExplicitHeight = 15
    end
    object lblDemoFMXAvail: TLabel
      Left = 353
      Top = 61
      Width = 88
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'FmxAvail'
      ExplicitTop = 75
      ExplicitWidth = 49
      ExplicitHeight = 15
    end
    object btnUpdateDemoFMX: TButton
      AlignWithMargins = True
      Left = 444
      Top = 64
      Width = 170
      Height = 18
      Align = alClient
      Caption = 'Update FMX Demo'
      TabOrder = 2
      ExplicitTop = 78
      ExplicitHeight = 17
    end
    object lblDemoVCLInst: TLabel
      Left = 161
      Top = 85
      Width = 192
      Height = 22
      Align = alClient
      Alignment = taCenter
      Caption = 'vclInst'
      ExplicitTop = 98
      ExplicitWidth = 34
      ExplicitHeight = 15
    end
    object lblDemoVCLAvail: TLabel
      Left = 353
      Top = 85
      Width = 88
      Height = 22
      Align = alClient
      Alignment = taCenter
      Caption = 'vclAvail'
      ExplicitTop = 98
      ExplicitWidth = 41
      ExplicitHeight = 15
    end
    object bntUpdateDemoVCL: TButton
      AlignWithMargins = True
      Left = 444
      Top = 88
      Width = 170
      Height = 16
      Align = alClient
      Caption = 'Update VCL Demo'
      TabOrder = 3
      ExplicitTop = 101
      ExplicitHeight = 15
    end
    object lblHdrUpdateRefresh: TLabel
      Left = 1
      Top = 107
      Width = 160
      Height = 12
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Last Update Refresh'
      ExplicitLeft = 57
      ExplicitTop = 108
      ExplicitWidth = 104
      ExplicitHeight = 15
    end
    object lblUpdateRefresh: TLabel
      Left = 161
      Top = 107
      Width = 192
      Height = 12
      Align = alClient
      Alignment = taCenter
      Caption = '00:00:00'
      ExplicitTop = 108
      ExplicitWidth = 42
      ExplicitHeight = 15
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 132
    Width = 618
    Height = 292
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    ExplicitTop = 120
    ExplicitHeight = 304
  end
end
