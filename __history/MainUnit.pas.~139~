unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.SyncObjs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox, FMX.SpinBox,
  System.Generics.Collections, DelphiConcurrent, ThreadsUnit, FMX.ListBox,
  FMX.Layouts;

type
  TMainForm = class(TForm)
    Layout1: TLayout;
    Synchronizer_GroupBox: TGroupBox;
    Monitor_RadioButton: TRadioButton;
    CriticalSection_RadioButton: TRadioButton;
    DCMRER_RadioButton: TRadioButton;
    DeadLock_Detection_GroupBox: TGroupBox;
    Thread_A_Def_GroupBox: TGroupBox;
    Instructions_Set_A_ComboBox: TComboBox;
    Add_Instruction_A_Button: TButton;
    Label5: TLabel;
    Scenario_A_ListBox: TListBox;
    Del_Instruction_A_Button: TButton;
    MoveUp_Instruction_A_Button: TButton;
    MoveDown_Instruction_A_Button: TButton;
    Clear_Instruction_A_Button: TButton;
    Thread_B_Def_GroupBox: TGroupBox;
    Instructions_Set_B_ComboBox: TComboBox;
    Add_Instruction_B_Button: TButton;
    Label6: TLabel;
    Scenario_B_ListBox: TListBox;
    Del_Instruction_B_Button: TButton;
    MoveUp_Instruction_B_Button: TButton;
    MoveDown_Instruction_B_Button: TButton;
    Clear_Instruction_B_Button: TButton;
    Run_Scenarios_Button: TButton;
    DeadLock_Log_GroupBox: TGroupBox;
    DeadLock_Log_Memo: TMemo;
    Layout2: TLayout;
    Speed_Test_GroupBox: TGroupBox;
    Speed_Test_Log_Memo: TMemo;
    MessagesNbrPerProducer_SpinBox: TSpinBox;
    lbl1: TLabel;
    ConsumersNbr_SpinBox: TSpinBox;
    lbl2: TLabel;
    ProducersNbr_SpinBox: TSpinBox;
    lbl3: TLabel;
    ExecTimeLabel: TLabel;
    lbl4: TLabel;
    StopButton: TButton;
    StartButton: TButton;
    spl1: TSplitter;
    procedure StartButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Add_Instruction_A_ButtonClick(Sender: TObject);
    procedure Add_Instruction_B_ButtonClick(Sender: TObject);
    procedure Del_Instruction_A_ButtonClick(Sender: TObject);
    procedure Del_Instruction_B_ButtonClick(Sender: TObject);
    procedure MoveUp_Instruction_A_ButtonClick(Sender: TObject);
    procedure MoveUp_Instruction_B_ButtonClick(Sender: TObject);
    procedure MoveDown_Instruction_A_ButtonClick(Sender: TObject);
    procedure MoveDown_Instruction_B_ButtonClick(Sender: TObject);
    procedure Clear_Instruction_A_ButtonClick(Sender: TObject);
    procedure Clear_Instruction_B_ButtonClick(Sender: TObject);
    procedure Run_Scenarios_ButtonClick(Sender: TObject);
    procedure Scenario_A_ListBoxChange(Sender: TObject);
    procedure Scenario_B_ListBoxChange(Sender: TObject);
  private
    { Déclarations privées }
    SharedResourcesLst: array [0..3] of TDCThreaded;
    ProducersLst: array of TProducer;
    ConsumersLst: array of TConsumer;
    DeadLock_Test_Thread_A, DeadLock_Test_Thread_B: TDeadLockTester;
    TestStartTime, TestEndTime, TestDuration: Cardinal;
    ProducersNbr, ConsumersNbr, MessagesNbrPerProducer : Integer;
    Is_Scenarios_Running : Boolean;
    procedure Thread_A_ActionsControl();
    procedure Thread_B_ActionsControl();
  public
    { Déclarations publiques }
    procedure UpdateSpeedTestResult(const msg: String);
    procedure UpdateDeadLockTestResult(const msg: String);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.Add_Instruction_A_ButtonClick(Sender: TObject);
