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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
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
        Control = btnUpdateDemoVCL
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
        Value = 10.377781904355330000
      end>
    ShowCaption = False
    TabOrder = 0
    object lblHdrItem: TLabel
      Left = 1
      Top = 1
      Width = 160
      Height = 26
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
      Height = 26
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
      Height = 26
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
      Height = 26
      Align = alClient
      Alignment = taCenter
      Caption = 'Available Version'
      ExplicitWidth = 89
      ExplicitHeight = 15
    end
    object lblDeputy: TLabel
      Left = 1
      Top = 27
      Width = 160
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'Deputy'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblCaddie: TLabel
      Left = 1
      Top = 47
      Width = 160
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'Caddie'
      ExplicitWidth = 37
      ExplicitHeight = 15
    end
    object lblDemoFMX: TLabel
      Left = 1
      Top = 67
      Width = 160
      Height = 26
      Align = alClient
      Alignment = taCenter
      Caption = 'FMX Demo'
      ExplicitWidth = 59
      ExplicitHeight = 15
    end
    object lblDemoVCL: TLabel
      Left = 1
      Top = 93
      Width = 160
      Height = 25
      Align = alClient
      Alignment = taCenter
      Caption = 'VCL Demo'
      ExplicitWidth = 56
      ExplicitHeight = 15
    end
    object lblDeputyInst: TLabel
      Left = 161
      Top = 27
      Width = 192
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'DeputyInst'
      ExplicitWidth = 57
      ExplicitHeight = 15
    end
    object lblDeputyAvail: TLabel
      Left = 353
      Top = 27
      Width = 88
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'deputyavail'
      ExplicitWidth = 61
      ExplicitHeight = 15
    end
    object btnUpdateDeputy: TButton
      AlignWithMargins = True
      Left = 444
      Top = 30
      Width = 170
      Height = 14
      Align = alClient
      Caption = 'Update Deputy'
      TabOrder = 0
      OnClick = btnUpdateDeputyClick
    end
    object lblCaddieInst: TLabel
      Left = 161
      Top = 47
      Width = 192
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'caddieInst'
      ExplicitWidth = 54
      ExplicitHeight = 15
    end
    object lblCaddieAvail: TLabel
      Left = 353
      Top = 47
      Width = 88
      Height = 20
      Align = alClient
      Alignment = taCenter
      Caption = 'CaddieAvail'
      ExplicitWidth = 63
      ExplicitHeight = 15
    end
    object btnUpdateCaddie: TButton
      AlignWithMargins = True
      Left = 444
      Top = 50
      Width = 170
      Height = 14
      Align = alClient
      Caption = 'Update Caddie'
      TabOrder = 1
      OnClick = btnUpdateCaddieClick
    end
    object lblDemoFmxInst: TLabel
      Left = 161
      Top = 67
      Width = 192
      Height = 26
      Align = alClient
      Alignment = taCenter
      Caption = 'fmxInst'
      ExplicitWidth = 40
      ExplicitHeight = 15
    end
    object lblDemoFMXAvail: TLabel
      Left = 353
      Top = 67
      Width = 88
      Height = 26
      Align = alClient
      Alignment = taCenter
      Caption = 'FmxAvail'
      ExplicitWidth = 49
      ExplicitHeight = 15
    end
    object btnUpdateDemoFMX: TButton
      AlignWithMargins = True
      Left = 444
      Top = 70
      Width = 170
      Height = 20
      Align = alClient
      Caption = 'Update FMX Demo'
      TabOrder = 2
      OnClick = btnUpdateDemoFMXClick
    end
    object lblDemoVCLInst: TLabel
      Left = 161
      Top = 93
      Width = 192
      Height = 25
      Align = alClient
      Alignment = taCenter
      Caption = 'vclInst'
      ExplicitWidth = 34
      ExplicitHeight = 15
    end
    object lblDemoVCLAvail: TLabel
      Left = 353
      Top = 93
      Width = 88
      Height = 25
      Align = alClient
      Alignment = taCenter
      Caption = 'vclAvail'
      ExplicitWidth = 41
      ExplicitHeight = 15
    end
    object btnUpdateDemoVCL: TButton
      AlignWithMargins = True
      Left = 444
      Top = 96
      Width = 170
      Height = 19
      Align = alClient
      Caption = 'Update VCL Demo'
      TabOrder = 3
      OnClick = btnUpdateDemoVCLClick
    end
    object lblHdrUpdateRefresh: TLabel
      Left = 1
      Top = 118
      Width = 160
      Height = 13
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Last Update Refresh'
      ExplicitLeft = 57
      ExplicitWidth = 104
      ExplicitHeight = 15
    end
    object lblUpdateRefresh: TLabel
      Left = 161
      Top = 118
      Width = 192
      Height = 13
      Align = alClient
      Alignment = taCenter
      Caption = '00:00:00'
      ExplicitWidth = 42
      ExplicitHeight = 15
    end
  end
  object memoMessages: TMemo
    Left = 0
    Top = 132
    Width = 618
    Height = 292
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
