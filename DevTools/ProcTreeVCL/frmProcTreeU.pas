unit frmProcTreeU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Winapi.TlHelp32,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function ProcIsRunning(AExeName: string): boolean;
    function FindMainWindow(PID: DWord): DWord;
    procedure ProcessEval(AProcEntry: TProcessEntry32);
    procedure LogMsg(AMessage: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

const
  DNLEN = 15;
  UNLEN = 256;

type
  PEnumInfo = ^TEnumInfo;

  TEnumInfo = record
    ProcessID: DWord;
    HWND: THandle;
  end;

{$R *.dfm}

function EnumWindowsProc(HWND: DWord; var einfo: TEnumInfo): BOOL; stdcall;
var
  PID: DWord;
  pw, wv, we, saw: boolean;
  style: Long_Ptr;
begin
  pw := false;
  wv := false;
  we := false;
  saw := false;
  // Get the Pid for the Window
  GetWindowThreadProcessId(HWND, @PID);
  result := PID = einfo.ProcessID;
  if result then // matched by PID
  begin // Inspect the window
    pw := GetParent(HWND) = 0;
    wv := IsWindowVisible(HWND);
    we := IsWindowEnabled(HWND);
    style := GetWindowLongPtr(HWND, GWL_EXSTYLE);
    if (Long_Ptr(style) and WS_EX_APPWINDOW) = WS_EX_APPWINDOW then
      saw := true;
    if pw and (wv or we) and saw then
    begin
      result := false;
      einfo.HWND := HWND; // set the handle
    end
    else
      result := true;
  end
  else
    result := true
    // EnumWindows continues until the last top-level window is enumerated or the callback function returns FALSE.
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ProcIsRunning(Edit1.Text);
end;

function TForm1.FindMainWindow(PID: DWord): DWord;
var
  einfo: TEnumInfo;
begin
  einfo.ProcessID := PID;
  einfo.HWND := 0;
  // for each window execute EnumWindows proc
  EnumWindows(@EnumWindowsProc, Integer(@einfo));
  result := einfo.HWND;
end;

procedure TForm1.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage)
end;

procedure TForm1.ProcessEval(AProcEntry: TProcessEntry32);
var
  mw: DWord;
  wtPID: Cardinal;
begin
  LogMsg(AProcEntry.th32ProcessID.ToString);
  mw := FindMainWindow(AProcEntry.th32ProcessID);
  try
    LogMsg('Handle =' + mw.ToString);
    LogMsg('Handle =' + mw.ToHexString);
    PostMessage(mw, WM_CLOSE, 0, 0);
  except
    on E: EOSError do
      LogMsg('Error : ' + IntToStr(E.ErrorCode) + E.Message);
  end;

end;

function TForm1.ProcIsRunning(AExeName: string): boolean;
var
  hSnapShot: THandle;
  PE: TProcessEntry32;
  tn: string;
begin
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    try
      tn := AExeName;
      if (hSnapShot <> THandle(-1)) then
      begin
        PE.dwSize := SizeOf(TProcessEntry32);
        if (Process32First(hSnapShot, PE)) then
          repeat // look for match by name
            if (PE.szExeFile = tn) then
              ProcessEval(PE);
          until (Process32Next(hSnapShot, PE) = false);
      end;
      result := true;
    except
      on E: Exception do
        raise Exception.Create('failed snapshot' + E.Message);
    end;
  finally
    CloseHandle(hSnapShot);
  end;

end;

end.
