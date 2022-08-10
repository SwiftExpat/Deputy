object frmDeputyHarness: TfrmDeputyHarness
  Left = 0
  Top = 0
  Caption = 'Deputy Form Harness'
  ClientHeight = 593
  ClientWidth = 944
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 944
    Height = 368
    ActivePage = tsUpdates
    Align = alClient
    TabOrder = 0
    object tsProcMgr: TTabSheet
      Caption = 'Process Manager'
      object lblProcDir: TLabel
        Left = 24
        Top = 80
        Width = 88
        Height = 15
        Caption = 'ProcessDirectory'
      end
      object lblProcName: TLabel
        Left = 24
        Top = 120
        Width = 75
        Height = 15
        Caption = 'Process Name'
      end
      object valDirName: TLabel
        Left = 160
        Top = 80
        Width = 112
        Height = 15
        Caption = 'C:\...\Studio\22.0\bin'
      end
      object valProcName: TLabel
        Left = 160
        Top = 120
        Width = 116
        Height = 15
        Caption = 'valProcName.Caption'
      end
      object btnProcMgrShow: TButton
        Left = 24
        Top = 16
        Width = 137
        Height = 25
        Caption = 'Show Proc Mgr'
        TabOrder = 0
        OnClick = btnProcMgrShowClick
      end
      object bntProcTest: TButton
        Left = 248
        Top = 168
        Width = 145
        Height = 25
        Caption = 'Test Proc Mgr'
        TabOrder = 1
        OnClick = bntProcTestClick
      end
      object btnSelectProc: TButton
        Left = 24
        Top = 152
        Width = 137
        Height = 25
        Caption = 'Select Process'
        TabOrder = 2
        OnClick = btnSelectProcClick
      end
    end
    object tsIdeInstance: TTabSheet
      Caption = 'Ide Instance Mgr'
      ImageIndex = 1
      object GridPanel1: TGridPanel
        Left = 10
        Top = 10
        Width = 640
        Height = 64
        BorderStyle = bsSingle
        ColumnCollection = <
          item
            SizeStyle = ssAbsolute
            Value = 72.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 96.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 96.000000000000000000
          end
          item
            Value = 100.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = lblIde1
            Row = 0
          end
          item
            Column = 1
            Control = btnStartIde1
            Row = 0
          end
          item
            Column = 0
            Control = lblIde2
            Row = 1
          end
          item
            Column = 1
            Control = btnStartIde2
            Row = 1
          end
          item
            Column = 2
            Control = lblPidIDE1
            Row = 0
          end
          item
            Column = 2
            Control = lblPidIDE2
            Row = 1
          end
          item
            Column = 3
            Control = editIde1Params
            Row = 0
          end
          item
            Column = 3
            Control = editIde2Params
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
        object lblIde1: TLabel
          Left = 1
          Top = 1
          Width = 72
          Height = 29
          Align = alClient
          Alignment = taCenter
          Caption = 'IDE Instance 1'
          Layout = tlCenter
          ExplicitWidth = 73
          ExplicitHeight = 15
        end
        object btnStartIde1: TButton
          AlignWithMargins = True
          Left = 76
          Top = 4
          Width = 90
          Height = 23
          Align = alClient
          Caption = 'Start IDE 1'
          TabOrder = 0
          OnClick = btnStartIde1Click
        end
        object lblIde2: TLabel
          Left = 1
          Top = 30
          Width = 72
          Height = 29
          Align = alClient
          Alignment = taCenter
          Caption = 'IDE Instance 2'
          Layout = tlCenter
          ExplicitWidth = 73
          ExplicitHeight = 15
        end
        object btnStartIde2: TButton
          AlignWithMargins = True
          Left = 76
          Top = 33
          Width = 90
          Height = 23
          Align = alClient
          Caption = 'Start IDE 2'
          TabOrder = 1
          OnClick = btnStartIde2Click
        end
        object lblPidIDE1: TLabel
          AlignWithMargins = True
          Left = 172
          Top = 4
          Width = 90
          Height = 23
          Align = alClient
          Caption = 'PID = ######'
          Layout = tlCenter
          ExplicitWidth = 74
          ExplicitHeight = 15
        end
        object lblPidIDE2: TLabel
          AlignWithMargins = True
          Left = 172
          Top = 33
          Width = 90
          Height = 23
          Align = alClient
          Caption = 'PID = ######'
          Layout = tlCenter
          ExplicitWidth = 74
          ExplicitHeight = 15
        end
        object editIde1Params: TEdit
          AlignWithMargins = True
          Left = 268
          Top = 4
          Width = 364
          Height = 23
          Align = alClient
          TabOrder = 2
          Text = '-np -r SEIEDev -pDelphi'
        end
        object editIde2Params: TEdit
          AlignWithMargins = True
          Left = 268
          Top = 33
          Width = 364
          Height = 23
          Align = alClient
          TabOrder = 3
          Text = '-np -r SEIEDev -pDelphi'
        end
      end
    end
    object tsUpdates: TTabSheet
      Caption = 'tsUpdates'
      ImageIndex = 2
    end
  end
  object memoProcMgrMessage: TMemo
    Left = 0
    Top = 368
    Width = 944
    Height = 225
    Align = alBottom
    Lines.Strings = (
      'memoProcMgrMessage')
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'exe'
    Filter = 'Executables (*.exe)|*.EXE'
    Title = 'Choose file for Deputy to manage'
    Left = 712
    Top = 112
  end
end
