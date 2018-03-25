unit ThreadsUnit;

interface

uses
  System.Classes, System.Types, System.SyncObjs, System.SysUtils, System.Contnrs, System.Generics.Collections,
  DelphiConcurrent;

type
  TExchangedMessage = class
    FID: Integer;
    FDT: TDateTime;
    constructor Create(const AID: Integer; const ADT: TDateTime);
  public
    procedure Assign(ASrcMsg: TExchangedMessage);
    property ID: Integer read FID write FID;
    property DT: TDateTime read FDT write FDT;
  end;

  TProducer = class(TThread)
  private
    FThreadNum, FMessagesNbr: Integer; // here FMessagesNbr = Nbr of messages to produce
    FSharedResource: TDCThreaded;
  public
    constructor Create(const AThreadNum, AMessagesNbr: Integer; ASharedResource: TDCThreaded);
    procedure Execute; override;
    procedure NotifyToUI(const msg: String);
    property ThreadNum: Integer read FThreadNum write FThreadNum;
  end;

  TConsumer = class(TThread)
  private
    FThreadNum, FMessagesNbr: Integer; // here FMessagesNbr = Nbr of messages to consume
    FSharedResource: TDCThreaded;
    FReceivedMessagesCopies: TObjectList<TExchangedMessage>;
  public
    constructor Create(const AThreadNum, AMessagesNbr: Integer; ASharedResource: TDCThreaded);
    destructor Destroy; override;
    procedure Execute; override;
    procedure NotifyToUI(const msg: String);
    property ThreadNum: Integer read FThreadNum write FThreadNum;
  end;

  TDeadLockTester = class(TThread)
  private
    FThreadNum: Char;
    FSharedResources: array of TDCThreaded;
    FInstructions: TStringList;
  public
    constructor Create(const AThreadNum: Char; ASharedResources: array of TDCThreaded; AInstructions: TStrings);
    destructor Destroy; override;
    procedure Execute; override;
    procedure NotifyToUI(const msg: String);
    property ThreadNum: Char read FThreadNum write FThreadNum;
  end;

implementation

uses
  MainUnit;

{ TProducer }

constructor TProducer.Create(const AThreadNum, AMessagesNbr: Integer; ASharedResource: TDCThreaded);
begin
  inherited Create();
  FThreadNum := AThreadNum;
  FMessagesNbr := AMessagesNbr;
  FSharedResource := ASharedResource;
end;

procedure TProducer.Execute;
var
  i: Integer;
  LExchangedMessage: TExchangedMessage;
  LResourcePointer: TDCProtected;
  LExecContext: TDCAdlLocalExecContext;
begin
  inherited;
  NameThreadForDebugging('Producer ' + FThreadNum.ToString);
  NotifyToUI('Producer Thread ' + FThreadNum.ToString + ' Started');
  LExecContext := TDCAdlLocalExecContext.Create;
  try
    i:=1;
    while (i <= FMessagesNbr) and (not Terminated) do
    begin
      LExchangedMessage := TExchangedMessage.Create(i, Now());
      LResourcePointer := FSharedResource.Lock(LExecContext, False); // ReadOnly: Boolean=True
      try
        if (LResourcePointer is TDCProtectedList) then
        begin
          TDCProtectedList(LResourcePointer).Add(LExchangedMessage);
        end;
      finally
        FSharedResource.Unlock(LExecContext);
      end;
      Inc(i);
      Sleep(5);
    end;
  finally
    FreeAndNil(LExecContext);
  end;
  NotifyToUI('Producer Thread ' + FThreadNum.ToString + ' Terminated');
end;

procedure TProducer.NotifyToUI(const msg: String);
begin
  TThread.Queue(nil, procedure begin
    MainForm.UpdateSpeedTestResult(msg);
  end);
end;

{ TConsumer }

constructor TConsumer.Create(const AThreadNum, AMessagesNbr: Integer; ASharedResource: TDCThreaded);
begin
  inherited Create();
  FThreadNum := AThreadNum;
  FMessagesNbr := AMessagesNbr;
  FSharedResource := ASharedResource;
  FReceivedMessagesCopies := TObjectList<TExchangedMessage>.Create(True);
end;

destructor TConsumer.Destroy;
begin
  FreeAndNil(FReceivedMessagesCopies);
  inherited;
end;

procedure TConsumer.Execute;
var
  i: Integer;
  LResourcePointer: TDCProtected;
  LExchangedMessageCopy: TExchangedMessage;
  LExecContext: TDCAdlLocalExecContext;
