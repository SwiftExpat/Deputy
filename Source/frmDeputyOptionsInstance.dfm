object frmDeputyOptInstance: TfrmDeputyOptInstance
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Align = alClient
  TabOrder = 0
  object rgInstanceManager: TRadioGroup
    Left = 32
    Top = 24
    Width = 209
    Height = 121
    Caption = 'Instance Manager'
    Items.Strings = (
      'Diasable'
      'Enable')
    TabOrder = 0
    OnClick = rgInstanceManagerClick
  end
end
