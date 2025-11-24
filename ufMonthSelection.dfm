object fMonthSelection: TfMonthSelection
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Month Selection'
  ClientHeight = 69
  ClientWidth = 172
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 13
  object lYear: TLabel
    Left = 5
    Top = 11
    Width = 22
    Height = 13
    Caption = 'Year'
  end
  object lMonth: TLabel
    Left = 92
    Top = 11
    Width = 30
    Height = 13
    Caption = 'Month'
  end
  object bAccept: TButton
    Left = 8
    Top = 36
    Width = 75
    Height = 25
    Caption = 'Accept'
    ModalResult = 1
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 89
    Top = 36
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object seYear: TSpinEdit
    Left = 33
    Top = 8
    Width = 53
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 2021
  end
  object seMonth: TSpinEdit
    Left = 128
    Top = 8
    Width = 38
    Height = 22
    MaxValue = 12
    MinValue = 1
    TabOrder = 3
    Value = 12
  end
end
