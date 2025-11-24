unit ufMonthSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin;

type
  TfMonthSelection = class(TForm)
    bAccept: TButton;
    bCancel: TButton;
    lYear: TLabel;
    lMonth: TLabel;
    seYear: TSpinEdit;
    seMonth: TSpinEdit;
    procedure FormCreate(Sender: TObject);
  end;

var
  fMonthSelection: TfMonthSelection;

implementation

uses
  System.DateUtils;

{$R *.dfm}

procedure TfMonthSelection.FormCreate(Sender: TObject);
var
  Datum: TDateTime;
begin
  Datum := IncMonth(Date, -1);
  seYear.Value := YearOf(Datum);
  seMonth.Value := MonthOf(Datum);
end;

end.
