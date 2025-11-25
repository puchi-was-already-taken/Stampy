unit ufStampy;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Generics.Collections, Vcl.Grids, Vcl.AppEvnts, System.Actions,
  Vcl.ActnList, Vcl.Menus, Vcl.ComCtrls, Vcl.Samples.Spin,
  FireDAC.Phys.SQLiteWrapper.Stat;

const
  WMRestoreFromTray = WM_USER + 1;

type
  THoursType = (htOnTime, htOffTime, htPause);
  TPunchMode = (pmAdvanced, pmSimple);

  TOption = class(TObject)
  strict private
    FKey: string;
    FValue: string;
    FEdit: TEdit;
    procedure SetValue(const Value: string);
    function GetEditText: string;
    procedure SetEditText(const Value: string);
  public
    constructor Create(const Key, Value: string; const Edit: TEdit); reintroduce;

    property Key: string read FKey;
    property Value: string read FValue write SetValue;
    property Edit: TEdit read FEdit;
    property EditText: string read GetEditText write SetEditText;
  end;

  TPeriod = class(TObject)
  strict private
    FState: THoursType;
    FStop: TDateTime;
    FStart: TDateTime;
    FId: Integer;
    FFirstOfDay: Boolean;
    function GetDuration: TDateTime;
  public
    constructor Create(const Id: Integer; const Start, Stop: TDateTime;
      const State: THoursType; const FirstOfDay: Boolean); overload;

    property Id: Integer read FId write FId;
    property Start: TDateTime read FStart write FStart;
    property Stop: TDateTime read FStop write FStop;
    property State: THoursType read FState write FState;
    property FirstOfDay: Boolean read FFirstOfDay write FFirstOfDay;
    property Duration: TDateTime read GetDuration;
  end;
  {
  Month                 | Work Time               | Pause Time
  KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
  Day             | Work Time               | Pause Time
  ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
  }
  TDay = class(TObject)
  strict private
    FDay: TDateTime;
    FWorkTime: TDateTime;
    FPauseTime: TDateTime;
  public
    constructor Create(const Periods: TObjectList<TPeriod>); overload;
    constructor Create(const Day, WorkTime, PauseTime: TDateTime); overload;

    property Day: TDateTime read FDay write FDay;
    property WorkTime: TDateTime read FWorkTime write FWorkTime;
    property PauseTime: TDateTime read FPauseTime write FPauseTime;
  end;

  TWeek = class(TObject)
  strict private
    FWeek: Integer;
    FEndDay: Integer;
    FWorkTime: TDateTime;
    FStartDay: Integer;
    FPauseTime: TDateTime;
    FWorkDays: Integer;
  public
    constructor Create(const Days: TObjectList<TDay>); overload;
    constructor Create(const Week, StartDay, EndDay, WorkDays: Integer;
      const WorkTime, PauseTime: TDateTime); overload;

    property Week: Integer read FWeek write FWeek;
    property StartDay: Integer read FStartDay write FStartDay;
    property EndDay: Integer read FEndDay write FEndDay;
    property WorkTime: TDateTime read FWorkTime write FWorkTime;
    property PauseTime: TDateTime read FPauseTime write FPauseTime;
    property WorkDays: Integer read FWorkDays write FWorkDays;
  end;

  TMonth = class(TObject)
  strict private
    FMonth: Integer;
    FEndDay: Integer;
    FWorkTime: TDateTime;
    FStartDay: Integer;
    FPauseTime: TDateTime;
    FWorkDays: Integer;
  public
    constructor Create(const Weeks: TObjectList<TWeek>); overload;
    constructor Create(const Month, StartDay, EndDay, WorkDays: Integer;
      const WorkTime, PauseTime: TDateTime); overload;

    property Month: Integer read FMonth write FMonth;
    property StartDay: Integer read FStartDay write FStartDay;
    property EndDay: Integer read FEndDay write FEndDay;
    property WorkTime: TDateTime read FWorkTime write FWorkTime;
    property PauseTime: TDateTime read FPauseTime write FPauseTime;
    property WorkDays: Integer read FWorkDays write FWorkDays;
  end;

  TfStampy = class(TForm)
    DB: TFDConnection;
    qInsertHours: TFDQuery;
    qFirstOfDay: TFDQuery;
    qLastTypeOfDay: TFDQuery;
    pButtons: TPanel;
    bStop: TButton;
    bPause: TButton;
    bStart: TButton;
    qOptions: TFDQuery;
    qReplaceOptions: TFDQuery;
    qTabelCount: TFDQuery;
    qDay: TFDQuery;
    UpdateTimer: TTimer;
    ApplicationEvents: TApplicationEvents;
    TrayIcon: TTrayIcon;
    ActionList: TActionList;
    pmTray: TPopupMenu;
    acStart: TAction;
    acStop: TAction;
    acPause: TAction;
    acSaveOptions: TAction;
    Start1: TMenuItem;
    Stop1: TMenuItem;
    Pause1: TMenuItem;
    acCloseApplication: TAction;
    CloseApplication1: TMenuItem;
    N1: TMenuItem;
    miHideRestore: TMenuItem;
    acRestore: TAction;
    N2: TMenuItem;
    acMinimize: TAction;
    pmPeriods: TPopupMenu;
    miChangePeriod: TMenuItem;
    qUpdateHours: TFDQuery;
    qDeleteHours: TFDQuery;
    miDeletePeriod: TMenuItem;
    pMain: TPanel;
    pCurrentDayStatistics: TPanel;
    lWorkTimeDesc: TLabel;
    lPauseTimeDesc: TLabel;
    lPauseTime: TLabel;
    lWorkTime: TLabel;
    lStatus: TLabel;
    pcMain: TPageControl;
    tsCurrentDay: TTabSheet;
    sgPeriods: TStringGrid;
    pCurrentDayTop: TPanel;
    lCurrentDay: TLabel;
    spCurrentDay: TSpinEdit;
    tsAnalysis: TTabSheet;
    sgAnalysis: TStringGrid;
    pAnalysisSelection: TPanel;
    lDomainCount: TLabel;
    seDomainCount: TSpinEdit;
    rgAnalysisMode: TRadioGroup;
    bLoadAnalysis: TButton;
    tsOptions: TTabSheet;
    lWorkDaysDesc: TLabel;
    lWeeklyHoursDesc: TLabel;
    bSaveOptions: TButton;
    eWeeklyHours: TEdit;
    eWeeklyWorkDays: TEdit;
    bSwitchMode: TButton;
    acSwitchMode: TAction;
    qReport: TFDQuery;
    eStdPauseDuration: TEdit;
    lStdPauseDuration: TLabel;
    ShutDownTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBBeforeDisconnect(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure acStartExecute(Sender: TObject);
    procedure acStopExecute(Sender: TObject);
    procedure acPauseExecute(Sender: TObject);
    procedure acSaveOptionsExecute(Sender: TObject);
    procedure acCloseApplicationExecute(Sender: TObject);
    procedure acRestoreExecute(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure acMinimizeExecute(Sender: TObject);
    procedure TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure miChangePeriodClick(Sender: TObject);
    procedure miDeletePeriodClick(Sender: TObject);
    procedure bLoadAnalysisClick(Sender: TObject);
    procedure spCurrentDayChange(Sender: TObject);
    procedure sgPeriodsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgPeriodsDblClick(Sender: TObject);
    procedure ApplicationEventsRestore(Sender: TObject);
    procedure acSwitchModeExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ShutDownTimerTimer(Sender: TObject);
  private
    FOptions: TObjectList<TOption>;
    FCurrentDay: TObjectList<TPeriod>;
    FLastPeriod: TPeriod;
    FWorkTime: TDateTime;
    FPauseTime: TDateTime;
    FUpdateCounter: Integer;
    FShuttingDown: Boolean;
    FLastUpdateTimers: TDateTime;
    FHiddenInTray: Boolean;
    FInCurrentDayChange: Boolean;
    FCurrentMode: TPunchMode;
    FWidth: Integer;
    FHeight: Integer;
    FpButtonsWidth: Integer;
    FLastReportFile: string;

    procedure InsertHours(const Day: Integer; const TimeStamp: TDateTime;
      const FirstOfDay: Boolean; const HoursType: THoursType;
      const Note: string); overload;
    procedure InsertHours(const HoursType: THoursType;
      const Note: string = ''); overload;
    procedure InsertFirstOfDay;
    function ExistsFirstOfDay(const Day: Integer): Boolean;
    function NewLastType(const Day: Integer; const HoursType: THoursType): Boolean;
    procedure CloseDay(const Day: Integer); overload;
    procedure CloseDay; overload;
    procedure SaveOptions;
    procedure SaveOption(const Key: string; const Value: string);
    procedure LoadOptions;
    procedure InitOptions;
    function OptionIndex(const Key: string): Integer;
    procedure OpenDB;
    procedure CreateDB;
    procedure LoadDay(const Day: Integer; const Periods: TObjectList<TPeriod>);
    procedure LoadWeek(const DayInWeek: Integer; const Days: TObjectList<TDay>); overload;
    procedure LoadWeek(const DayInWeek, MinStartDay, MaxEndDay: Integer; const Days:
      TObjectList<TDay>); overload;
    procedure LoadMonth(const DayInMonth: Integer; const Weeks: TObjectList<TWeek>);
    procedure AnalyseToday;
    procedure PrintPeriods(const Periods: TObjectList<TPeriod>;
      const StringGrid: TStringGrid);
    procedure UpdateTimers;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure CurrentDayStatistics;
    procedure AddPeriodToCurrentDay(const Period: TPeriod);
    procedure UpdatePeriod(const Period: TPeriod);
    procedure DeletePeriod(const Period: TPeriod);
    procedure Refresh;
    procedure PrintWeeks(const Weeks: TObjectList < TObjectList<TDay> > ;
      const StringGrid: TStringGrid);
    procedure PrintMonths(const Months: TObjectList < TObjectList<TWeek> > ;
      const StringGrid: TStringGrid);
    procedure AnalyseWeeks(const StartDay, WeekCount: Integer; const Weeks: TObjectList <
      TObjectList<TDay> > );
    procedure WeeksStatistics(const StartDay, WeekCount: Integer);
    procedure AnalyseMonths(const StartDay, MonthCount: Integer; const Months: TObjectList <
      TObjectList<TWeek> > );
    procedure MonthsStatistics(const StartDay, MonthCount: Integer);
    procedure ChangePeriod;
    procedure Restore;
    function GetWeeklyHours: Integer;
    function GetWeeklyWorkDays: Integer;
    function GetStdPauseDuration: Integer;
    procedure SetMode(const ModeName: string); overload;
    procedure SetMode(const NewMode: TPunchMode); overload;
    procedure SwitchMode;
    procedure MinimizeToTray;
    function GetCurrentDayDateTime: TDateTime;
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QueryEndSession;
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

var
  fStampy: TfStampy;

implementation

uses
  ufChangePeriod, DateUtils, Math, JclAppInst, ufMonthSelection;

const
  HoursTypeNames: array[THoursType] of string = ('On-Time', 'Off-Time', 'Pause');
  ModeNames: array[TPunchMode] of string = ('Advanced', 'Simple');
  PunchModeOptionName = 'PunchMode';
  LastReportFile = 'LastReportFile';

type
  TColWidths = array of Integer;

{$R *.dfm}

function ShutdownBlockReasonCreate(hWnd: HWND; pwszReason: LPCWSTR): Bool; stdcall; external user32;

function ShutdownBlockReasonDestroy(hWnd: HWND): Bool; stdcall; external user32;

procedure AnalyseDay(
  const Periods: TObjectList<TPeriod>; out WorkTime, PauseTime: TDateTime);
var
  I: Integer;
begin
  WorkTime := 0;
  PauseTime := 0;

  for I := 0 to Periods.Count - 1 do
  begin
    if Periods[I].Stop > 0 then
    begin
      case Periods[I].State of
        htOnTime: WorkTime := WorkTime + Periods[I].Duration;
        htOffTime: ; // Nichts tun.
        htPause: PauseTime := PauseTime + Periods[I].Duration;
      end;
    end;
  end;
end;

function AddRow(const Grid: TStringGrid): Integer;
begin
  Result := Grid.RowCount;
  Grid.RowCount := Result + 1;

  Grid.Rows[Result].Clear;
end;

procedure ProcessColWidths(const Grid: TStringGrid; const Row: Integer;
  var MaxColWidths: TColWidths);
var
  I: Integer;
begin
  for I := 0 to Grid.Rows[Row].Count - 1 do
  begin
    MaxColWidths[I] := Max(MaxColWidths[I], Grid.Canvas.TextWidth(Grid.Rows[Row][I]));
  end;
end;

procedure AdjustColWidths(const Grid: TStringGrid; const ColWidths: TColWidths);
var
  I: Integer;
begin
  for I := 0 to Grid.ColCount - 1 do
  begin
    Grid.ColWidths[I] := ColWidths[I] + 10;
  end;
end;

procedure AdjustColWidthsAndFixedRow(const Grid: TStringGrid;
  const ColWidths: TColWidths; const FixedRows: Integer);
begin
  AdjustColWidths(Grid, ColWidths);

  if Grid.RowCount < FixedRows then
  begin
    Grid.FixedRows := FixedRows;
  end;
end;

function TotalAvgString(TotalHours, AvgHours: Double; AltAvgHours: Double = 0): string;
var
  Sign: string;
begin
  if TotalHours < 0 then
  begin
    Sign := '-';
  end
  else
  begin
    Sign := '';
  end;

  TotalHours := Abs(TotalHours);
  AvgHours := Abs(AvgHours);
  AltAvgHours := Abs(AltAvgHours);

  if AltAvgHours = 0 then
  begin
    Result := Format('%s%.2d:%.2d (Ø %s%.2d:%.2d)', [Sign, Trunc(TotalHours), Round(Frac(TotalHours)
          * 60),
        Sign, Trunc(AvgHours), Round(Frac(AvgHours) * 60)]);
  end
  else
  begin
    Result := Format('%s%.2d:%.2d (Ø %s%.2d:%.2d | %s%.2d:%.2d)', [Sign, Trunc(TotalHours),
        Round(Frac(TotalHours) * 60),
        Sign, Trunc(AvgHours), Round(Frac(AvgHours) * 60),
        Sign, Trunc(AltAvgHours), Round(Frac(AltAvgHours) * 60)]);
  end;
end;

function TotalTimeToStr(const DateTime: TDateTime): string;
var
  Sign: string;
  TotalHours, Minutes, Seconds: Integer;
begin
  if DateTime < 0 then
  begin
    Sign := '-';
  end
  else
  begin
    Sign := '';
  end;

  TotalHours := Trunc(Abs(DateTime) * 24);
  Minutes := Trunc(Frac(Abs(DateTime) * 24) * 60);
  Seconds := Round(Frac(Abs(DateTime) * 24 * 60) * 60);

  Result := Format('%s%.2d:%.2d:%.2d', [Sign, TotalHours, Minutes, Seconds]);
end;

function BaseDiffString(BaseTime, SubtrahendTime: TDateTime): string;
begin
  Result := TotalTimeToStr(BaseTime) + ' ( ' + TotalTimeToStr(BaseTime - SubtrahendTime) + ' )';
end;

procedure TfStampy.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FShuttingDown or (FCurrentMode <> pmSimple) then
  begin
    try
      SaveOptions;
    except
    end;

    try
      CloseDay;
    except
    end;
  end
  else
  begin
    Action := caNone;
    MinimizeToTray;
  end;
end;

procedure TfStampy.FormCreate(Sender: TObject);
begin
  FOptions := TObjectList<TOption>.Create(True);
  InitOptions;

  FCurrentDay := TObjectList<TPeriod>.Create(True);

  OpenDB;

  InsertFirstOfDay;
  Refresh;
end;

procedure TfStampy.FormDestroy(Sender: TObject);
begin
  //  SaveOptions;
  //  CloseDay; // Das ist hier buggy... k.A. warum (qLastTypeOfDay.EOF ist immer True)
  try
    DB.Close;
  except
  end;

  FCurrentDay.Free;
  FOptions.Free;

  try
    TrayIcon.Visible := False;
  except
  end;
end;

function TfStampy.GetCurrentDayDateTime: TDateTime;
begin
  Result := Now;

  if FCurrentMode = pmAdvanced then
  begin
    Result := Result + spCurrentDay.Value;
  end;
end;

function TfStampy.GetStdPauseDuration: Integer;
begin
  Result := StrToIntDef(eStdPauseDuration.Text, 0);

  if Result <= 0 then
  begin
    Result := 45;
  end;
end;

function TfStampy.GetWeeklyHours: Integer;
begin
  Result := StrToIntDef(eWeeklyHours.Text, 0);

  if Result <= 0 then
  begin
    Result := 40;
  end;
end;

function TfStampy.GetWeeklyWorkDays: Integer;
begin
  Result := StrToIntDef(eWeeklyWorkDays.Text, 0);

  if Result <= 0 then
  begin
    Result := 5;
  end;
end;

procedure TfStampy.InitOptions;
begin
  FOptions.Add(TOption.Create('WeeklyHours', '', eWeeklyHours));
  FOptions.Add(TOption.Create('WorkDays', '', eWeeklyWorkDays));
  FOptions.Add(TOption.Create('StdPauseDuration', '', eStdPauseDuration));
end;

procedure TfStampy.InsertFirstOfDay;
var
  Today: Integer;
  StartupDateTime: TDateTime;
begin
  Today := Trunc(Date);

  if ExistsFirstOfDay(Today) then
  begin
    Exit;
  end;

  // Startup time rounded to minutes.
  StartupDateTime := Now - GetTickCount64 / 24 / 60 / 60 / 1000;

  if Trunc(StartupDateTime) <> Today then
  begin
    StartupDateTime := Now;
  end;

  InsertHours(Today, StartupDateTime, True, htOnTime, 'Application Starting');
end;

procedure TfStampy.InsertHours(const HoursType: THoursType;
  const Note: string = '');
begin
  InsertHours(Trunc(GetCurrentDayDateTime), GetCurrentDayDateTime, False, HoursType, Note);
end;

procedure TfStampy.InsertHours(const Day: Integer; const TimeStamp: TDateTime;
  const FirstOfDay: Boolean; const HoursType: THoursType; const Note: string);
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  if not (FirstOfDay or NewLastType(Day, HoursType)) then
  begin
    Exit;
  end;

  qInsertHours.ParamByName('Day').AsInteger := Day;
  qInsertHours.ParamByName('TimeStamp').AsFloat := TimeStamp;
  qInsertHours.ParamByName('FirstOfDay').AsInteger := Integer(FirstOfDay);
  qInsertHours.ParamByName('Type').AsInteger := Integer(HoursType);
  qInsertHours.ParamByName('Note').AsString := Note;

  qInsertHours.ExecSQL;

  if not FShuttingDown then
  begin
    AddPeriodToCurrentDay(
      TPeriod.Create(qInsertHours.Connection.GetLastAutoGenValue(''), TimeStamp, 0, HoursType,
      FirstOfDay));
    CurrentDayStatistics;
  end;
end;

procedure TfStampy.LoadOptions;
var
  Index: Integer;
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  qOptions.Open;

  while not qOptions.Eof do
  begin
    try
      if qOptions.FieldByName('Key').AsString = PunchModeOptionName then
      begin
        SetMode(qOptions.FieldByName('Value').AsString);
        Continue;
      end;

      if qOptions.FieldByName('Key').AsString = LastReportFile then
      begin
        FLastReportFile := qOptions.FieldByName('Value').AsString;
        Continue;
      end;

      Index := OptionIndex(qOptions.FieldByName('Key').AsString);
      if Index > -1 then
      begin
        FOptions[Index].Value := qOptions.FieldByName('Value').AsString;
        FOptions[Index].Edit.Text := FOptions[Index].Value;
      end;

    finally
      qOptions.Next;
    end;
  end;

  qOptions.Close;
end;

procedure TfStampy.LoadWeek(const DayInWeek, MinStartDay,
  MaxEndDay: Integer; const Days: TObjectList<TDay>);
var
  Periods: TObjectList<TPeriod>;
  StartDay, EndDay: Integer;
  I: Integer;
begin
  Days.Clear;

  Periods := TObjectList<TPeriod>.Create(True);
  try
    StartDay := Max(Trunc(StartOfTheWeek(DayInWeek)), MinStartDay);
    EndDay := Min(Trunc(EndOfTheWeek(DayInWeek)), MaxEndDay);

    for I := StartDay to EndDay do
    begin
      LoadDay(I, Periods);

      if (Periods.Count > 0) and not ((I = Date) and (Periods.Last.State <> htOffTime)) then
      begin
        Days.Add(TDay.Create(Periods));
      end;
    end;
  finally
    Periods.Free;
  end;
end;

procedure TfStampy.LoadWeek(const DayInWeek: Integer;
  const Days: TObjectList<TDay>);
begin
  LoadWeek(DayInWeek, Trunc(StartOfTheWeek(DayInWeek)), Trunc(EndOfTheWeek(DayInWeek)), Days);
end;

procedure TfStampy.miChangePeriodClick(Sender: TObject);
begin
  ChangePeriod;
end;

procedure TfStampy.ChangePeriod;
var
  Period: TPeriod;
  ChangePeriod: TfChangePeriod;
  State: string;
begin
  if (FCurrentDay.Count > 0) and (sgPeriods.Row > 0) and (FCurrentDay.Count >= sgPeriods.Row) then
  begin
    Period := FCurrentDay[sgPeriods.Row - 1];

    ChangePeriod := TfChangePeriod.Create(nil);
    try
      for State in HoursTypeNames do
      begin
        ChangePeriod.cbState.Items.Add(State);
      end;

      ChangePeriod.cbState.ItemIndex := Integer(Period.State);
      ChangePeriod.dpStartDate.Date := Trunc(Period.Start);
      ChangePeriod.tpStart.DateTime := Period.Start;
      ChangePeriod.tpStop.DateTime := Period.Stop;
      ChangePeriod.UpdateDuration;
      ChangePeriod.cbFirstOfDay.Checked := Period.FirstOfDay;

      if ChangePeriod.ShowModal = mrOk then
      begin
        Period.State := THoursType(ChangePeriod.cbState.ItemIndex);
        Period.Start := ChangePeriod.dpStartDate.Date + ChangePeriod.tpStart.Time;
        Period.FirstOfDay := ChangePeriod.cbFirstOfDay.Checked;
      end;

      UpdatePeriod(Period);

    finally
      ChangePeriod.Free;
    end;
  end;
end;

procedure TfStampy.miDeletePeriodClick(Sender: TObject);
begin
  if (FCurrentDay.Count > 0) and (sgPeriods.Row > 0) and (FCurrentDay.Count >= sgPeriods.Row) then
  begin
    DeletePeriod(FCurrentDay[sgPeriods.Row - 1]);
  end;
end;

procedure TfStampy.MinimizeToTray;
begin
  UpdateTimer.Enabled := False;

  Application.Minimize;
  Application.MainForm.Visible := False;

  FHiddenInTray := True;
  miHideRestore.Action := acRestore;
end;

procedure TfStampy.MonthsStatistics(const StartDay,
  MonthCount: Integer);
var
  Months: TObjectList<TObjectList<TWeek>>;
begin
  Months := TObjectList < TObjectList<TWeek> > .Create(True);
  try
    AnalyseMonths(StartDay, MonthCount, Months);
    PrintMonths(Months, sgAnalysis);
  finally
    Months.Free;
  end;
end;

function TfStampy.NewLastType(const Day: Integer;
  const HoursType: THoursType): Boolean;
begin
  if not DB.Connected then
  begin
    Result := False;
    Exit;
  end;

  qLastTypeOfDay.ParamByName('Day').AsInteger := Day;
  qLastTypeOfDay.Open;

  Result := (qLastTypeOfDay.Bof and qLastTypeOfDay.Eof) or (qLastTypeOfDay.Fields[0].AsInteger <>
    Integer(HoursType));

  qLastTypeOfDay.Close;
end;

procedure TfStampy.OpenDB;
begin
  DB.Params.Database := ExtractFilePath(Application.ExeName) + 'StampyWorkingHours.sqlite3';
  DB.Open;

  if not DB.Connected then
  begin
    Exit;
  end;

  qTabelCount.Open;
  if qTabelCount.Fields[0].AsInteger = 0 then
  begin
    CreateDB;
  end;
  qTabelCount.Close;
end;

function TfStampy.OptionIndex(const Key: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FOptions.Count - 1 do
  begin
    if FOptions[I].Key = Key then
    begin
      Result := I;
      Exit;
    end;
  end;

  Result := -1;
end;

procedure TfStampy.PrintPeriods(
  const Periods: TObjectList<TPeriod>; const StringGrid: TStringGrid);
var
  I: Integer;
  ColWidths: TColWidths;
  Period: TPeriod;
begin
  if Periods.Count > 0 then
  begin
    lCurrentDay.Caption := FormatDateTime('dddddd', Periods.First.Start);
  end;

  StringGrid.RowCount := 1;
  StringGrid.ColCount := 4;

  SetLength(ColWidths, StringGrid.ColCount);

  StringGrid.Rows[0].Clear;
  StringGrid.Rows[0][0] := 'State';
  StringGrid.Rows[0][1] := 'Start';
  StringGrid.Rows[0][2] := 'Stop';
  StringGrid.Rows[0][3] := 'Duration';

  ProcessColWidths(StringGrid, 0, ColWidths);

  for Period in Periods do
  begin
    I := AddRow(StringGrid);

    StringGrid.Rows[I].Clear;
    StringGrid.Rows[I][0] := HoursTypeNames[Period.State];
    StringGrid.Rows[I][1] := FormatDateTime('dd.mm. hh:nn:ss', Period.Start);

    if Period.Stop = 0 then
    begin
      StringGrid.Rows[I][2] := '---';
      StringGrid.Rows[I][3] := '---';
    end
    else
    begin
      StringGrid.Rows[I][2] := FormatDateTime('dd.mm. hh:nn:ss', Period.Stop);
      StringGrid.Rows[I][3] := TotalTimeToStr(Period.Duration);
    end;

    ProcessColWidths(StringGrid, I, ColWidths);
  end;

  StringGrid.TopRow := StringGrid.RowCount - StringGrid.VisibleRowCount;

  if Periods.Count > 0 then
  begin
    AdjustColWidthsAndFixedRow(StringGrid, ColWidths, 0);
  end;
end;

{
Mode: Week:
Day             | Work Time               | Pause Time
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
Summary:        | [hh]:nn (avg: [hh]:nn)  | [hh]:nn (avg: [hh]:nn)
.
.
.
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
ddd. dd.mm.yyyy | [hh]:nn                 | [hh]:nn
Summary:        | [hh]:nn (Ø: [hh]:nn)  | [hh]:nn (Ø: [hh]:nn)
}
procedure TfStampy.PrintWeeks(
  const Weeks: TObjectList < TObjectList<TDay> > ; const StringGrid: TStringGrid);
var
  WeeklyHours, WeeklyWorkDays, WeekWorkDays, PauseDuration, Index: Integer;
  Week: TObjectList<TDay>;
  Day: TDay;
  WeekSummary: TWeek;
  ColWidths: TColWidths;
  WeekWorkTime, WeekPauseTime: TDateTime;
  QuotaWorkTime, QuotaPauseTime, DeltaWorkTime, DeltaPauseTime: Double;
begin
  WeeklyHours := GetWeeklyHours;
  WeeklyWorkDays := GetWeeklyWorkDays;
  PauseDuration := GetStdPauseDuration;

  StringGrid.RowCount := 1;
  StringGrid.ColCount := 3;

  SetLength(ColWidths, StringGrid.ColCount);

  StringGrid.Rows[0].Clear;
  StringGrid.Rows[0][0] := 'Day';
  StringGrid.Rows[0][1] := 'Work Time';
  StringGrid.Rows[0][2] := 'Pause Time';

  ProcessColWidths(StringGrid, 0, ColWidths);

  for Week in Weeks do
  begin
    WeekSummary := TWeek.Create(Week);
    try
      WeekWorkTime := WeekSummary.WorkTime * 24;
      WeekPauseTime := WeekSummary.PauseTime * 24;
      WeekWorkDays := WeekSummary.WorkDays;
    finally
      WeekSummary.Free;
    end;

    for Day in Week do
    begin
      Index := AddRow(StringGrid);

      StringGrid.Rows[Index][0] := FormatDateTime('ddd. dd.mm.yyyy', Day.Day);
      StringGrid.Rows[Index][1] := BaseDiffString(Day.WorkTime, WeeklyHours / 24 / WeeklyWorkDays);
      StringGrid.Rows[Index][2] := BaseDiffString(Day.PauseTime, PauseDuration / 24 / 60);

      ProcessColWidths(StringGrid, Index, ColWidths);
    end;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Summary:';
    if WeekWorkDays = 0 then
    begin
      StringGrid.Rows[Index][1] := TotalAvgString(WeekWorkTime, WeekWorkTime);
      StringGrid.Rows[Index][2] := TotalAvgString(WeekPauseTime, WeekPauseTime);
    end
    else
    begin
      StringGrid.Rows[Index][1] := TotalAvgString(WeekWorkTime, WeekWorkTime / WeekWorkDays);
      StringGrid.Rows[Index][2] := TotalAvgString(WeekPauseTime, WeekPauseTime / WeekWorkDays);
    end;

    ProcessColWidths(StringGrid, Index, ColWidths);

    QuotaWorkTime := WeeklyHours / WeeklyWorkDays * Week.Count;
    QuotaPauseTime := PauseDuration / 60 * Week.Count;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Quota:';
    StringGrid.Rows[Index][1] := TotalAvgString(QuotaWorkTime, WeeklyHours / WeeklyWorkDays);
    StringGrid.Rows[Index][2] := TotalAvgString(QuotaPauseTime, PauseDuration / 60);

    ProcessColWidths(StringGrid, Index, ColWidths);

    DeltaWorkTime := WeekWorkTime - QuotaWorkTime;
    DeltaPauseTime := WeekPauseTime - QuotaPauseTime;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Difference:';
    StringGrid.Rows[Index][1] := TotalAvgString(DeltaWorkTime, DeltaWorkTime / WeeklyWorkDays);
    StringGrid.Rows[Index][2] := TotalAvgString(DeltaPauseTime, DeltaPauseTime / WeeklyWorkDays);

    ProcessColWidths(StringGrid, Index, ColWidths);
  end;

  AdjustColWidthsAndFixedRow(StringGrid, ColWidths, 1);
end;

{
Month                 | Work Time               | Pause Time
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
Summary:              | [hh]:nn (avg: [hh]:nn)  | [hh]:nn (avg: [hh]:nn)
.
.
.
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
KW XX dd.mm. - dd.mm. | [hh]:nn                 | [hh]:nn
Summary:              | [hh]:nn (avg: [hh]:nn)  | [hh]:nn (avg: [hh]:nn)
}
procedure TfStampy.PrintMonths(
  const Months: TObjectList < TObjectList<TWeek> > ; const StringGrid: TStringGrid);
var
  ColWidths: TColWidths;
  Month: TObjectList<TWeek>;
  Week: TWeek;
  WeeklyHours, WeeklyWorkDays, PauseDuration, Index: Integer;
  MonthSummary: TMonth;
  MonthWorkTime, MonthPauseTime, QuotaWorkTime, QuotaPauseTime, DeltaWorkTime,
    DeltaPauseTime: TDateTime;
  MonthWorkDays: Integer;
begin
  WeeklyHours := GetWeeklyHours;
  WeeklyWorkDays := GetWeeklyWorkDays;
  PauseDuration := GetStdPauseDuration;

  StringGrid.RowCount := 1;
  StringGrid.ColCount := 3;

  SetLength(ColWidths, StringGrid.ColCount);

  StringGrid.Rows[0].Clear;
  StringGrid.Rows[0][0] := 'Week';
  StringGrid.Rows[0][1] := 'Work Time';
  StringGrid.Rows[0][2] := 'Pause Time';

  ProcessColWidths(StringGrid, 0, ColWidths);

  for Month in Months do
  begin
    MonthSummary := TMonth.Create(Month);
    try
      MonthWorkTime := MonthSummary.WorkTime * 24;
      MonthPauseTime := MonthSummary.PauseTime * 24;
      MonthWorkDays := Max(1, MonthSummary.WorkDays);
    finally
      MonthSummary.Free;
    end;

    for Week in Month do
    begin
      Index := StringGrid.RowCount;
      StringGrid.RowCount := Index + 1;

      StringGrid.Rows[Index][0] := 'KW ' + IntToStr(Week.Week).PadLeft(2, '0')
      + ' ' + FormatDateTime('dd.mm.', Week.StartDay) + ' - ' + FormatDateTime('dd.mm.',
        Week.EndDay);
      StringGrid.Rows[Index][1] := BaseDiffString(Week.WorkTime, WeeklyHours / 24 / WeeklyWorkDays *
        Week.WorkDays);
      StringGrid.Rows[Index][2] := BaseDiffString(Week.PauseTime, PauseDuration / 24 / 60 *
        Week.WorkDays);

      ProcessColWidths(StringGrid, Index, ColWidths);
    end;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Summary:';
    StringGrid.Rows[Index][1] := TotalAvgString(MonthWorkTime, MonthWorkTime / MonthWorkDays,
      MonthWorkTime / MonthWorkDays * WeeklyWorkDays);
    StringGrid.Rows[Index][2] := TotalAvgString(MonthPauseTime, MonthPauseTime / MonthWorkDays,
      MonthPauseTime / MonthWorkDays * WeeklyWorkDays);

    ProcessColWidths(StringGrid, Index, ColWidths);

    QuotaWorkTime := WeeklyHours / WeeklyWorkDays * MonthWorkDays;
    QuotaPauseTime := PauseDuration / 60 * MonthWorkDays;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Quota:';
    StringGrid.Rows[Index][1] := TotalAvgString(QuotaWorkTime, WeeklyHours / WeeklyWorkDays,
      WeeklyHours / WeeklyWorkDays * WeeklyWorkDays);
    StringGrid.Rows[Index][2] := TotalAvgString(QuotaPauseTime, PauseDuration / 60, PauseDuration /
      60 * WeeklyWorkDays);

    ProcessColWidths(StringGrid, Index, ColWidths);

    DeltaWorkTime := MonthWorkTime - QuotaWorkTime;
    DeltaPauseTime := MonthPauseTime - QuotaPauseTime;

    Index := AddRow(StringGrid);
    StringGrid.Rows[Index][0] := 'Difference:';
    StringGrid.Rows[Index][1] := TotalAvgString(DeltaWorkTime, DeltaWorkTime / WeeklyWorkDays,
      DeltaWorkTime / WeeklyWorkDays * WeeklyWorkDays);
    StringGrid.Rows[Index][2] := TotalAvgString(DeltaPauseTime, DeltaPauseTime / WeeklyWorkDays,
      DeltaPauseTime / WeeklyWorkDays * WeeklyWorkDays);

    ProcessColWidths(StringGrid, Index, ColWidths);
  end;

  AdjustColWidthsAndFixedRow(StringGrid, ColWidths, 1);
end;

procedure TfStampy.Refresh;
begin
  LoadOptions;
  LoadDay(Trunc(Date) + spCurrentDay.Value, FCurrentDay);
  CurrentDayStatistics;
end;

procedure TfStampy.Restore;
begin
  if FHiddenInTray then
  begin
    acRestore.Execute;
  end;
end;

procedure TfStampy.SaveOption(const Key, Value: string);
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  qReplaceOptions.ParamByName('Key').AsString := Key;
  qReplaceOptions.ParamByName('Value').AsString := Value;

  qReplaceOptions.ExecSQL;
end;

procedure TfStampy.SaveOptions;
var
  I: Integer;
begin
  for I := 0 to FOptions.Count - 1 do
  begin
    if FOptions[I].Value <> FOptions[I].Edit.Text then
    begin
      FOptions[I].Value := FOptions[I].Edit.Text;
      SaveOption(FOptions[I].Key, FOptions[I].Value);
    end;
  end;
end;

procedure TfStampy.SetMode(const NewMode: TPunchMode);
begin
  if NewMode = FCurrentMode then
  begin
    Exit;
  end;

  case NewMode of
    pmSimple:
      begin
        UpdateTimer.Enabled := False;

        FpButtonsWidth := pButtons.Width;
        FWidth := Width;
        FHeight := Height;

        Width := Width - pMain.Width;
        Height := Height + (bPause.Top - bStop.Top);

        pMain.Visible := False;
        bPause.Visible := False;

        pButtons.Align := alClient;

        BorderStyle := bsDialog;
      end;

    pmAdvanced:
      begin
        BorderStyle := bsSizeable;

        pButtons.Align := alLeft;
        pButtons.Width := FpButtonsWidth;

        Width := FWidth;
        Height := FHeight;

        pMain.Visible := True;
        bPause.Visible := True;

        UpdateTimer.Enabled := True;
      end;
  end;

  FCurrentMode := NewMode;
  SaveOption(PunchModeOptionName, ModeNames[FCurrentMode]);
end;

procedure TfStampy.SetMode(const ModeName: string);
var
  Mode: TPunchMode;
begin
  for Mode := Low(TPunchMode) to High(TPunchMode) do
  begin
    if ModeName = ModeNames[Mode] then
    begin
      SetMode(Mode);
      Exit;
    end;
  end;
end;

procedure TfStampy.sgPeriodsDblClick(Sender: TObject);
begin
  ChangePeriod;
end;

procedure TfStampy.sgPeriodsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  if Button = mbRight then
  begin
    sgPeriods.MouseToCell(X, Y, Col, Row);
    sgPeriods.Col := Col;
    sgPeriods.Row := Row;
  end;

  inherited;
end;

procedure TfStampy.ShutDownTimerTimer(Sender: TObject);
begin
  ShutDownTimer.Enabled := False;

  ShutdownBlockReasonCreate(Handle, 'Shutting down...');
  try
    FShuttingDown := True;
    Close;
  finally
    ShutdownBlockReasonDestroy(Handle);
  end;
end;

procedure TfStampy.spCurrentDayChange(Sender: TObject);
begin
  if FInCurrentDayChange then
  begin
    Exit;
  end;

  FInCurrentDayChange := True;
  try
    if spCurrentDay.Value > 0 then
    begin
      spCurrentDay.Value := 0;
    end;
  finally
    FInCurrentDayChange := False;
  end;

  Refresh;
end;

procedure TfStampy.SwitchMode;
begin
  SetMode(TPunchMode((Integer(FCurrentMode) + 1) mod (Integer(High(TPunchMode)) + 1)));
end;

procedure TfStampy.TrayIconDblClick(Sender: TObject);
begin
  acRestore.Execute;
end;

procedure TfStampy.TrayIconMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (not Visible or (FCurrentMode = pmSimple)) and (Now - FLastUpdateTimers > 1 / 24 / 60 / 60)
    then
  begin
    UpdateTimers;

    TrayIcon.Hint := Caption
      + #13#10 + 'Status: ' + lStatus.Caption
      + #13#10 + lWorkTimeDesc.Caption + ' ' + lWorkTime.Caption
      + #13#10 + lPauseTimeDesc.Caption + ' ' + lPauseTime.Caption;
  end;
end;

procedure TfStampy.UpdatePeriod(const Period: TPeriod);
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  qUpdateHours.ParamByName('Day').AsInteger := Trunc(Period.Start);
  qUpdateHours.ParamByName('TimeStamp').AsFloat := Period.Start;
  qUpdateHours.ParamByName('Type').AsInteger := Integer(Period.State);
  qUpdateHours.ParamByName('FirstOfDay').AsInteger := Integer(Period.FirstOfDay);
  qUpdateHours.ParamByName('rowid').AsInteger := Period.Id;

  qUpdateHours.ExecSQL;

  Refresh;
end;

procedure TfStampy.UpdateTimers;
var
  WorkTime, PauseTime: TDateTime;
begin
  FLastUpdateTimers := Now;

  WorkTime := FWorkTime;
  PauseTime := FPauseTime;

  if Assigned(FLastPeriod) and (FLastPeriod.Stop = 0) then
  begin
    case FLastPeriod.State of
      htOnTime:
        begin
          WorkTime := WorkTime + Now - FLastPeriod.Start;
          lStatus.Font.Color := clGreen;
        end;

      htPause:
        begin
          PauseTime := PauseTime + Now - FLastPeriod.Start;
          lStatus.Font.Color := clRed;
        end;

    else
      begin
        lStatus.Font.Color := clRed;
      end;
    end;

    lStatus.Caption := HoursTypeNames[FLastPeriod.State];
  end
  else
  begin
    lStatus.Font.Color := clRed;
    lStatus.Caption := HoursTypeNames[htOffTime];
  end;

  lWorkTime.Caption := BaseDiffString(WorkTime, GetWeeklyHours / 24 / GetWeeklyWorkDays);
  lPauseTime.Caption := BaseDiffString(PauseTime, GetStdPauseDuration / 24 / 60);
end;

procedure TfStampy.UpdateTimerTimer(Sender: TObject);
begin
  UpdateTimers;
end;

procedure TfStampy.WeeksStatistics(const StartDay,
  WeekCount: Integer);
var
  Weeks: TObjectList<TObjectList<TDay>>;
begin
  Weeks := TObjectList < TObjectList<TDay> > .Create(True);
  try
    AnalyseWeeks(StartDay, WeekCount, Weeks);
    PrintWeeks(Weeks, sgAnalysis);
  finally
    Weeks.Free;
  end;
end;

procedure TfStampy.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  Msg.Result := 0; // Deny system shutdown
  ShutDownTimer.Enabled := True; // Initialize non-blocking shutdown code.
end;

procedure TfStampy.WndProc(var Message: TMessage);
begin
  if Message.Msg = JclAppInstances.MessageId then
  begin
    case Message.WParam of
      AI_USERMSG:
        begin
          if Message.LParam = SC_RESTORE then
          begin
            Restore;
          end;
        end;
    end;
  end;

  inherited WndProc(Message);
end;

procedure TfStampy.CloseDay(const Day: Integer);
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  InsertHours(Day, Now, False, htOffTime, 'Application Closing');
end;

procedure TfStampy.LoadDay(const Day: Integer;
  const Periods: TObjectList<TPeriod>);
var
  Period: TPeriod;
begin
  Periods.Clear;

  if not DB.Connected then
  begin
    Exit;
  end;

  qDay.ParamByName('Day').AsInteger := Day;
  qDay.Open;

  try
    Period := nil;

    while not qDay.Eof do
    begin
      if not Assigned(Period) then
      begin
        Period := TPeriod.Create;
        Period.Id := qDay.FieldByName('rowid').AsInteger;
        Period.Start := qDay.FieldByName('TimeStamp').AsFloat;
        Period.State := THoursType(qDay.FieldByName('Type').AsInteger);
        Period.FirstOfDay := qDay.FieldByName('FirstOfDay').AsInteger <> 0;
      end
      else
      begin
        Period.Stop := qDay.FieldByName('TimeStamp').AsFloat;
        Periods.Add(Period);

        Period := TPeriod.Create;
        Period.Id := qDay.FieldByName('rowid').AsInteger;
        Period.Start := qDay.FieldByName('TimeStamp').AsFloat;
        Period.State := THoursType(qDay.FieldByName('Type').AsInteger);
        Period.FirstOfDay := qDay.FieldByName('FirstOfDay').AsInteger <> 0;
      end;

      qDay.Next;
    end;

    if Assigned(Period) then
    begin
      Periods.Add(Period);
    end

  finally
    qDay.Close;
  end;
end;

procedure TfStampy.LoadMonth(const DayInMonth: Integer;
  const Weeks: TObjectList<TWeek>);
var
  Days: TObjectList<TDay>;
  StartDay, EndDay: Integer;
  I: Integer;
begin
  Weeks.Clear;

  Days := TObjectList<TDay>.Create(True);
  try
    StartDay := Trunc(StartOfTheMonth(DayInMonth));
    EndDay := Trunc(EndOfTheMonth(DayInMonth));

    for I := 0 to WeekOfTheYear(EndDay) - WeekOfTheYear(StartDay) do
    begin
      LoadWeek(StartDay + I * 7, StartDay, EndDay, Days);

      if Days.Count > 0 then
      begin
        Weeks.Add(TWeek.Create(Days));
      end;
    end;
  finally
    Days.Free;
  end;
end;

procedure TfStampy.acCloseApplicationExecute(Sender: TObject);
begin
  FShuttingDown := True;
  Close;
end;

procedure TfStampy.acMinimizeExecute(Sender: TObject);
begin
  MinimizeToTray;
end;

procedure TfStampy.acPauseExecute(Sender: TObject);
begin
  InsertHours(htPause);
end;

procedure TfStampy.acRestoreExecute(Sender: TObject);
begin
  if not FHiddenInTray then
  begin
    Exit;
  end;

  Application.MainForm.Visible := True;

  Application.Restore;
  Application.BringToFront;

  FHiddenInTray := False;
  miHideRestore.Action := acMinimize;

  UpdateTimer.Enabled := FCurrentMode = pmAdvanced;
end;

procedure TfStampy.acSaveOptionsExecute(Sender: TObject);
begin
  SaveOptions;
end;

procedure TfStampy.acStartExecute(Sender: TObject);
begin
  InsertHours(htOnTime);
end;

procedure TfStampy.acStopExecute(Sender: TObject);
begin
  InsertHours(htOffTime);
  UpdateTimer.Enabled := False;
end;

procedure TfStampy.acSwitchModeExecute(Sender: TObject);
begin
  SwitchMode;
end;

procedure TfStampy.AddPeriodToCurrentDay(const Period: TPeriod);
begin
  BeginUpdate;
  try
    if Assigned(FLastPeriod) and (FLastPeriod.Stop = 0) then
    begin
      FLastPeriod.Stop := Period.Start;

      case FLastPeriod.State of
        htOnTime: FWorkTime := FWorkTime + FLastPeriod.Duration;
        htPause: FPauseTime := FPauseTime + FLastPeriod.Duration;
      end;
    end;

    FLastPeriod := Period;
    FCurrentDay.Add(Period);

  finally
    EndUpdate;
  end;
end;

procedure TfStampy.AnalyseMonths(const StartDay,
  MonthCount: Integer; const Months: TObjectList < TObjectList<TWeek> > );
var
  I: Integer;
  Month: TObjectList<TWeek>;
begin
  for I := 0 to MonthCount - 1 do
  begin
    Month := TObjectList<TWeek>.Create(True);
    LoadMonth(Trunc((IncMonth(StartDay, -I))), Month);

    if Month.Count = 0 then
    begin
      Month.Free;
    end
    else
    begin
      Months.Add(Month);
    end;
  end;
end;

procedure TfStampy.AnalyseToday;
begin
  BeginUpdate;
  try
    if FCurrentDay.Count > 0 then
    begin
      FLastPeriod := FCurrentDay.Last;
    end;

    AnalyseDay(FCurrentDay, FWorkTime, FPauseTime);
  finally
    EndUpdate;
  end;
end;

procedure TfStampy.AnalyseWeeks(const StartDay,
  WeekCount: Integer; const Weeks: TObjectList < TObjectList<TDay> > );
var
  I: Integer;
  Week: TObjectList<TDay>;
begin
  for I := 0 to WeekCount - 1 do
  begin
    Week := TObjectList<TDay>.Create(True);
    LoadWeek(StartDay - I * 7, Week);

    if Week.Count = 0 then
    begin
      Week.Free;
    end
    else
    begin
      Weeks.Add(Week);
    end;
  end;
end;

procedure TfStampy.ApplicationEventsMinimize(Sender: TObject);
begin
  acMinimize.Execute;
end;

procedure TfStampy.ApplicationEventsRestore(Sender: TObject);
begin
  acRestore.Execute;
end;

procedure TfStampy.BeginUpdate;
begin
  Inc(FUpdateCounter);
  UpdateTimer.Enabled := False;
end;

procedure TfStampy.bLoadAnalysisClick(Sender: TObject);
begin
  case rgAnalysisMode.ItemIndex of
    0: // Weeks
      begin
        WeeksStatistics(Trunc(Date), seDomainCount.Value);
      end;

    1: // Months
      begin
        MonthsStatistics(Trunc(Date), seDomainCount.Value);
      end;
  end;
end;

procedure TfStampy.CloseDay;
begin
  CloseDay(Trunc(Date));
end;

procedure TfStampy.CreateDB;
var
  Query: TFDQuery;
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DB;
    Query.SQL.LoadFromFile('StampyWorkingHours.sqlite3.sql');
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TfStampy.CurrentDayStatistics;
begin
  PrintPeriods(FCurrentDay, sgPeriods);
  AnalyseToday;
end;

procedure TfStampy.DBBeforeDisconnect(Sender: TObject);
begin
  SaveOptions;
  CloseDay;
end;

procedure TfStampy.DeletePeriod(const Period: TPeriod);
begin
  if not DB.Connected then
  begin
    Exit;
  end;

  qDeleteHours.ParamByName('rowid').AsInteger := Period.Id;
  qDeleteHours.ExecSQL;

  Refresh;
end;

procedure TfStampy.EndUpdate;
begin
  Dec(FUpdateCounter);

  if FUpdateCounter = 0 then
  begin
    UpdateTimers;
    UpdateTimer.Enabled := not FHiddenInTray
      and Assigned(FLastPeriod)
      and (FLastPeriod.State <> htOffTime)
      and (FCurrentMode = pmAdvanced);
  end;
end;

function TfStampy.ExistsFirstOfDay(const Day: Integer): Boolean;
begin
  if not DB.Connected then
  begin
    Result := False;
    Exit;
  end;

  qFirstOfDay.ParamByName('Day').AsInteger := Day;
  qFirstOfDay.ParamByName('FirstOfDay').AsInteger := Integer(True);

  qFirstOfDay.Open;

  Result := not qFirstOfDay.Eof;

  qFirstOfDay.Close;
end;

{ TOption }

constructor TOption.Create(const Key, Value: string; const Edit: TEdit);
begin
  FEdit := Edit;
  FKey := Key;
  FValue := Value;
end;

function TOption.GetEditText: string;
begin
  if Assigned(FEdit) then
  begin
    Result := FEdit.Text;
    Exit;
  end;

  Result := '';
end;

procedure TOption.SetEditText(const Value: string);
begin
  if Assigned(FEdit) then
  begin
    FEdit.Text := Value;
  end;
end;

procedure TOption.SetValue(const Value: string);
begin
  FValue := Value;
  EditText := Value;
end;

{ TPeriod }

constructor TPeriod.Create(const Id: Integer; const Start, Stop: TDateTime;
  const State: THoursType; const FirstOfDay: Boolean);
begin
  FId := Id;
  FStart := Start;
  FStop := Stop;
  FState := State;
  FFirstOfDay := FirstOfDay;
end;

function TPeriod.GetDuration: TDateTime;
begin
  if Stop = 0 then
  begin
    Result := Now - Start;
  end
  else
  begin
    Result := Stop - Start;
  end;
end;

{ TDay }

constructor TDay.Create(const Day, WorkTime, PauseTime: TDateTime);
begin
  FDay := Day;
  FWorkTime := WorkTime;
  FPauseTime := PauseTime;
end;

constructor TDay.Create(const Periods: TObjectList<TPeriod>);
begin
  if Periods.Count > 0 then
  begin
    FDay := Trunc(Periods.First.Start);
    AnalyseDay(Periods, FWorkTime, FPauseTime);
  end;
end;

{ TWeek }

constructor TWeek.Create(const Week, StartDay, EndDay, WorkDays: Integer;
  const WorkTime, PauseTime: TDateTime);
begin
  FWeek := Week;
  FStartDay := StartDay;
  FEndDay := EndDay;
  FWorkDays := WorkDays;
  FWorkTime := WorkTime;
  FPauseTime := PauseTime;
end;

constructor TWeek.Create(const Days: TObjectList<TDay>);
var
  I: Integer;
begin
  if Days.Count > 0 then
  begin
    FWeek := WeekOf(Days.First.Day);
    FStartDay := Trunc(Days.First.Day);
    FEndDay := Trunc(Days.Last.Day);
    FWorkDays := Days.Count;

    FWorkTime := 0;
    FPauseTime := 0;
    for I := 0 to FWorkDays - 1 do
    begin
      FWorkTime := FWorkTime + Days[I].WorkTime;
      FPauseTime := FPauseTime + Days[I].PauseTime;
    end;
  end;
end;

{ TMonth }

constructor TMonth.Create(const Month, StartDay, EndDay, WorkDays: Integer;
  const WorkTime, PauseTime: TDateTime);
begin
  FMonth := Month;
  FStartDay := StartDay;
  FEndDay := EndDay;
  FWorkDays := WorkDays;
  FWorkTime := WorkTime;
  FPauseTime := PauseTime;
end;

constructor TMonth.Create(const Weeks: TObjectList<TWeek>);
var
  I: Integer;
begin
  if Weeks.Count > 0 then
  begin
    FMonth := MonthOf(Weeks.First.StartDay);
    FStartDay := Trunc(Weeks.First.StartDay);
    FEndDay := Trunc(Weeks.Last.EndDay);

    FWorkDays := 0;
    FWorkTime := 0;
    FPauseTime := 0;
    for I := 0 to Weeks.Count - 1 do
    begin
      Inc(FWorkDays, Weeks[I].WorkDays);
      FWorkTime := FWorkTime + Weeks[I].WorkTime;
      FPauseTime := FPauseTime + Weeks[I].PauseTime;
    end;
  end;
end;

end.


