unit DelphiConcurrent;

// Delphi Concurrent Anti-DeadLock Optimistic-MultiRead FrameWork
// Author : Moualek Adlene (moualek.adlene@gmail.com)
// Version : 0.1
// Project Start Date : 25/02/2018

interface

uses
  System.Classes, System.Types, System.SyncObjs, System.SysUtils, System.Contnrs, System.Generics.Collections;

type
  // Delphi Concurrent Anti-DeadLock TMultiReadExclusiveWriteSynchronizer Class
  TDCAdlMultiReadExclusiveWriteSynchronizer = class(TMultiReadExclusiveWriteSynchronizer)
  private
    FReadOnly: Boolean;
  public
    constructor Create();
    procedure Lock(AReadOnly: Boolean); inline;
    procedure Unlock; inline;
    property ReadOnly: Boolean read FReadOnly;
  end;

  // A Base Class that can put a Thread-Safe Object in ReadOnly or ReadWrite Access Mode
  TDCReadableOnly = class
  private
    FRWSynchronizer: TObject;
    procedure ToggleFromReadToWriteMode();
  public
    constructor Create(ARWSynchronizer: TObject); virtual;
    property RWSynchronizer: TObject read FRWSynchronizer;
  end;

  // Delphi Concurrent Anti-DeadLock Optimistic-MultiRead Generic Class
  TDCReadableOnlyClass = class of TDCReadableOnly;
  TDCLockType = (ltAdlMREW, ltCriticalSection, ltMonitor);

  TDCAdlThreaded = class
  private
    FLockType: TDCLockType;
    FLockObject: TObject;
    FSharedObject: TDCReadableOnly;
  public
    constructor Create(ADCReadableOnlyClass: TDCReadableOnlyClass; ALockType: TDCLockType=ltAdlMREW);
    destructor Destroy; override;
    // Be optimist for MultiRead, Toggle to ReadWrite Mode (Exclusif Access) only when necessary
    function Lock(AReadOnly: Boolean=True): TDCReadableOnly; inline;
    procedure Unlock; inline;
    property LockType: TDCLockType read FLockType;
    property LockObject: TObject read FLockObject;
  end;

  // A Readable Only TList Class
  TDCReadableOnlyList = class(TDCReadableOnly)
  private
    FList: TList;
  protected
    function Get(Index: Integer): Pointer;
    procedure Put(Index: Integer; Item: Pointer);
    function GetCapacity(): Integer;
    function GetCount(): Integer;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    constructor Create(ARWSynchronizer: TObject); override;
    destructor Destroy; override;
    function Add(Item: Pointer): Integer;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TList;
    function Extract(Item: Pointer): Pointer;
    function ExtractItem(Item: Pointer; Direction: TDirection): Pointer;
    function First: Pointer; inline;
    function GetEnumerator: TListEnumerator;
    function IndexOf(Item: Pointer): Integer;
    function IndexOfItem(Item: Pointer; Direction: TDirection): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
    function Last: Pointer;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Pointer): Integer;
    function RemoveItem(Item: Pointer; Direction: TDirection): Integer;
    procedure Pack;
    procedure Sort(Compare: TListSortCompare);
    procedure SortList(const Compare: TListSortCompareFunc);
    procedure Assign(ListA: TList; AOperator: TListAssignOp = laCopy; ListB: TList = nil);
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: Pointer read Get write Put; default;
  end;

  // A Readable Only TObjectList Class
  TDCReadableOnlyObjectList = class(TDCReadableOnly)
  private
    FObjectList: TObjectList;
  protected
    function GetOwnsObjects(): Boolean;
    procedure SetOwnsObjects(Value: Boolean);
    function GetItem(Index: Integer): TObject; inline;
    procedure SetItem(Index: Integer; AObject: TObject);
  public
    constructor Create(ARWSynchronizer: TObject; AOwnsObjects: Boolean); reintroduce;
    destructor Destroy; override;
    function Add(AObject: TObject): Integer;
    function Extract(Item: TObject): TObject;
    function ExtractItem(Item: TObject; Direction: TList.TDirection): TObject;
    function Remove(AObject: TObject): Integer; overload;
    function RemoveItem(AObject: TObject; ADirection: TList.TDirection): Integer;
    function IndexOf(AObject: TObject): Integer; inline;
    function IndexOfItem(AObject: TObject; ADirection: TList.TDirection): Integer; inline;
    function FindInstanceOf(AClass: TClass; AExact: Boolean = True; AStartAt: Integer = 0): Integer;
    procedure Insert(Index: Integer; AObject: TObject);
    function First: TObject; inline;
    function Last: TObject; inline;
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
    property Items[Index: Integer]: TObject read GetItem write SetItem; default;
  end;

  // A Readable Only TStack Class
  TDCReadableOnlyStack = class(TDCReadableOnly)
  private
    FStack: TStack;
  public
    constructor Create(ARWSynchronizer: TObject); override;
    destructor Destroy; override;
    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    function Push(AItem: Pointer): Pointer;
    function Pop: Pointer;
    function Peek: Pointer;
  end;

  // A Readable Only TObjectStack Class
  TDCReadableOnlyObjectStack = class(TDCReadableOnly)
  private
    FObjectStack: TObjectStack;
  public
    constructor Create(ARWSynchronizer: TObject); override;
    destructor Destroy; override;
    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    function Push(AObject: TObject): TObject;
    function Pop: TObject;
    function Peek: TObject;
  end;

  // A Readable Only TQueue Class
  TDCReadableOnlyQueue = class(TDCReadableOnly)
  private
    FQueue: TQueue;
  public
    constructor Create(ARWSynchronizer: TObject); override;
    destructor Destroy; override;
    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    function Push(AItem: Pointer): Pointer;
    function Pop: Pointer;
    function Peek: Pointer;
  end;

  // A Readable Only TObjectQueue Class
  TDCReadableOnlyObjectQueue = class(TDCReadableOnly)
  private
    FObjectQueue: TObjectQueue;
  public
    constructor Create(ARWSynchronizer: TObject); override;
    destructor Destroy; override;
    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    function Push(AObject: TObject): TObject;
    function Pop: TObject;
    function Peek: TObject;
  end;

