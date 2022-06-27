unit frmDeputyUpdates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TDeputyUpdates = class(TForm)
    gpUpdates: TGridPanel;
    lblHdrItem: TLabel;
    lblHdrVerCurr: TLabel;
    lblHdrUpdate: TLabel;
    Memo1: TMemo;
    lblHdrVerAvail: TLabel;
    lblDeputy: TLabel;
    lblCaddie: TLabel;
    lblDemoFMX: TLabel;
    lblDemoVCL: TLabel;
    lblDeputyInst: TLabel;
    lblDeputyAvail: TLabel;
    Button1: TButton;
    lblCaddieInst: TLabel;
    lblCaddieAvail: TLabel;
    Button2: TButton;
    lblDemoFmxInst: TLabel;
    lblDemoFMXAvail: TLabel;
    Button3: TButton;
    lblDemoVCLInst: TLabel;
    lblDemoVCLAvail: TLabel;
    Button4: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DeputyUpdates: TDeputyUpdates;

implementation

{$R *.dfm}

end.
