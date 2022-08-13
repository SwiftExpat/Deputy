object frmDeputyOptProcMgr: TfrmDeputyOptProcMgr
  Left = 0
  Top = 0
  Width = 762
  Height = 480
  TabOrder = 0
  object LinkLabel1: TLinkLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 756
    Height = 29
    Align = alTop
    Caption = 
      'Process Manager configuration options , hover to show the hint e' +
      'xplainations.'
    TabOrder = 0
    ExplicitWidth = 621
  end
  object GridPanel1: TGridPanel
    Left = 0
    Top = 35
    Width = 762
    Height = 445
    Align = alClient
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = gpOptions
        Row = 0
      end
      item
        Column = 0
        Control = gpTimeouts
        Row = 1
      end
      item
        Column = 0
        Control = Memo1
        Row = 2
      end>
    RowCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 120.000000000000000000
      end
      item
        SizeStyle = ssAbsolute
        Value = 164.000000000000000000
      end
      item
        Value = 100.000000000000000000
      end>
    ShowCaption = False
    TabOrder = 1
    object gpOptions: TGridPanel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 754
      Height = 117
      Align = alTop
      Anchors = []
      Caption = 'gp'
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 164.000000000000000000
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
          Control = rgProcMgrActive
          Row = 0
          RowSpan = 2
        end
        item
          Column = 1
          Control = rgProcStopCommand
          Row = 0
          RowSpan = 2
        end
        item
          Column = 2
          Control = cbCloseLeakWindow
          Row = 0
        end
        item
          Column = 2
          Control = cbCopyLeakMessage
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
      object rgProcMgrActive: TRadioGroup
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 158
        Height = 109
        Hint = 'Disables Process Manager for compile and debug'
        Align = alClient
        Caption = 'Process Manager'
        Items.Strings = (
          'Disabled'
          'Enabled')
        TabOrder = 0
      end
      object rgProcStopCommand: TRadioGroup
        AlignWithMargins = True
        Left = 168
        Top = 4
        Width = 158
        Height = 109
        Hint = 
          'Terminate uses process terminate and close sends a wm_close mess' +
          'age'
        Align = alClient
        Caption = 'Terminate Action'
        Items.Strings = (
          'Terminate'
          'Close')
        TabOrder = 1
        OnClick = rgProcStopCommandClick
        ExplicitTop = 5
      end
      object cbCloseLeakWindow: TCheckBox
        AlignWithMargins = True
        Left = 332
        Top = 4
        Width = 418
        Height = 52
        Hint = 'Close possible memory leak window'
        Align = alClient
        Caption = 'Close Leak Window'
        TabOrder = 2
        OnClick = cbCloseLeakWindowClick
      end
      object cbCopyLeakMessage: TCheckBox
        AlignWithMargins = True
        Left = 332
        Top = 62
        Width = 418
        Height = 51
        Hint = 'Copy memory leak message to history'
        Align = alClient
        Caption = 'Copy Leak Message'
        TabOrder = 3
        OnClick = cbCopyLeakMessageClick
      end
    end
    object gpTimeouts: TGridPanel
      AlignWithMargins = True
      Left = 4
      Top = 124
      Width = 445
      Height = 158
      Align = alLeft
      BorderWidth = 1
      BorderStyle = bsSingle
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 240.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 96.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          ColumnSpan = 2
          Control = lblHdrTimeouts
          Row = 0
        end
        item
          Column = 0
          Control = lblWaitPollTimeout
          Row = 1
        end
        item
          Column = 1
          Control = edtWaitPoll
          Row = 1
        end
        item
          Column = 0
          Control = lblHdrShowDelay
          Row = 2
        end
        item
          Column = 1
          Control = edtShowDelay
          Row = 2
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 32.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 42.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 42.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      ShowCaption = False
      TabOrder = 1
      object lblHdrTimeouts: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 5
        Width = 330
        Height = 26
        Align = alClient
        Alignment = taCenter
        Caption = 'Process Manager Timeouts'
        ExplicitWidth = 213
        ExplicitHeight = 25
      end
      object lblWaitPollTimeout: TLabel
        Left = 2
        Top = 34
        Width = 240
        Height = 42
        Hint = 'Controls loop time waiting for the process to close'
        Align = alClient
        Alignment = taRightJustify
        Caption = 'WaitPoll Interval (ms)'
        Layout = tlCenter
        ExplicitLeft = 77
        ExplicitWidth = 165
        ExplicitHeight = 25
      end
      object edtWaitPoll: TSpinEdit
        AlignWithMargins = True
        Left = 245
        Top = 37
        Width = 90
        Height = 36
        Align = alClient
        MaxValue = 200
        MinValue = 25
        TabOrder = 0
        Value = 25
        OnChange = edtWaitPollChange
      end
      object lblHdrShowDelay: TLabel
        Left = 2
        Top = 76
        Width = 240
        Height = 42
        Hint = 'Controls delay for showing the Process Manger window.'
        Align = alClient
        Alignment = taRightJustify
        Caption = 'Show Manager Delay (ms)'
        Layout = tlCenter
        ExplicitLeft = 35
        ExplicitWidth = 207
        ExplicitHeight = 25
      end
      object edtShowDelay: TSpinEdit
        AlignWithMargins = True
        Left = 245
        Top = 79
        Width = 90
        Height = 36
        Align = alClient
        MaxValue = 1500
        MinValue = 100
        TabOrder = 1
        Value = 200
        OnChange = edtShowDelayChange
      end
    end
    object Memo1: TMemo
      Left = 1
      Top = 355
      Width = 760
      Height = 89
      Align = alBottom
      Anchors = []
      TabOrder = 2
    end
  end
end