implementation

{ TDCAdlThreaded<T> }

constructor TDCAdlThreaded.Create(ADCReadableOnlyClass: TDCReadableOnlyClass; ALockType: TDCLockType);
begin
  inherited Create;
  FLockType := ALockType;
  case FLockType of
    ltAdlMREW: FLockObject := TDCAdlMultiReadExclusiveWriteSynchronizer.Create;
    ltCriticalSection: FLockObject := TCriticalSection.Create;
    ltMonitor: FLockObject := nil;
  end;
  FSharedObject := ADCReadableOnlyClass.Create(FLockObject);
end;

destructor TDCAdlThreaded.Destroy;
begin
  if (FLockType <> ltMonitor)
    then Lock(False {ReadOnly});
  try
    FreeAndNil(FSharedObject);
    inherited Destroy;
  finally
    if (FLockType <> ltMonitor)
      then Unlock;
    FreeAndNil(FLockObject);
  end;
end;

function TDCAdlThreaded.Lock(AReadOnly: Boolean): TDCReadableOnly;
begin
  case FLockType of
    ltAdlMREW: TDCAdlMultiReadExclusiveWriteSynchronizer(FLockObject).Lock(AReadOnly);
    ltCriticalSection: TCriticalSection(FLockObject).Acquire;
    ltMonitor: TMonitor.Enter(FSharedObject);
  end;
  Result := FSharedObject;
end;

procedure TDCAdlThreaded.Unlock;
begin
  case FLockType of
    ltAdlMREW: TDCAdlMultiReadExclusiveWriteSynchronizer(FLockObject).Unlock;
    ltCriticalSection: TCriticalSection(FLockObject).Release;
    ltMonitor: TMonitor.Exit(FSharedObject);
  end;
end;

{ TDCReadableOnly }

constructor TDCReadableOnly.Create(ARWSynchronizer: TObject);
begin
  inherited Create;
  FRWSynchronizer := ARWSynchronizer;
end;

procedure TDCReadableOnly.ToggleFromReadToWriteMode;
begin
  TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).Unlock;
  TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).Lock(False {ReadOnly});
end;

{ TDCReadableOnlyList }

function TDCReadableOnlyList.Add(Item: Pointer): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.Add(Item);
end;

procedure TDCReadableOnlyList.Assign(ListA: TList; AOperator: TListAssignOp; ListB: TList);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Assign(ListA, AOperator, ListB);
end;

procedure TDCReadableOnlyList.Clear;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Clear;
end;

constructor TDCReadableOnlyList.Create(ARWSynchronizer: TObject);
begin
  inherited Create(ARWSynchronizer);
  FList := TList.Create;
end;

