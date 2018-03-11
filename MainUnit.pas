unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, DelphiConcurrent, ThreadsUnit;

type
  TForm1 = class(TForm)
    StartButton: TButton;
    Memo1: TMemo;
    StopButton: TButton;
    Label1: TLabel;
    ExecTimeLabel: TLabel;
    procedure StartButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { D�clarations priv�es }
    SharedRessource: TDCAdlThreaded;
    ProducersLst: array[1..ProducersNbr] of TProducer;
    ConsumersLst: array[1..ConsumersNbr] of TConsumer;
    TestStartTime, TestEndTime, TestDuration: Cardinal;
  public
    { D�clarations publiques }
    procedure UpdateTestResult(const msg: String);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  StartButton.Enabled := True;
  StopButton.Enabled := False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if StopButton.Enabled
    then StopButtonClick(nil);
end;

procedure TForm1.StartButtonClick(Sender: TObject);
var
  i: Integer;
begin
  StartButton.Enabled := False;
  ExecTimeLabel.Text := '';
  Memo1.Lines.Clear;
  TestStartTime := TThread.GetTickCount;
  Application.ProcessMessages; // force mainform update
  SharedRessource := TDCAdlThreaded.Create(TDCReadableOnlyList);
  for i:=1 to ProducersNbr do
    ProducersLst[i] := TProducer.Create(i, SharedRessource);
  for i:=1 to ConsumersNbr do
    ConsumersLst[i] := TConsumer.Create(i, SharedRessource);
  StopButton.Enabled := True;
  Application.ProcessMessages; // force mainform update
end;

procedure TForm1.StopButtonClick(Sender: TObject);
var
  i: Integer;
  LRessourcePointer: TDCReadableOnly;
begin
  StopButton.Enabled := False;
  for i:=1 to ProducersNbr do
  begin
    if Assigned(ProducersLst[i]) then
    begin
      ProducersLst[i].Terminate;
      ProducersLst[i].WaitFor;
      ProducersLst[i] := nil;
    end;
  end;
  for i:=1 to ConsumersNbr do
  begin
    if Assigned(ConsumersLst[i]) then
    begin
      ConsumersLst[i].Terminate;
      ConsumersLst[i].WaitFor;
      ConsumersLst[i] := nil;
    end;
  end;
  LRessourcePointer := SharedRessource.Lock(); // ReadOnly: Boolean=True
  try
    if (LRessourcePointer is TDCReadableOnlyList) then
    begin
      for i:=0 to TDCReadableOnlyList(LRessourcePointer).Count-1 do
      begin
         TExchangedMessage(TDCReadableOnlyList(LRessourcePointer)[i]).Free;
      end;
    end;
  finally
    SharedRessource.Unlock;
  end;
  FreeAndNil(SharedRessource);
  StartButton.Enabled := True;
end;

procedure TForm1.UpdateTestResult(const msg: String);
begin
  Memo1.Lines.Add('Line n�' + IntToStr(Memo1.Lines.Count+1) + ': ' + msg);
  // each thread (Producer or Consumer) will insert 2 messages in the memo in his life
  // so we except at the end 2 * (ProducersNbr + ConsumersNbr) messages in the memo
  if (Memo1.Lines.Count = 2 * (ProducersNbr + ConsumersNbr)) then
  begin
    TestEndTime := TThread.GetTickCount;
    TestDuration := TestEndTime - TestStartTime;
    ExecTimeLabel.Text := Format('%f', [TestDuration / 1000]) + ' sec';
    StopButtonClick(nil);
  end;
end;

end.
