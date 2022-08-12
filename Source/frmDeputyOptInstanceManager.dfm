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
    Height = 50
    Align = alTop
    Caption = 
      'This setting controls Deputy ability to look for a second instan' +
      'ce of the IDE at startup.'
    WordWrap = True
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 618
  end
  object rgInstanceManager: TRadioGroup
    Left = 16
    Top = 59
    Width = 225
    Height = 105
    Caption = 'Instance Manager'
    Items.Strings = (
      'Disable'
      'Enable')
    TabOrder = 0
    OnClick = rgInstanceManagerClick
  end
end
