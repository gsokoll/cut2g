unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, Buttons, StrUtils, ComCtrls, Math, ShellApi;

type
  TfrmMain = class(TForm)
    cmdGo: TBitBtn;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    txtCutFile: TEdit;
    txtGCodeFile: TEdit;
    cmdBrowseInput: TButton;
    cmdBrowseOutput: TButton;
    dlgOpenFile: TOpenDialog;
    dlgSaveFile: TSaveDialog;
    GroupBox3: TGroupBox;
    ProgressBar1: TProgressBar;
    lblStatus: TLabel;
    cmdOptions: TBitBtn;
    Label1: TLabel;
    procedure cmdBrowseInputClick(Sender: TObject);
    procedure cmdBrowseOutputClick(Sender: TObject);
    procedure cmdGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdOptionsClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
    function feedrate(t, x1, y1, x2, y2: double):double;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  CutFileName, GCodeFileName: TFileName;
  FoamName: string;
  TableName: string;
  TINY_HEAT: double = 0.01;  // value of heat below which is assumed to be equal to zero
  TINY_TIME:double = 0.0001; // value of time step below which is assumed to be equal to zero
  TINY_STEP:double = 0.0001; // value of movement step below which is assumed to be equal to zero
  SAME_RATE: double = 0.005;  // percent change in feed rate below which is assumed to be same

const
  EXE_VERSION = '1.3';
  COMMENT_CHAR = '%% ';

implementation

uses
  unitGlobals, unitOptions;

{$R *.dfm}


procedure TfrmMain.cmdBrowseInputClick(Sender: TObject);
begin
  // call standard file open dialog
  if dlgOpenFile.Execute then
    begin
    CutFileName := dlgOpenFile.FileName;
    txtCutFile.Text := CutFileName;
    end;
  if (length(CutFileName) > 0) and (length(GCodeFileName) > 0) then
    begin
    cmdGo.Enabled := True;
    lblStatus.Caption := 'Ready for conversion...';
    end
  else
    cmdGo.Enabled := False;
end;

procedure TfrmMain.cmdBrowseOutputClick(Sender: TObject);
begin
  // call standard file save dialog
  if dlgSaveFile.Execute then
    begin
    GCodeFileName := dlgSaveFile.FileName;
    txtGCodeFile.Text := GCodeFileName;
    end;
  if (length(CutFileName) > 0) and (length(GCodeFileName) > 0) then
    begin
    cmdGo.Enabled := True;
    lblStatus.Caption := 'Ready for conversion...';
    end
  else
    cmdGo.Enabled := False;
end;


procedure TfrmMain.cmdGoClick(Sender: TObject);
var
  fhIn, fhOut: TextFile;
  sLine: string;
  IncludeComments, IncludeWireHeat: Boolean;
  i, n, code: integer;
  s, st, sh, s1, s2, s3, s4: string;
  dt, // time to traverse to this segment in seconds
  Ftime, // F value corresponding to G93 feed rate mode
  Frate, oFrate, // F value corresponding to G94 feed rate mode
  dh, // heat value for this segment
  xg, yg, xd, yd: double; // absolute vertex locations in mm
  oxg, oyg, oxd, oyd: double; // old values of vertex locations in mm
  sXG, sYG, sXD, sYD: string;
