program cut2G;

uses
  Forms,
  unitOptions in 'unitOptions.pas' {frmOptions},
  unitGlobals in 'unitGlobals.pas',
  unitMain in 'unitMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'cut2G';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
