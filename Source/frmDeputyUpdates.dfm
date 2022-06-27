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
    Height = 120
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
      end>
    RowCollection = <
      item
        Value = 19.124847001223990000
      end
      item
        Value = 24.479804161566710000
      end
      item
        Value = 19.124847001223990000
      end
      item
        Value = 19.216646266829870000
      end
      item
        Value = 18.053855569155450000
      end>
    ShowCaption = False
    TabOrder = 0
    ExplicitTop = -6
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
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Deputy'
      ExplicitTop = 11
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblCaddie: TLabel
      Left = 1
      Top = 52
      Width = 160
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Caddie'
      ExplicitTop = 21
      ExplicitWidth = 37
      ExplicitHeight = 15
    end
    object lblDemoFMX: TLabel
      Left = 1
      Top = 75
      Width = 160
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'FMX Demo'
      ExplicitTop = 29
      ExplicitWidth = 59
      ExplicitHeight = 15
    end
    object lblDemoVCL: TLabel
      Left = 1
      Top = 98
      Width = 160
      Height = 21
      Align = alClient
      Alignment = taCenter
      Caption = 'VCL Demo'
      ExplicitTop = 35
      ExplicitWidth = 56
      ExplicitHeight = 15
    end
    object lblDeputyInst: TLabel
      Left = 161
      Top = 24
      Width = 192
      Height = 28
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
      Height = 28
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
      Height = 22
      Align = alClient
      Caption = 'Update Deputy'
      TabOrder = 0
      ExplicitLeft = 272
      ExplicitTop = 48
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
    object lblCaddieInst: TLabel
      Left = 161
      Top = 52
      Width = 192
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'caddieInst'
      ExplicitWidth = 54
      ExplicitHeight = 15
    end
    object lblCaddieAvail: TLabel
      Left = 353
      Top = 52
      Width = 88
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'CaddieAvail'
      ExplicitWidth = 63
      ExplicitHeight = 15
    end
    object btnUpdateCaddie: TButton
      AlignWithMargins = True
      Left = 444
      Top = 55
      Width = 170
      Height = 17
      Align = alClient
      Caption = 'Update Caddie'
      TabOrder = 1
      ExplicitLeft = 272
      ExplicitTop = 48
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
    object lblDemoFmxInst: TLabel
      Left = 161
      Top = 75
      Width = 192
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'fmxInst'
      ExplicitWidth = 40
      ExplicitHeight = 15
    end
    object lblDemoFMXAvail: TLabel
      Left = 353
      Top = 75
      Width = 88
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'FmxAvail'
      ExplicitWidth = 49
      ExplicitHeight = 15
    end
    object btnUpdateDemoFMX: TButton
      AlignWithMargins = True
      Left = 444
      Top = 78
      Width = 170
      Height = 17
      Align = alClient
      Caption = 'Update FMX Demo'
      TabOrder = 2
      ExplicitLeft = 272
      ExplicitTop = 48
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
    object lblDemoVCLInst: TLabel
      Left = 161
      Top = 98
      Width = 192
      Height = 21
      Align = alClient
      Alignment = taCenter
      Caption = 'vclInst'
      ExplicitWidth = 34
      ExplicitHeight = 15
    end
    object lblDemoVCLAvail: TLabel
      Left = 353
      Top = 98
      Width = 88
      Height = 21
      Align = alClient
      Alignment = taCenter
      Caption = 'vclAvail'
      ExplicitWidth = 41
      ExplicitHeight = 15
    end
    object bntUpdateDemoVCL: TButton
      AlignWithMargins = True
      Left = 444
      Top = 101
      Width = 170
      Height = 15
      Align = alClient
      Caption = 'Update VCL Demo'
      TabOrder = 3
      ExplicitLeft = 272
      ExplicitTop = 48
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 120
    Width = 618
    Height = 304
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
