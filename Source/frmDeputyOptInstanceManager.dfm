object frmDeputyOptInstMgr: TfrmDeputyOptInstMgr
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Align = alClient
  TabOrder = 0
  object lblDeputyInstMgrHeader: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 634
    Height = 25
    Align = alTop
    Caption = 
      'Control Deputy'#39's ability to detect a second instance of the IDE ' +
      'at startup.'
    WordWrap = True
    ExplicitWidth = 576
  end
  object rgInstanceManager: TRadioGroup
    Left = 0
    Top = 31
    Width = 640
    Height = 105
    Hint = 'Disable prevents the Instance Manager in the IDE started event'
    Align = alTop
    Caption = 'Instance Manager'
    Items.Strings = (
      'Disable'
      'Enable')
    TabOrder = 0
    OnClick = rgInstanceManagerClick
    ExplicitTop = 56
  end
end