begin
  Scenario_A_ListBox.ItemIndex := Scenario_A_ListBox.Items.Add(Instructions_Set_A_ComboBox.Items[Instructions_Set_A_ComboBox.ItemIndex]);
  Thread_A_ActionsControl();
end;

procedure TMainForm.Add_Instruction_B_ButtonClick(Sender: TObject);
begin
  Scenario_B_ListBox.ItemIndex := Scenario_B_ListBox.Items.Add(Instructions_Set_B_ComboBox.Items[Instructions_Set_B_ComboBox.ItemIndex]);
  Thread_B_ActionsControl();
end;

procedure TMainForm.Clear_Instruction_A_ButtonClick(Sender: TObject);
begin
  Scenario_A_ListBox.Items.Clear;
  Thread_A_ActionsControl();
end;

procedure TMainForm.Clear_Instruction_B_ButtonClick(Sender: TObject);
begin
  Scenario_B_ListBox.Items.Clear;
  Thread_B_ActionsControl();
end;

procedure TMainForm.Del_Instruction_A_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_A_ListBox.ItemIndex;
  Scenario_A_ListBox.Items.Delete(Scenario_A_ListBox.ItemIndex);
  if (Scenario_A_ListBox.Count > 0) then
  begin
    if (x < Scenario_A_ListBox.Count)
      then Scenario_A_ListBox.ItemIndex := x
      else Scenario_A_ListBox.ItemIndex := x-1;
  end;
  Thread_A_ActionsControl();
end;

procedure TMainForm.Del_Instruction_B_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_B_ListBox.ItemIndex;
  Scenario_B_ListBox.Items.Delete(Scenario_B_ListBox.ItemIndex);
  if (Scenario_B_ListBox.Count > 0) then
  begin
    if (x < Scenario_B_ListBox.Count)
      then Scenario_B_ListBox.ItemIndex := x
      else Scenario_B_ListBox.ItemIndex := x-1;
  end;
  Thread_B_ActionsControl();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  StartButton.Enabled := True;
  StopButton.Enabled := False;
  Thread_A_ActionsControl();
  Thread_B_ActionsControl();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if StopButton.Enabled
    then StopButtonClick(nil);
end;

procedure TMainForm.MoveDown_Instruction_A_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_A_ListBox.ItemIndex;
  Scenario_A_ListBox.Items.Move(x, x + 1);
  Scenario_A_ListBox.ItemIndex := x + 1;
  Thread_A_ActionsControl();
end;

procedure TMainForm.MoveDown_Instruction_B_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_B_ListBox.ItemIndex;
  Scenario_B_ListBox.Items.Move(x, x + 1);
  Scenario_B_ListBox.ItemIndex := x + 1;
  Thread_B_ActionsControl();
end;

procedure TMainForm.MoveUp_Instruction_A_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_A_ListBox.ItemIndex;
  Scenario_A_ListBox.Items.Move(x, x - 1);
  Scenario_A_ListBox.ItemIndex := x - 1;
  Thread_A_ActionsControl();
end;

procedure TMainForm.MoveUp_Instruction_B_ButtonClick(Sender: TObject);
var
  x : Integer;
begin
  x := Scenario_B_ListBox.ItemIndex;
  Scenario_B_ListBox.Items.Move(x, x - 1);
  Scenario_B_ListBox.ItemIndex := x - 1;
  Thread_B_ActionsControl();
end;

procedure TMainForm.Run_Scenarios_ButtonClick(Sender: TObject);
var
  i, j: Integer;
  MessagesLockType: TDCLockType;
  LExecContext: TDCAdlLocalExecContext;
  LResourcePointer: TDCProtected;
