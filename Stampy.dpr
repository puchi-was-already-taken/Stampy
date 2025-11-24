program Stampy;

uses
  Vcl.Forms,
  ufStampy in 'ufStampy.pas' {fStampy},
  Vcl.Themes,
  Vcl.Styles,
  JclAppInst,
  Winapi.Windows,
  ufChangePeriod in 'ufChangePeriod.pas' {fChangePeriod},
  ufMonthSelection in 'ufMonthSelection.pas' {fMonthSelection};

{$R *.res}

begin
  if not JclAppInstances.CheckInstance(1) then
  begin
    JclAppInstances.UserNotify(SC_RESTORE);
    JclAppInstances.SwitchTo(0);
    JclAppInstances.KillInstance;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Golden Graphite');
  Application.CreateForm(TfStampy, fStampy);
  Application.CreateForm(TfChangePeriod, fChangePeriod);
  Application.CreateForm(TfMonthSelection, fMonthSelection);
  Application.Run;
end.
