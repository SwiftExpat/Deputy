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
    Height = 196
    Align = alTop
    Caption = 'gpUpdates'
    ColumnCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 96.000000000000000000
      end
      item
        SizeStyle = ssAbsolute
        Value = 220.000000000000000000
      end
      item
        SizeStyle = ssAbsolute
        Value = 164.000000000000000000
      end
      item
        Value = 100.000000000000000000
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
        SizeStyle = ssAbsolute
        Value = 24.000000000000000000
      end
      item
        Value = 16.446296828550970000
      end
      item
        Value = 16.614285885756040000
      end
      item
        Value = 16.924303900295690000
      end
      item
        Value = 16.717808507005190000
      end
      item
        Value = 33.297304878392110000
      end>
    ShowCaption = False
    TabOrder = 0
    object lblHdrItem: TLabel
      Left = 1
      Top = 1
      Width = 96
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'Item'
      ExplicitWidth = 24
      ExplicitHeight = 15
    end
    object lblHdrVerCurr: TLabel
      Left = 97
      Top = 1
      Width = 220
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'Current Version'
      ExplicitWidth = 81
      ExplicitHeight = 15
    end
    object lblHdrUpdate: TLabel
      Left = 481
      Top = 1
      Width = 136
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'Update'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblHdrVerAvail: TLabel
      Left = 317
      Top = 1
      Width = 164
      Height = 24
      Align = alClient
      Alignment = taCenter
      Caption = 'Available Version'
      ExplicitWidth = 89
      ExplicitHeight = 15
    end
    object lblDeputy: TLabel
      Left = 1
      Top = 25
      Width = 96
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Deputy'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblCaddie: TLabel
      Left = 1
      Top = 53
      Width = 96
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Caddie'
      ExplicitWidth = 37
      ExplicitHeight = 15
    end
    object lblDemoFMX: TLabel
      Left = 1
      Top = 81
      Width = 96
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'FMX Demo'
      ExplicitWidth = 59
      ExplicitHeight = 15
    end
    object lblDemoVCL: TLabel
      Left = 1
      Top = 110
      Width = 96
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'VCL Demo'
      ExplicitWidth = 56
      ExplicitHeight = 15
    end
    object lblDeputyInst: TLabel
      Left = 97
      Top = 25
      Width = 220
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'DeputyInst'
      ExplicitWidth = 57
      ExplicitHeight = 15
    end
    object lblDeputyAvail: TLabel
      Left = 317
      Top = 25
      Width = 164
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'deputyavail'
      ExplicitWidth = 61
      ExplicitHeight = 15
    end
    object btnUpdateDeputy: TButton
      AlignWithMargins = True
      Left = 484
      Top = 28
      Width = 130
      Height = 22
      Align = alClient
      Caption = 'Update Deputy'
      TabOrder = 0
      OnClick = btnUpdateDeputyClick
    end
    object lblCaddieInst: TLabel
      Left = 97
      Top = 53
      Width = 220
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'caddieInst'
      ExplicitWidth = 54
      ExplicitHeight = 15
    end
    object lblCaddieAvail: TLabel
      Left = 317
      Top = 53
      Width = 164
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'CaddieAvail'
      ExplicitWidth = 63
      ExplicitHeight = 15
    end
    object btnUpdateCaddie: TButton
      AlignWithMargins = True
      Left = 484
      Top = 56
      Width = 130
      Height = 22
      Align = alClient
      Caption = 'Update Caddie'
      TabOrder = 1
      OnClick = btnUpdateCaddieClick
    end
    object lblDemoFmxInst: TLabel
      Left = 97
      Top = 81
      Width = 220
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'fmxInst'
      ExplicitWidth = 40
      ExplicitHeight = 15
    end
    object lblDemoFMXAvail: TLabel
      Left = 317
      Top = 81
      Width = 164
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'FmxAvail'
      ExplicitWidth = 49
      ExplicitHeight = 15
    end
    object btnUpdateDemoFMX: TButton
      AlignWithMargins = True
      Left = 484
      Top = 84
      Width = 130
      Height = 23
      Align = alClient
      Caption = 'Update FMX Demo'
      TabOrder = 2
      OnClick = btnUpdateDemoFMXClick
    end
    object lblDemoVCLInst: TLabel
      Left = 97
      Top = 110
      Width = 220
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'vclInst'
      ExplicitWidth = 34
      ExplicitHeight = 15
    end
    object lblDemoVCLAvail: TLabel
      Left = 317
      Top = 110
      Width = 164
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'vclAvail'
      ExplicitWidth = 41
      ExplicitHeight = 15
    end
    object btnUpdateDemoVCL: TButton
      AlignWithMargins = True
      Left = 484
      Top = 113
      Width = 130
      Height = 22
      Align = alClient
      Caption = 'Update VCL Demo'
      TabOrder = 3
      OnClick = btnUpdateDemoVCLClick
    end
    object lblHdrUpdateRefresh: TLabel
      Left = 1
      Top = 138
      Width = 96
      Height = 57
      Align = alClient
      Alignment = taCenter
      Caption = 'Updates Refreshed'
      WordWrap = True
      ExplicitWidth = 52
      ExplicitHeight = 30
    end
    object lblUpdateRefresh: TLabel
      Left = 97
      Top = 138
      Width = 220
      Height = 57
      Align = alClient
      Alignment = taCenter
      Caption = '00:00:00'
      ExplicitWidth = 42
      ExplicitHeight = 15
    end
  end
  object memoMessages: TMemo
    Left = 0
    Top = 196
    Width = 618
    Height = 228
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