begin
  Is_Scenarios_Running := True;
  Scenario_A_ListBox.ItemIndex := -1;
  Scenario_B_ListBox.ItemIndex := -1;
  Thread_A_ActionsControl();
  Thread_B_ActionsControl();
  try
    DeadLock_Log_Memo.Lines.Clear;
    if (DCMRER_RadioButton.IsChecked)
      then MessagesLockType := ltMREW
    else
    if (CriticalSection_RadioButton.IsChecked)
      then MessagesLockType := ltCriticalSection
    else
      MessagesLockType := ltMonitor;
    // we want to simulate a deadlock but we dont want to have a real deadlock in this simulator
    // because we can not skip out from a real deadlock and restart a new test without killing the application
    // so the TDCThreaded has a special option made for this test case (the 'SimulationMode' option)
    for i:=1 to 3 do
      SharedResourcesLst[i] := TDCThreaded.Create(TDCProtectedList, MessagesLockType, True); // SimulationMode = True
    //
    DeadLock_Test_Thread_A := TDeadLockTester.Create('A', SharedResourcesLst, Scenario_A_ListBox.Items);
    DeadLock_Test_Thread_B := TDeadLockTester.Create('B', SharedResourcesLst, Scenario_B_ListBox.Items);
    //
    DeadLock_Test_Thread_A.WaitFor;
    DeadLock_Test_Thread_A.Free;
    DeadLock_Test_Thread_A := nil;

    DeadLock_Test_Thread_B.WaitFor;
    DeadLock_Test_Thread_B.Free;
    DeadLock_Test_Thread_B := nil;

    for i:=1 to 3 do
    begin
      LExecContext := TDCAdlLocalExecContext.Create;
      LResourcePointer := SharedResourcesLst[i].Lock(LExecContext, False); // ReadOnly: Boolean=True
      try
        if (LResourcePointer is TDCProtectedList) then
        begin
          for j:=0 to TDCProtectedList(LResourcePointer).Count-1 do
          begin
             TExchangedMessage(TDCProtectedList(LResourcePointer)[j]).Free;
          end;
        end;
      finally
        SharedResourcesLst[i].Unlock(LExecContext);
        FreeAndNil(LExecContext);
      end;
      SharedResourcesLst[i].Free;
      SharedResourcesLst[i] := nil;
    end;
  finally
    Is_Scenarios_Running := False;
    Thread_A_ActionsControl();
    Thread_B_ActionsControl();
  end;
end;

procedure TMainForm.Scenario_A_ListBoxChange(Sender: TObject);
begin
  Thread_A_ActionsControl();
end;

procedure TMainForm.Scenario_B_ListBoxChange(Sender: TObject);
begin
  Thread_B_ActionsControl();
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
var
  i: Integer;
  MessagesLockType: TDCLockType;
begin
  StartButton.Enabled := False;
  ProducersNbr := Trunc(ProducersNbr_SpinBox.Value);
  ConsumersNbr := Trunc(ConsumersNbr_SpinBox.Value);
  MessagesNbrPerProducer := Trunc(MessagesNbrPerProducer_SpinBox.Value);
  if (DCMRER_RadioButton.IsChecked)
    then MessagesLockType := ltMREW
  else
  if (CriticalSection_RadioButton.IsChecked)
    then MessagesLockType := ltCriticalSection
  else
    MessagesLockType := ltMonitor;

  SharedResourcesLst[0] := TDCThreaded.Create(TDCProtectedList, MessagesLockType);
  SetLength(ProducersLst, ProducersNbr);
  SetLength(ConsumersLst, ConsumersNbr);

  ExecTimeLabel.Text := '';
  Speed_Test_Log_Memo.Lines.Clear;
  Speed_Test_Log_Memo.Lines.BeginUpdate;
  StopButton.Enabled := True;
  Application.ProcessMessages; // force mainform update

  TestStartTime := TThread.GetTickCount;
  for i:=0 to ProducersNbr-1 do
    ProducersLst[i] := TProducer.Create(i, MessagesNbrPerProducer, SharedResourcesLst[0]);
  for i:=0 to ConsumersNbr-1 do
    ConsumersLst[i] := TConsumer.Create(i, MessagesNbrPerProducer * ProducersNbr, SharedResourcesLst[0]);
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
var
  i: Integer;
  LExecContext: TDCAdlLocalExecContext;
  LResourcePointer: TDCProtected;
