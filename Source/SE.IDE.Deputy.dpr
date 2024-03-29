library SE.IDE.Deputy;

{$R 'Icon.res' 'Resources\Icon.rc'}
{$I DW.LibSuffixIDE.inc}

uses
  System.SysUtils,
  System.Classes,
  SERTTK.DeputyTypes in 'SERTTK.DeputyTypes.pas',
  SERTTK.DeputyExpert in 'SERTTK.DeputyExpert.pas',
  frmDeputyProcMgr in 'frmDeputyProcMgr.pas' {DeputyProcMgr},
  frmDeputyUpdates in 'frmDeputyUpdates.pas' {DeputyUpdates},
  SE.UpdateManager in 'SE.UpdateManager.pas',
  SE.ProcMgrUtils in 'SE.ProcMgrUtils.pas',
  frmDeputyInstanceManager in 'frmDeputyInstanceManager.pas' {DeputyInstanceManager},
  frmDeputyOptionsInstance in 'frmDeputyOptionsInstance.pas' {frmDeputyOptInstance: TFrame},
  frmDeputyOptInstanceManager in 'frmDeputyOptInstanceManager.pas' {frmDeputyOptInstMgr: TFrame},
  frmDeputyOptUpdates in 'frmDeputyOptUpdates.pas' {frmDeputyOptUpdate: TFrame},
  frmDeputyOptProcessManager in 'frmDeputyOptProcessManager.pas' {frmDeputyOptProcMgr: TFrame};

{$R *.res}

begin

end.