begin
    // open and parse cut file into cut list
    AssignFile(fhIn, CutFileName);
    AssignFile(fhOut, GCodeFileName);
    Reset(fhIn);
    Rewrite(fhOut);
    // output some basics
    IncludeComments := (frmOptions.rgComments.ItemIndex = 0);
    IncludeWireHeat := (frmOptions.rgWireHeat.ItemIndex = 0);
    if IncludeComments then
      begin
      WriteLn(fhOut, COMMENT_CHAR + 'G-Code prepared by cut2G, version ', EXE_VERSION);
      WriteLn(fhOut, COMMENT_CHAR + 'copyright G Sokoll 2012');
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET LENGTH UNITS');
      WriteLn(fhOut, COMMENT_CHAR + 'G20: INCHES');
      WriteLn(fhOut, COMMENT_CHAR + 'G21: MILLIMETERS');
      end;
    WriteLn(fhOut, UnitOption[1,frmOptions.rgUnits.ItemIndex]);
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET CUTTER COMPENSATION');
      WriteLn(fhOut, COMMENT_CHAR + 'G40: OFF');
      WriteLn(fhOut, COMMENT_CHAR + 'G41: ON LEFT');
      WriteLn(fhOut, COMMENT_CHAR + 'G42: ON RIGHT');
      end;
    WriteLn(fhOut, 'G40');
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET TOOL LENGTH OFFSET');
      WriteLn(fhOut, COMMENT_CHAR + 'G43: INDEX IN TOOL TABLE');
      WriteLn(fhOut, COMMENT_CHAR + 'G49: NO OFFSET');
      end;
    WriteLn(fhOut, 'G49');
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET PATH CONTROL MODE');
      WriteLn(fhOut, COMMENT_CHAR + 'G61: EXACT STOP');
      WriteLn(fhOut, COMMENT_CHAR + 'G64: CONSTANT VELOCITY');
      end;
    WriteLn(fhOut, PathOption[1,frmOptions.rgPathControl.ItemIndex]);
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET DISTANCE MODE');
      WriteLn(fhOut, COMMENT_CHAR + 'G90: ABSOLUTE');
      WriteLn(fhOut, COMMENT_CHAR + 'G91: INCREMENTAL');
      end;
    WriteLn(fhOut, 'G90');
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'SET FEED RATE MODE:');
      WriteLn(fhOut, COMMENT_CHAR + 'G93: INVERSE TIME MODE (MOVES PER MINUTE)');
      WriteLn(fhOut, COMMENT_CHAR + 'G94: UNITS PER MINUTE (PER SECOND ???)');
      WriteLn(fhOut, COMMENT_CHAR + 'G95: UNITS PER REV');
      end;
    WriteLn(fhOut, FeedOption[1,frmOptions.rgFeedRate.ItemIndex]);
    // set strings for axes naming
    if frmOptions.rgAxesNaming.ItemIndex = 0 then
      begin
      sXG := 'X';
      sYG := 'Y';
      sXD := 'A';
      sYD := 'B';
      end
    else
      begin
      sXG := 'X';
      sYG := 'Y';
      sXD := 'Z';
      sYD := 'A';
      end;
    if IncludeComments then
      begin
      WriteLn(fhOut, '');
      WriteLn(fhOut, COMMENT_CHAR + 'Axes Naming convention:');
      WriteLn(fhOut, COMMENT_CHAR + ' - Left hand axes = ' + sXG + ', ' + sYG);
      WriteLn(fhOut, COMMENT_CHAR + ' - Right hand axes = ' + sXD + ', ' + sYD);
      end;
    WriteLn(fhOut, '');
    n := 0;
    oxg := 0; oyg := 0; oxd := 0; oyd := 0;
    oFrate := -999; // flag that haven't calculated Frate before
    while not Eof(fhIn) do
      begin
      Readln(fhIn, sLine);
      Trim(sLine); // trims any leading or trailing spaces and control characters
      if not AnsiStartsStr('//',sLine) then // ignore comment lines
        begin
        if AnsiStartsText('F:',sLine) then // line start with F: or f:
          begin
          FoamName := sLine;
          Delete(FoamName, 1, 2);
          if IncludeComments then WriteLn(fhOut, COMMENT_CHAR + 'Foam: ', FoamName);
          end
        else
          if AnsiStartsText('N:', sLine) then // line start with N: or n:
            begin
            TableName := sLine;
            Delete(TableName, 1, 2);
            if IncludeComments then WriteLn(fhOut, COMMENT_CHAR + 'Table: ', TableName);
            end
          else
            if AnsiStartsText('Hw:', sLine) then // line start with Hw:
              begin
              sh := sLine;
              Delete(sh, 1, 3);
              dh := StrToFloat(sh);
              if IncludeWireHeat then
                begin
                if IncludeComments then WriteLn(fhOut, COMMENT_CHAR + 'Set wire heat using PWM spindle speed and turn on');
                if (dh > TINY_HEAT) then
                  begin
                  s := Format('S %10.7f M3', [dh])
                  end
                else
                  s := 'S0 M5';
                WriteLn(fhOut, s);
                end;
              end
            else
              if AnsiStartsText('T:', sLine) then // line starts with T: or t:
                begin
                inc(n);
                if (n mod 100) = 0 then
                  begin
                  if ProgressBar1.Position = ProgressBar1.Max then
                    ProgressBar1.Position := ProgressBar1.Min
                  else
                    ProgressBar1.StepIt;
                  end;
                // split sLine into five separate strings for t, xg, yg, xd, yd
                i := AnsiPos(' ', sLine);  // find position of first space
                st := AnsiLeftStr(sLine, i-1);
                Delete(sLine, 1, i); // delete previously processed item
                Trim(sLine); // delete any leading/trailing spaces
                i := AnsiPos(' ', sLine);  // find position of first space
                s1 := AnsiLeftStr(sLine, i-1);
                Delete(sLine, 1, i); // delete previously processed item
                Trim(sLine); // delete any leading/trailing spaces
                i := AnsiPos(' ', sLine);  // find position of first space
                s2 := AnsiLeftStr(sLine, i-1);
                Delete(sLine, 1, i); // delete previously processed item
                Trim(sLine); // delete any leading/trailing spaces
                i := AnsiPos(' ', sLine);  // find position of first space
                s3 := AnsiLeftStr(sLine, i-1);
                Delete(sLine, 1, i); // delete previously processed item
                Trim(sLine); // delete any leading/trailing spaces
                s4 := sLine;
                // assign xg, yg, xd, yd
                Delete(st, 1, 2); // delete T:
                if AnsiStartsText('XG:', s1) then Delete(s1, 1, 3);
                if AnsiStartsText('YG:', s2) then Delete(s2, 1, 3);
                if AnsiStartsText('XD:', s3) then Delete(s3, 1, 3);
                if AnsiStartsText('YD:', s4) then Delete(s4, 1, 3);
                Val(st, dt, code); // time is allowable time to traverse to this vertex from previous vertex
                Val(s1, xg, code); // but axis locations are absolute
                Val(s2, yg, code);
                Val(s3, xd, code);
                Val(s4, yd, code);
                // only process data if valid time step
                if (dt < TINY_TIME) then
                  ShowMessage('Vertex ' + inttostr(n) + ' ignored - time step too small.')
                else if (abs(xg - oxg) < TINY_STEP)
                and (abs(yg - oyg) < TINY_STEP)
                and (abs(xd - oxd) < TINY_STEP)
                and (abs(yd - oyd) < TINY_STEP) then // haven't moved, so use dwell command
                  begin
                  s := Format('G4 P %10.7f', [dt]);
                  WriteLn(fhOut, s);
                  end
                else // all ok, normal step
                  begin
                  Ftime := 60.0/dt;
                  Frate := max(feedrate(dt, oxg, oyg, xg, yg), feedrate(dt, oxd, oyd, xd, yd));
                  case frmOptions.rgFeedRate.ItemIndex of
                    0:   // Inverse Time
                      s := Format('F %10.7f G1 %s %10.7f %s %10.7f %s %10.7f %s %10.7f', [Ftime, sXG, xg, sYG, yg, sXD, xd, sYD, yd]);
                    1: // units per minute
                      begin
                      if (oFrate < -998) then oFrate := 0.1* Frate;
                      if (abs(Frate-oFrate)/oFrate > SAME_RATE) then
                        begin
                        oFrate := Frate;
                        s := Format('F %10.7f ', [Frate]);
                        WriteLn(fhOut, s);
                        end;
                      s := Format('G1 %s %10.7f %s %10.7f %s %10.7f %s %10.7f', [sXG, xg, sYG, yg, sXD, xd, sYD, yd]);
                      end;
                    end;
                  // output GCode info
                  WriteLn(fhOut, s);
                  oxg := xg; oyg := yg; oxd := xd; oyd := yd;
                  end;
                end; {end if line starts with t: or T:}
        end; {end if not AnsiStartsStr('//',sLine) then}
      end; {end while not Eof(fhIn)}
    if IncludeWireHeat then
      begin
      if IncludeComments then WriteLn(fhOut, COMMENT_CHAR + 'Turn off wire heat');
      WriteLn(fhOut, 'M5');
      end;
    // write closing line - just to be neat
    WriteLn(fhOut, COMMENT_CHAR + 'End of file.  Bye.');
    CloseFile(fhIn);
    CloseFile(fhOut);
    ProgressBar1.Position := ProgressBar1.Max;
    lblStatus.Caption := 'Conversion complete.';
    cmdGo.Enabled := False;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // disable conversion until both input and outputs have been selected
  cmdGo.Enabled := False;
end;

procedure TfrmMain.cmdOptionsClick(Sender: TObject);
begin
  frmOptions.ShowModal;

end;

// calculates feedrate in units per minute
function TfrmMain.feedrate(t, x1, y1, x2, y2: double):double;
var
  ds: double;
begin
  ds := sqrt(sqr(x2-x1)+sqr(y2-y1));
  feedrate := 60 * ds / t;
end;

procedure TfrmMain.Label1Click(Sender: TObject);
begin
    ShellExecute (0, nil, 'http://www.sokoll.net/doku.php/pastimes:rc:projects:cnc_foam_cutter:cut2g', nil, nil, SW_SHOWNORMAL);
end;

end.