procedure TDCReadableOnlyList.Delete(Index: Integer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Delete(Index);
end;

destructor TDCReadableOnlyList.Destroy;
begin
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TDCReadableOnlyList.Exchange(Index1, Index2: Integer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Exchange(Index1, Index2);
end;

function TDCReadableOnlyList.Expand: TList;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.Expand();
end;

function TDCReadableOnlyList.Extract(Item: Pointer): Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.Extract(Item);
end;

function TDCReadableOnlyList.ExtractItem(Item: Pointer; Direction: TDirection): Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.ExtractItem(Item, Direction);
end;

function TDCReadableOnlyList.First: Pointer;
begin
  Result := FList.First();
end;

function TDCReadableOnlyList.Get(Index: Integer): Pointer;
begin
  Result := FList.Items[Index];
end;

function TDCReadableOnlyList.GetCapacity: Integer;
begin
  Result := FList.Capacity;
end;

function TDCReadableOnlyList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDCReadableOnlyList.GetEnumerator: TListEnumerator;
begin
  Result := FList.GetEnumerator();
end;

function TDCReadableOnlyList.IndexOf(Item: Pointer): Integer;
begin
  Result := FList.IndexOf(Item);
end;

function TDCReadableOnlyList.IndexOfItem(Item: Pointer; Direction: TDirection): Integer;
begin
  Result := FList.IndexOfItem(Item, Direction);
end;

procedure TDCReadableOnlyList.Insert(Index: Integer; Item: Pointer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Insert(Index, Item);
end;

function TDCReadableOnlyList.Last: Pointer;
begin
  Result := FList.Last();
end;

procedure TDCReadableOnlyList.Move(CurIndex, NewIndex: Integer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Move(CurIndex, NewIndex);
end;

procedure TDCReadableOnlyList.Pack;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer)
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Pack();
end;

procedure TDCReadableOnlyList.Put(Index: Integer; Item: Pointer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Items[Index] := Item;
end;

function TDCReadableOnlyList.Remove(Item: Pointer): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.Remove(Item);
end;

function TDCReadableOnlyList.RemoveItem(Item: Pointer; Direction: TDirection): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FList.RemoveItem(Item, Direction);
end;

procedure TDCReadableOnlyList.SetCapacity(NewCapacity: Integer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Capacity := NewCapacity;
end;

procedure TDCReadableOnlyList.SetCount(NewCount: Integer);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Count := NewCount;
end;

procedure TDCReadableOnlyList.Sort(Compare: TListSortCompare);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.Sort(Compare);
end;

procedure TDCReadableOnlyList.SortList(const Compare: TListSortCompareFunc);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FList.SortList(Compare);
end;

{ TDCReadableOnlyObjectList }

function TDCReadableOnlyObjectList.Add(AObject: TObject): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectList.Add(AObject);
end;

constructor TDCReadableOnlyObjectList.Create(ARWSynchronizer: TObject; AOwnsObjects: Boolean);
begin
  inherited Create(ARWSynchronizer);
  FObjectList := TObjectList.Create(AOwnsObjects);
end;

destructor TDCReadableOnlyObjectList.Destroy;
begin
  FreeAndNil(FObjectList);
  inherited Destroy;
end;

function TDCReadableOnlyObjectList.Extract(Item: TObject): TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectList.Extract(Item);
end;

function TDCReadableOnlyObjectList.ExtractItem(Item: TObject; Direction: TList.TDirection): TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectList.ExtractItem(Item, Direction);
end;

function TDCReadableOnlyObjectList.FindInstanceOf(AClass: TClass; AExact: Boolean; AStartAt: Integer): Integer;
begin
  Result := FObjectList.FindInstanceOf(AClass, AExact, AStartAt);
end;

function TDCReadableOnlyObjectList.First: TObject;
begin
  Result := FObjectList.First;
end;

function TDCReadableOnlyObjectList.GetItem(Index: Integer): TObject;
begin
  Result := FObjectList.Items[Index];
end;

function TDCReadableOnlyObjectList.GetOwnsObjects: Boolean;
begin
  Result := FObjectList.OwnsObjects;
end;

function TDCReadableOnlyObjectList.IndexOf(AObject: TObject): Integer;
begin
  Result := FObjectList.IndexOf(AObject);
end;

function TDCReadableOnlyObjectList.IndexOfItem(AObject: TObject; ADirection: TList.TDirection): Integer;
begin
  Result := FObjectList.IndexOfItem(AObject, ADirection);
end;

procedure TDCReadableOnlyObjectList.Insert(Index: Integer; AObject: TObject);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FObjectList.Insert(Index, AObject);
end;

function TDCReadableOnlyObjectList.Last: TObject;
begin
  Result := FObjectList.Last;
end;

function TDCReadableOnlyObjectList.Remove(AObject: TObject): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectList.Remove(AObject);
end;

function TDCReadableOnlyObjectList.RemoveItem(AObject: TObject; ADirection: TList.TDirection): Integer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectList.RemoveItem(AObject, ADirection);
end;

procedure TDCReadableOnlyObjectList.SetItem(Index: Integer; AObject: TObject);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FObjectList.Items[Index] := AObject;
end;

procedure TDCReadableOnlyObjectList.SetOwnsObjects(Value: Boolean);
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  FObjectList.OwnsObjects := Value;
end;

{ TDCReadableOnlyStack }

function TDCReadableOnlyStack.AtLeast(ACount: Integer): Boolean;
begin
  Result := FStack.AtLeast(ACount);
end;

function TDCReadableOnlyStack.Count: Integer;
begin
  Result := FStack.Count;
end;

constructor TDCReadableOnlyStack.Create(ARWSynchronizer: TObject);
begin
  inherited Create(ARWSynchronizer);
  FStack := TStack.Create;
end;

destructor TDCReadableOnlyStack.Destroy;
begin
  FreeAndNil(FStack);
  inherited Destroy;
end;

function TDCReadableOnlyStack.Peek: Pointer;
begin
  Result := FStack.Peek();
end;

function TDCReadableOnlyStack.Pop: Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FStack.Pop();
end;

function TDCReadableOnlyStack.Push(AItem: Pointer): Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FStack.Push(AItem);
end;

{ TDCReadableOnlyObjectStack }

function TDCReadableOnlyObjectStack.AtLeast(ACount: Integer): Boolean;
begin
  Result := FObjectStack.AtLeast(ACount);
end;

function TDCReadableOnlyObjectStack.Count: Integer;
begin
  Result := FObjectStack.Count;
end;

constructor TDCReadableOnlyObjectStack.Create(ARWSynchronizer: TObject);
begin
  inherited Create(ARWSynchronizer);
  FObjectStack := TObjectStack.Create;
end;

destructor TDCReadableOnlyObjectStack.Destroy;
begin
  FreeAndNil(FObjectStack);
  inherited Destroy;
end;

function TDCReadableOnlyObjectStack.Peek: TObject;
begin
  Result := FObjectStack.Peek();
end;

function TDCReadableOnlyObjectStack.Pop: TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectStack.Pop();
end;

function TDCReadableOnlyObjectStack.Push(AObject: TObject): TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectStack.Push(AObject);
end;

{ TDCReadableOnlyQueue }

function TDCReadableOnlyQueue.AtLeast(ACount: Integer): Boolean;
begin
  Result := FQueue.AtLeast(ACount);
end;

function TDCReadableOnlyQueue.Count: Integer;
begin
  Result := FQueue.Count;
end;

constructor TDCReadableOnlyQueue.Create(ARWSynchronizer: TObject);
begin
  inherited Create(ARWSynchronizer);
  FQueue := TQueue.Create;
end;

destructor TDCReadableOnlyQueue.Destroy;
begin
  FreeAndNil(FQueue);
  inherited Destroy;
end;

function TDCReadableOnlyQueue.Peek: Pointer;
begin
  Result := FQueue.Peek();
end;

function TDCReadableOnlyQueue.Pop: Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FQueue.Pop();
end;

function TDCReadableOnlyQueue.Push(AItem: Pointer): Pointer;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FQueue.Push(AItem);
end;

{ TDCReadableOnlyObjectQueue }

function TDCReadableOnlyObjectQueue.AtLeast(ACount: Integer): Boolean;
begin
  Result := FObjectQueue.AtLeast(ACount);
end;

function TDCReadableOnlyObjectQueue.Count: Integer;
begin
  Result := FObjectQueue.Count;
end;

constructor TDCReadableOnlyObjectQueue.Create(ARWSynchronizer: TObject);
begin
  inherited Create(ARWSynchronizer);
  FObjectQueue := TObjectQueue.Create;
end;

destructor TDCReadableOnlyObjectQueue.Destroy;
begin
  FreeAndNil(FObjectQueue);
  inherited Destroy;
end;

function TDCReadableOnlyObjectQueue.Peek: TObject;
begin
  Result := FObjectQueue.Peek();
end;

function TDCReadableOnlyObjectQueue.Pop: TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectQueue.Pop();
end;

function TDCReadableOnlyObjectQueue.Push(AObject: TObject): TObject;
begin
  If Assigned(FRWSynchronizer) and (FRWSynchronizer is TDCAdlMultiReadExclusiveWriteSynchronizer) 
    and (TDCAdlMultiReadExclusiveWriteSynchronizer(FRWSynchronizer).ReadOnly)
    then ToggleFromReadToWriteMode();
  Result := FObjectQueue.Push(AObject);
end;

{ TDCAdlMultiReadExclusiveWriteSynchronizer }

constructor TDCAdlMultiReadExclusiveWriteSynchronizer.Create;
begin
  inherited Create;
  FReadOnly := False;
end;

procedure TDCAdlMultiReadExclusiveWriteSynchronizer.Lock(AReadOnly: Boolean);
begin
  if AReadOnly
    then BeginRead
    else BeginWrite;
  FReadOnly := AReadOnly;
end;

procedure TDCAdlMultiReadExclusiveWriteSynchronizer.Unlock;
begin
  if FReadOnly
    then EndRead
    else EndWrite;
end;

end.

