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
    ActivePage = tsProcMgr
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 593
    object tsProcMgr: TTabSheet
      Caption = 'Process Manager'
      object lblProcDir: TLabel
        Left = 24
        Top = 80
        Width = 145
        Height = 15
        Caption = 'ProcessDirectory'
      end
      object lblProcName: TLabel
        Left = 24
        Top = 120
        Width = 113
        Height = 15
        Caption = 'Process Name'
      end
      object valDirName: TLabel
        Left = 160
        Top = 80
        Width = 721
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
    ExplicitTop = 0
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'exe'
    Filter = 'Executables (*.exe)|*.EXE'
    Title = 'Choose file for Deputy to manage'
    Left = 712
    Top = 112
  end
end
