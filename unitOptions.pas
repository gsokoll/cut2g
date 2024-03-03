unit unitOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmOptions = class(TForm)
    rgUnits: TRadioGroup;
    rgPathControl: TRadioGroup;
    rgFeedRate: TRadioGroup;
    cmdOK: TBitBtn;
    rgComments: TRadioGroup;
    rgWireHeat: TRadioGroup;
    rgAxesNaming: TRadioGroup;
    procedure cmdOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.dfm}

procedure TfrmOptions.cmdOKClick(Sender: TObject);
begin
  Close;
end;

end.
