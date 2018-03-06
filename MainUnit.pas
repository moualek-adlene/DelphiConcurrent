unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  DelphiConcurrent;

procedure TForm1.Button1Click(Sender: TObject);
var
  obj1 : TDCAdlThreaded<TDCReadableOnlyList>;
begin
  obj1 := TDCAdlThreaded<TDCReadableOnlyList>.Create;
  try

  finally
    obj1.Free;
  end;
end;

end.
