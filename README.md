# DelphiConcurrent

<p><em>DelphiConcurrent</em> is a new way to build Delphi applications which involve parallel executed code based on threads like applications servers. <em>DelphiConcurrent</em> provide to the programmers the internal mechanisms to write safer multi-thread code while taking a special care of performance and genericity.
</p>

<p>The main goals of this API are the following :</br>
<h3>1- Detect and Prevent DEADLOCKs before they occurs :</h3>
With <em>DelphiConcurrent</em>, a DEADLOCK is detected and automatically skipped - before he occurs - and the programmer has an explicit exception describing the multi-thread problem instead of a blocking DEADLOCK which kills the server with no output log.</br>
As a reminder, a DEADLOCK may occurs when two threads or more try to lock two consecutive shared resources or more but in a different order.
</p>

<p><h5>Example:</h5>
Suppose we have two threads <b>A</b> and <b>B</b>, and two shared resources <b>1</b> and <b>2</b>.</br>
Threads <b>A</b> and <b>B</b> sequences are the following :</br>
<table>
    <tr>
        <td><b>Thread(A)</b></td> <td><b>Thread(B)</b></td>
    </tr>
    <tr>
        <td>Resource(1).Lock</td> <td>Resource(2).Lock</td>
    </tr>
    <tr>
        <td>Resource(2).Lock</td> <td>Resource(1).Lock</td>
    </tr>
    <tr>
        <td>Some work on resources...</td> <td>Some work on resources...</td>
    </tr>
    <tr>
        <td>Resource(2).UnLock</td> <td>Resource(1).UnLock</td>
    </tr>
    <tr>
        <td>Resource(1).UnLock</td> <td>Resource(2).UnLock</td>
    </tr>
</table>
</p>
<p>When threads <b>A</b> and <b>B</b> start their parallel execution, the thread <b>A</b> owns exclusive access to resource <b>1</b> while the thread <b>B</b> does the same for the resource <b>2</b>. The DEADLOCK will occurs in the second step, when the thread <b>A</b> will wait for getting access to resource <b>2</b> while the thread <b>B</b> wait for getting access to resource <b>1</b>. From this moment, the threads are mutually blocked for ever.
</p>
<p>
<em>DelphiConcurrent</em> can protect the threads from this DEADLOCK by a correct monitoring of the lock/unlock sequences and an explicit exception object raised when the problem is detected (this is done even if the DEADLOCK does not occurs).
</p>

Line n°1: DeadLockTester Thread A Started
Line n°2: DeadLockTester Thread B Started
Line n°3: Thread A Before Lock for Resource 1
Line n°4: Thread B Before Lock for Resource 2
Line n°5: Thread A After Lock for Resource 1
Line n°6: Thread B After Lock for Resource 2
Line n°7: Thread A Before Lock for Resource 2
Line n°8: Thread B Before Lock for Resource 1
Line n°9: Thread A After Lock for Resource 2
Line n°10: Thread A Before UnLock for Resource 2
Line n°11: Thread A After UnLock for Resource 2
Line n°12: Thread A Before UnLock for Resource 1
Line n°13: Thread A After UnLock for Resource 1
Line n°14: DeadLockTester Thread A Terminated
Line n°15: Exception "TDCDeadLockException" on Thread B : Possible deadLock detected. The global lock order is not respected.
Line n°16: Exception "TDCRemainingLocksException" on Thread B : The stack is not empty in the local execution context (1 remaining locks).
Line n°17: DeadLockTester Thread B Terminated

<p><h3>2- Detect Remaining Locks :</h3>
Every time a programmer lock a shared resource on a parallel application like a server he must explicitly don't forget to unlock this resource to make it available again to others threads on the application. But a programmer is a human being and in a big or complex application he can easily forget to do that in some cases. <em>DelphiConcurrent</em> handle this problem also by keeping trace of the programmer lock/unlook sequences and throwing an exception every time a shared resource is not unlocked at the good moment.
</p>

<p><h3>3- Detect Bad Unlocks Sequences :</h3>
This is more an additional comfort than a real problem, because a programmer is not theoretically constrained to unlock a set of shared resources in a special order, but it is a good practice to do that in the correct order. So, <em>DelphiConcurrent</em> will also throws an exception every time the good unlock order is not respected.
</p>

<p><h3>4- Provide High-Performance threading model based on the MREW model :</h3>
<em>DelphiConcurrent</em> implements the Multi-Read Exclusive-Write (MREW) threads synchronization model. This model of parallel threads execution is more efficient than the others synchronization schemas based on Critical-Sections or Monitors because it doesn't prevent parallel threads from reading at the same time from a shared resource, exclusive access is only needed when writing to the resource. The MREW is therefore the default synchronization model used in <em>DelphiConcurrent</em>, however others synchronization schemas (Critical-Sections and Monitors) are also implemented and can be easily used if necessary.
</p>

<p>The API is encapsulated in the Delphi Unit named "DelphiConcurrent.pas".</br>
A running Delphi example (Project and Binary) is available in the repository in order to see how this API works. The example is build on Delphi 10.1 Berlin Edition.
</p>
