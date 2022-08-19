object LeakLoopTester: TLeakLoopTester
  Left = 0
  Top = 0
  Caption = 'Leak and Loop Tester'
  ClientHeight = 424
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Button1: TButton
    Left = 176
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Single leak'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 48
    Top = 56
    Width = 75
    Height = 25
    Caption = 'big leak'
    TabOrder = 1
    OnClick = Button2Click
  end
  object btnLoop: TButton
    Left = 48
    Top = 144
    Width = 121
    Height = 25
    Caption = 'Loop forever'
    TabOrder = 2
    OnClick = btnLoopClick
  end
  object Memo1: TMemo
    Left = 0
    Top = 335
    Width = 618
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
  object memTable: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 504
    Top = 144
    object memTableLeakName: TStringField
      FieldName = 'LeakName'
    end
  end
end
