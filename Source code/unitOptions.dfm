object frmOptions: TfrmOptions
  Left = 959
  Top = 500
  Width = 479
  Height = 474
  Caption = 'Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object rgUnits: TRadioGroup
    Left = 31
    Top = 25
    Width = 187
    Height = 87
    Caption = 'Units'
    ItemIndex = 1
    Items.Strings = (
      'Inches'
      'Millimetres')
    TabOrder = 0
  end
  object rgPathControl: TRadioGroup
    Left = 257
    Top = 25
    Width = 187
    Height = 87
    Caption = 'Path Control Mode'
    ItemIndex = 1
    Items.Strings = (
      'Exact Stop'
      'Constant Velcoity')
    TabOrder = 1
  end
  object rgFeedRate: TRadioGroup
    Left = 31
    Top = 148
    Width = 187
    Height = 87
    Caption = 'Feed Rate Mode'
    ItemIndex = 1
    Items.Strings = (
      'Inverse Time'
      'Units per Minute')
    TabOrder = 2
  end
  object cmdOK: TBitBtn
    Left = 190
    Top = 390
    Width = 99
    Height = 32
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = cmdOKClick
  end
  object rgComments: TRadioGroup
    Left = 257
    Top = 148
    Width = 187
    Height = 87
    Caption = 'Comments in Output File'
    ItemIndex = 0
    Items.Strings = (
      'Include'
      'Exclude')
    TabOrder = 4
  end
  object rgWireHeat: TRadioGroup
    Left = 31
    Top = 266
    Width = 187
    Height = 87
    Caption = 'Wire Heat Control '
    ItemIndex = 0
    Items.Strings = (
      'Use spindle speed'
      'Don'#39't use')
    TabOrder = 5
  end
  object rgAxesNaming: TRadioGroup
    Left = 255
    Top = 266
    Width = 187
    Height = 87
    Caption = 'Axes Naming'
    ItemIndex = 0
    Items.Strings = (
      'LHS = XY, RHS = AB'
      'LHS = XY, RHS = ZA')
    TabOrder = 6
  end
end
