object frmMain: TfrmMain
  Left = 878
  Top = 204
  BorderStyle = bsDialog
  Caption = 'Cut2G "GMFC to G-code Converter" v1.2'
  ClientHeight = 411
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 434
    Top = 392
    Width = 103
    Height = 16
    Alignment = taRightJustify
    Caption = '(c) G Sokoll, 2012'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label1Click
  end
  object cmdGo: TBitBtn
    Left = 255
    Top = 355
    Width = 100
    Height = 32
    Caption = 'Convert!'
    TabOrder = 0
    OnClick = cmdGoClick
    Layout = blGlyphTop
    NumGlyphs = 2
  end
  object GroupBox1: TGroupBox
    Left = 25
    Top = 25
    Width = 493
    Height = 81
    Caption = 'Input GMFC cut file'
    TabOrder = 1
    object cmdBrowseInput: TButton
      Left = 400
      Top = 37
      Width = 81
      Height = 26
      Caption = 'Browse...'
      TabOrder = 1
      OnClick = cmdBrowseInputClick
    end
    object txtCutFile: TEdit
      Left = 12
      Top = 37
      Width = 377
      Height = 24
      ReadOnly = True
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 25
    Top = 129
    Width = 493
    Height = 81
    Caption = 'Output G-code file'
    TabOrder = 2
    object cmdBrowseOutput: TButton
      Left = 400
      Top = 37
      Width = 81
      Height = 26
      Caption = 'Browse...'
      TabOrder = 1
      OnClick = cmdBrowseOutputClick
    end
    object txtGCodeFile: TEdit
      Left = 12
      Top = 37
      Width = 377
      Height = 24
      ReadOnly = True
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 25
    Top = 228
    Width = 493
    Height = 99
    Caption = 'Conversion Status'
    TabOrder = 3
    object lblStatus: TLabel
      Left = 18
      Top = 25
      Width = 457
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'Waiting for file selections...'
    end
    object ProgressBar1: TProgressBar
      Left = 18
      Top = 55
      Width = 457
      Height = 14
      TabOrder = 0
    end
  end
  object cmdOptions: TBitBtn
    Left = 101
    Top = 355
    Width = 100
    Height = 32
    Caption = 'Options...'
    TabOrder = 4
    OnClick = cmdOptionsClick
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = 'cut'
    Filter = 'CNCNet Cut files|*.cut|All files|*.*'
    Left = 10
    Top = 346
  end
  object dlgSaveFile: TSaveDialog
    DefaultExt = 'tap'
    Filter = 'G-Code tap files|*.tap|G-Code nc files|*.nc|All files|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofExtensionDifferent, ofEnableSizing]
    Left = 47
    Top = 346
  end
end