begin
  StopButton.Enabled := False;
  Speed_Test_Log_Memo.Lines.EndUpdate;

  for i:=0 to ProducersNbr-1 do
  begin
    if Assigned(ProducersLst[i]) then
    begin
      ProducersLst[i].Terminate;
      ProducersLst[i].WaitFor;
      ProducersLst[i].Free;
      ProducersLst[i] := nil;
    end;
  end;
  for i:=0 to ConsumersNbr-1 do
  begin
    if Assigned(ConsumersLst[i]) then
    begin
      ConsumersLst[i].Terminate;
      ConsumersLst[i].WaitFor;
      ConsumersLst[i].Free;
      ConsumersLst[i] := nil;
    end;
  end;
  Finalize(ProducersLst);
  Finalize(ConsumersLst);
  LExecContext := TDCAdlLocalExecContext.Create;
  LResourcePointer := SharedResourcesLst[0].Lock(LExecContext, False); // ReadOnly: Boolean=True
  try
    if (LResourcePointer is TDCProtectedList) then
    begin
      for i:=0 to TDCProtectedList(LResourcePointer).Count-1 do
      begin
         TExchangedMessage(TDCProtectedList(LResourcePointer)[i]).Free;
      end;
    end;
  finally
    SharedResourcesLst[0].Unlock(LExecContext);
    FreeAndNil(LExecContext);
  end;
  SharedResourcesLst[0].Free;
  SharedResourcesLst[0] := nil;
  StartButton.Enabled := True;
end;

procedure TMainForm.Thread_A_ActionsControl;
begin
  Add_Instruction_A_Button.Enabled := (not Is_Scenarios_Running);
  Del_Instruction_A_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.ItemIndex >= 0);
  MoveUp_Instruction_A_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.ItemIndex > 0);
  MoveDown_Instruction_A_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.ItemIndex >= 0)
    and (Scenario_A_ListBox.ItemIndex < Scenario_A_ListBox.Count - 1);
  Clear_Instruction_A_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.Count > 0);
  Run_Scenarios_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.Count > 0) and (Scenario_B_ListBox.Count > 0);
end;

procedure TMainForm.Thread_B_ActionsControl;
begin
  Add_Instruction_B_Button.Enabled := (not Is_Scenarios_Running);
  Del_Instruction_B_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_B_ListBox.ItemIndex >= 0);
  MoveUp_Instruction_B_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_B_ListBox.ItemIndex > 0);
  MoveDown_Instruction_B_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_B_ListBox.ItemIndex >= 0)
    and (Scenario_B_ListBox.ItemIndex < Scenario_B_ListBox.Count - 1);
  Clear_Instruction_B_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_B_ListBox.Count > 0);
  Run_Scenarios_Button.Enabled := (not Is_Scenarios_Running) and (Scenario_A_ListBox.Count > 0) and (Scenario_B_ListBox.Count > 0);
end;

procedure TMainForm.UpdateDeadLockTestResult(const msg: String);
begin
  DeadLock_Log_Memo.Lines.Add('Line n°' + IntToStr(DeadLock_Log_Memo.Lines.Count+1) + ': ' + msg);
end;

procedure TMainForm.UpdateSpeedTestResult(const msg: String);
begin
  Speed_Test_Log_Memo.Lines.Add('Line n°' + IntToStr(Speed_Test_Log_Memo.Lines.Count+1) + ': ' + msg);
  // each thread (Producer or Consumer) will insert 2 messages in the memo in his life
  // so we except at the end 2 * (ProducersNbr + ConsumersNbr) messages in the memo
  if (Speed_Test_Log_Memo.Lines.Count = 2 * (ProducersNbr + ConsumersNbr)) then
  begin
    TestEndTime := TThread.GetTickCount;
    TestDuration := TestEndTime - TestStartTime;
    ExecTimeLabel.Text := Format('%f', [TestDuration / 1000]) + ' sec';
    StopButtonClick(nil);
  end;
end;

end.
