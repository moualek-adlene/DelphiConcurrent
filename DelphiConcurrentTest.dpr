program DelphiConcurrentTest;

uses
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {Form1},
  DelphiConcurrent in 'DelphiConcurrent.pas',
  ThreadsUnit in 'ThreadsUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
