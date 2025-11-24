object fChangePeriod: TfChangePeriod
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Period'
  ClientHeight = 211
  ClientWidth = 246
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    246
    211)
  PixelsPerInch = 96
  TextHeight = 13
  object lDuration: TLabel
    Left = 78
    Top = 112
    Width = 43
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lDuration'
    ExplicitTop = 62
  end
  object lStartDesc: TLabel
    Left = 44
    Top = 57
    Width = 28
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Start:'
    ExplicitTop = 47
  end
  object lStopDesc: TLabel
    Left = 46
    Top = 90
    Width = 26
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Stop:'
    ExplicitTop = 80
  end
  object lStateDesc: TLabel
    Left = 40
    Top = 134
    Width = 30
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'State:'
    ExplicitTop = 84
  end
  object lDurationDesc: TLabel
    Left = 27
    Top = 112
    Width = 45
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Duration:'
    ExplicitTop = 62
  end
  object lFirstOfDayDesc: TLabel
    Left = 8
    Top = 159
    Width = 62
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'First Of Day:'
    ExplicitTop = 109
  end
  object lStartDateDesc: TLabel
    Left = 45
    Top = 22
    Width = 27
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Date:'
    ExplicitTop = 12
  end
  object cbState: TComboBox
    Left = 76
    Top = 131
    Width = 150
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 0
    Text = 'cbState'
  end
  object bAccept: TButton
    Left = 8
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Accept'
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 132
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object cbFirstOfDay: TCheckBox
    Left = 76
    Top = 158
    Width = 150
    Height = 17
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object dpStartDate: TDatePicker
    Left = 78
    Top = 12
    Anchors = [akLeft, akBottom]
    Date = 43868.000000000000000000
    DateFormat = 'dd/MM/yyyy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabOrder = 4
  end
  object tpStart: TDateTimePicker
    Left = 78
    Top = 50
    Width = 150
    Height = 27
    Date = 44029.000000000000000000
    Time = 0.353895821761398100
    DateFormat = dfLong
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    Kind = dtkTime
    ParentFont = False
    TabOrder = 5
    OnChange = tpStartChange
  end
  object tpStop: TDateTimePicker
    Left = 78
    Top = 83
    Width = 150
    Height = 27
    Date = 44029.000000000000000000
    Time = 0.353895821761398100
    DateFormat = dfLong
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    Kind = dtkTime
    ParentFont = False
    TabOrder = 6
    OnChange = tpStartChange
  end
end
