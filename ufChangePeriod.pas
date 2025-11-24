unit ufChangePeriod;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXPickers, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TfChangePeriod = class(TForm)
    cbState: TComboBox;
    lDuration: TLabel;
    lStartDesc: TLabel;
    lStopDesc: TLabel;
    lStateDesc: TLabel;
    lDurationDesc: TLabel;
    bAccept: TButton;
    bCancel: TButton;
    lFirstOfDayDesc: TLabel;
    cbFirstOfDay: TCheckBox;
    dpStartDate: TDatePicker;
    lStartDateDesc: TLabel;
    tpStart: TDateTimePicker;
    tpStop: TDateTimePicker;
    procedure tpStartChange(Sender: TObject);
  public
    procedure UpdateDuration;
  end;

var
  fChangePeriod: TfChangePeriod;

implementation

{$R *.dfm}

procedure TfChangePeriod.tpStartChange(Sender: TObject);
begin
  UpdateDuration;
end;

procedure TfChangePeriod.UpdateDuration;
begin
  if tpStop.Time = 0 then
  begin
    if tpStart.Date = Date then
    begin
      lDuration.Caption := TimeToStr(Now - tpStart.Time);
    end
    else
    begin
      lDuration.Caption := '---';
    end;
  end
  else
  begin
    lDuration.Caption := TimeToStr(tpStop.Time - tpStart.Time);
  end;
end;

end.