begin
  inherited;
  NameThreadForDebugging('Consumer ' + FThreadNum.ToString);
  NotifyToUI('Consumer Thread ' + FThreadNum.ToString + ' Started');
  LExecContext := TDCAdlLocalExecContext.Create;
  try
    while (FReceivedMessagesCopies.Count < FMessagesNbr) and (not Terminated) do
    begin
      LResourcePointer := FSharedResource.Lock(LExecContext); // ReadOnly: Boolean=True
      try
        if (LResourcePointer is TDCProtectedList) then
        begin
          for i:=0 to TDCProtectedList(LResourcePointer).Count-1 do
          begin
            if (FReceivedMessagesCopies.IndexOf(TDCProtectedList(LResourcePointer)[i]) < 0) then
            begin
              LExchangedMessageCopy := TExchangedMessage.Create(0, 0);
              LExchangedMessageCopy.Assign(TDCProtectedList(LResourcePointer)[i]);
              FReceivedMessagesCopies.Add(LExchangedMessageCopy);
            end;
          end;
        end;
      finally
        FSharedResource.Unlock(LExecContext);
      end;
      Sleep(5);
    end;
  finally
    FreeAndNil(LExecContext);
  end;
  NotifyToUI('Consumer Thread ' + FThreadNum.ToString + ' Terminated');
end;

procedure TConsumer.NotifyToUI(const msg: String);
begin
  TThread.Queue(nil, procedure begin
    MainForm.UpdateSpeedTestResult(msg);
  end);
end;

{ TExchangedMessage }

procedure TExchangedMessage.Assign(ASrcMsg: TExchangedMessage);
begin
  FID := ASrcMsg.ID;
  FDT := ASrcMsg.DT;
end;

constructor TExchangedMessage.Create(const AID: Integer; const ADT: TDateTime);
begin
  FID := AID;
  FDT := ADT;
end;

{ TDeadLockTester }

constructor TDeadLockTester.Create(const AThreadNum: Char; ASharedResources: array of TDCThreaded; AInstructions: TStrings);
var
  i: Integer;
begin
  inherited Create();
  FThreadNum := AThreadNum;
  // NOTE: SharedResource[0] is not used in this test (it's just for the speed test)
  SetLength(FSharedResources, Length(ASharedResources) - 1);
  for i:=1 to High(ASharedResources)
    do FSharedResources[i-1] := ASharedResources[i];
  FInstructions := TStringList.Create;
  FInstructions.Assign(AInstructions);
end;

destructor TDeadLockTester.Destroy;
begin
  Finalize(FSharedResources);
  FreeAndNil(FInstructions);
  inherited;
end;

procedure TDeadLockTester.Execute;
type
  TInstructionType = (itLock, itUnLock);
var
  i, LResourceNum: Integer;
  LInstructionType: TInstructionType;
  LExecContext: TDCAdlLocalExecContext;
begin
  inherited;
  NameThreadForDebugging('DeadLockTester ' + FThreadNum);
  NotifyToUI('DeadLockTester Thread ' + FThreadNum + ' Started');
  LExecContext := TDCAdlLocalExecContext.Create;
  try
    try
      for i:=0 to FInstructions.Count-1 do
      begin
        LResourceNum := Copy(FInstructions[i], Length('Resource') + 1, 1).ToInteger;
        if (Copy(FInstructions[i], Pos('.', FInstructions[i]) + 1, Length(FInstructions[i])) = 'Lock')
          then LInstructionType := itLock
          else LInstructionType := itUnLock;
        if (LInstructionType = itLock) then
        begin
          NotifyToUI('Thread ' + FThreadNum + ' Before Lock for Resource ' + LResourceNum.ToString);
          FSharedResources[LResourceNum-1].Lock(LExecContext, False); // ReadOnly: Boolean=True
          NotifyToUI('Thread ' + FThreadNum + ' After Lock for Resource ' + LResourceNum.ToString);
        end else
        begin
          NotifyToUI('Thread ' + FThreadNum + ' Before UnLock for Resource ' + LResourceNum.ToString);
          FSharedResources[LResourceNum-1].UnLock(LExecContext);
          NotifyToUI('Thread ' + FThreadNum + ' After UnLock for Resource ' + LResourceNum.ToString);
        end;
      end;
    except
      on e:Exception
        do NotifyToUI('Exception "' + e.ClassName + '" on Thread ' + FThreadNum + ' : ' + e.message);
    end;
  finally
    try
      FreeAndNil(LExecContext);
    except
      on e:Exception
        do NotifyToUI('Exception "' + e.ClassName + '" on Thread ' + FThreadNum + ' : ' + e.message);
    end;
  end;
  NotifyToUI('DeadLockTester Thread ' + FThreadNum + ' Terminated');
end;

procedure TDeadLockTester.NotifyToUI(const msg: String);
begin
  TThread.Queue(nil, procedure begin
    MainForm.UpdateDeadLockTestResult(msg);
  end);
end;

end.
