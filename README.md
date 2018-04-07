# DelphiConcurrent

<p>
	<em>DelphiConcurrent</em> is a new way to build Delphi applications which involve parallel executed code based on threads like application servers. <em>DelphiConcurrent</em> provide to the programmers the internal mechanisms to write safer multi-thread code while taking a special care of performance and genericity.
</p>

<h2>The main goals of this API are the following :</h2>

<p>
	<h3>1- Detect and Prevent DEADLOCKs before they occurs :</h3>
	In concurrent applications a DEADLOCK may occurs when two threads or more try to lock two consecutive shared resources or more but in a different order.
	With <em>DelphiConcurrent</em>, a DEADLOCK is detected and automatically skipped - before he occurs - and the programmer has an explicit exception describing the multi-thread problem instead of a blocking DEADLOCK which freeze the application with no output log (and perhaps also the linked clients if we talk about an application server).
</p>

<p>
	<h4>Example 1:</h4>
	Suppose we have two threads <b>A</b> and <b>B</b>, and two shared resources <b>1</b> and <b>2</b>.</br>
	Threads <b>A</b> and <b>B</b> execution sequences are the following :</br>
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

<p>
	When threads <b>A</b> and <b>B</b> start their parallel execution, the thread <b>A</b> owns exclusive access to resource <b>1</b> while the thread <b>B</b> does the same for the resource <b>2</b>. The DEADLOCK will occurs in the second step, when the thread <b>A</b> will wait indefinitely for getting access to resource <b>2</b> while the thread <b>B</b> wait indefinitely also for getting access to resource <b>1</b>. From this moment, the two threads are mutually blocked forever.
</p>

<p>
	Every programmer knows that DEADLOCKs are very difficult to detect because of two factors :</br>
	<p>
		A- <b>The probability that a DEADLOCK occurs is not 100% :</b></br>
		A same written multi-threaded code can run in many ways showing a different behaviour sometime or everytime (we can have 100 running threads for example or 100 shared resources in our application).</br>
		In example 1, the thread <b>A</b> may successfully lock the resources <b>1</b> and <b>2</b> before that the thread <b>B</b> is created or before that the thread <b>B</b> try to lock the resource <b>2</b>.</br>
		This is a big engineering problem, because that means that code quality cannot be guaranteed simply by running test cases. The programmer may deliver to the client a code where he haven't found any error while testing it and some weeks later, the client is furious because the application (may be a server) freeze repeatedly and he must restart it eachtime the problem occurs, and the log file mysteriously doesn't show anything...
	</p>
	<p>
		B- <b>A DEADLOCK leaves no trace :</b></br>
		Threads are like human beings, they can't talk after they are dead !. Mutually blocked threads will not fire any exception saying 'We are blocked', they will just freeze forever. No exception means also no entry in the log output, so analysing the application log file will not help to discover or resolve the problem.</br>
		Moreover, some of the locked resources may be critical which means that these resources may by used globally by the others application threads and this will lead to an overall application failure progressively (deny of service).
	</p>
</p>

<p>
	<em>DelphiConcurrent</em> can protect the threads from DEADLOCKs by a correct monitoring of the lock/unlock sequences at runtime and an explicit exception raised when the problem is detected. This is done with a probability of 100% even if the DEADLOCK doesn't occurs, hence the code quality (the thread safety part) is guaranteed at project end.
</p>

<p>
	<h3>2- Detect Remaining Locks :</h3>
	Every time a programmer locks a shared resource on a concurrent application he must explicitly don't forget to unlock this resource to make it available again to others threads on the application. But a programmer is a human being and in a big or complex application he can easily forget to do that in some cases which will make one or more resources definitely inavailable to others threads with no exception (no log entry). It happens sometimes also that the programmer inserts -by mistake- a lock command in his source code instead of the unlock command needed. <em>DelphiConcurrent</em> handle this problem also by keeping trace of the programmer lock/unlook sequences and throwing an exception every time a shared resource is not unlocked at the good moment.
</p>

<p>
	<h3>3- Detect Bad Unlocks Sequences :</h3>
	This is more an additional comfort than a real problem, because a programmer is not theoretically constrained to unlock a set of shared resources in a special order, but it is a good practice to do that in the correct order (which is the reverse of the lock order). So, <em>DelphiConcurrent</em> will also throws an exception every time the good unlock order is not respected.
</p>

<p>
	<h3>4- Provide High-Performance threading model based on the MREW model :</h3>
	<em>DelphiConcurrent</em> implements the Multi-Read Exclusive-Write (MREW) threads synchronization model. This model of parallel threads execution is more efficient than the others synchronization schemas based on Critical-Sections or Monitors because it doesn't prevent parallel threads from reading at the same time from a shared resource, exclusive access is only needed when writing to the resource. The MREW is therefore the default synchronization model used in <em>DelphiConcurrent</em>, however others synchronization schemas (Critical-Sections and Monitors) are also implemented and can be easily used if necessary.
</p>

<h2>DelphiConcurrent API Presentation :</h2>

<p>
	The API is encapsulated in the Delphi Unit named "DelphiConcurrent.pas".</br>
	A running Delphi example (Project and Binary) is available in the GitHub repository in order to see how this API works. The example is build on Delphi 10.1 Berlin Edition.
</p>

<p>
	<em>DelphiConcurrent</em> uses the concept of "<b>Lock on resource</b>" rather than "<b>Lock on code</b>" because it is impossible to guarantee a zero-fault multi-threaded code if we leave the control to the programmer (or the development team) for managing the kind of problems described before.
	DEADLOCKs or Forgotten-LOCKs especially must be detected <b>By Design</b> and not just if they occurs someday.
</p>

<p>
	Each shared resource is represented in <em>DelphiConcurrent</em> by an instance of a class derived from the class <b>TDCProtected</b>. We can use for example the <b>TDCProtectedList</b> sub-class to have a thread-safe <b>TList</b> that way.</br>
	This shared resource will not be accessible directly at runtime, rather it will be encapsulated in an object of the class <b>TDCProtector</b> which associate the protected resource to some lock object or mechanism. This last may be a <b>Monitor</b> or an instance of the class <b>TCriticalSection</b> or <b>TDCMultiReadExclusiveWriteSynchronizer</b>.
</p>

<p>
	In theory, if we want to avoid DEADLOCKs in your concurrent code, we must ensure that resources are locked in the same order everytime we access them, in every portion of your source code. But in practice, this is very difficult to achieve, because a real application is made of different units (modules) each one containing perhaps some shared resources, and some of these resources may be allocated dynamically (not enumerated at design step), and as that was not enough there is maybe many programmers involved in the project and no programmer has a clear vision from start of what lock order must be respected by all the team.</br>
	This is way each resource in <em>DelphiConcurrent</em> will have a global order which determines at which moment we can access it compared to other resources (of all application modules). This global order is stored in the read-only property <b>TDCProtector.LockOrder</b> and will correspond (by convention) to the global creation order of shared resources at runtime.
</p>

<p>
	<em>DelphiConcurrent</em> introduce a Local-Execution-Context class named <b>TDCLocalExecContext</b> to monitor the overall lock/unlock sequences in each running thread. As indicated by his name, each allocated context is local to his thread (Don't try to share those contexts between threads). The <b>TDCLocalExecContext</b> keeps an eye on each lock/unlock instruction and will throws an exception if any problem is detected. It is it's responsibility to detect and prevent DEADLOCKs.
</p>

<p>
	A typical <em>DelphiConcurrent</em> API use will be the following :</br>
	
	// Some shared resource declared and allocated somewhere (in main-unit for example)
	var
		GSharedResource: TDCProtector;
	begin
		// we need for example, a thread-safe TList, and
		// we choose to protect it with a Multi-Read Exclusive-Write Synchronizer
		GSharedResource := TDCProtector.Create(TDCProtectedList, ltMREW);
		try
			Thread(X, GSharedResource).Start;
			Thread(X).WaitFor;
		finally
			GSharedResource.Free;
		end;
	end;
	
	// Some Thread(X) implementation
	var
		LExecContext: TDCLocalExecContext;
		LResourcePointer: TDCProtectedList;
	begin
		LExecContext := TDCLocalExecContext.Create;
		try
			try
				LResourcePointer := GSharedResource.Lock(LExecContext);
				try
					<Some work with the shared resource LResourcePointer ...>
				finally
					GSharedResource.UnLock(LExecContext);
				end;
			except
				on e1:Exception	do NotifyToUI('Exception "' + e1.ClassName + '" : ' + e1.message);
			end;
		finally
			LExecContext.Free;
		end;
	end;
</p>

<p>
	The running Delphi example available in the GitHub repository handles some advanced topics like how to automatically react to a DEADLOCK. We can for example, not just fill a log file or show a message on the screen but also release any previously locked resources (unlock them) to -at least- restore those resources to others threads (look at the implementation of the procedure <b>TDeadLockTester.Execute</b> in the <b>ThreadsUnit.pas</b> for that).
</p>

<p>
	<h3>DelphiConcurrent Exceptions Classes :</h3>
	All the <em>DelphiConcurrent</em> exception classes derive from the <b>TDCException</b> class.</br>
	We distinguish the following exceptions :</br>
	<p>
		1- <b>TDCDeadLockException</b> :</br>
		The <em>DelphiConcurrent</em> API will throws this kind of exception whenever the <b>global lock order</b> is not respected. Programmers involved in a project managed with the <em>DelphiConcurrent</em> API must lock the shared resources following their <b>creation order</b> in memory. Which means that if the Resource <b>1</b> is created before the Resource <b>2</b> in memory than every thread which need to work on both resources at the same time must lock the Resource <b>1</b> before the Resource <b>2</b> and not the reverse.
	</p>
	<p>
		2- <b>TDCRemainingLocksException</b> :</br>
		Before a <b>TDCLocalExecContext</b> is destroyed, it will check that there is <b>no remaining active locks</b> and will throws this kind of exception if the problem is detected.
	</p>
	<p>
		3- <b>TDCBadUnlockSequenceException</b> :</br>
		The <em>DelphiConcurrent</em> API will throws an exception every time the good unlock order is not respected (which is the reverse of the lock order).
	</p>
</p>

<p>
	Work is in progress to achieve this API. Currently, many basic Delphi classes have been wrapped with this API (<b>TList</b>, <b>TObjectList</b>, <b>TStack</b>, <b>TObjectStack</b>, <b>TQueue</b> and <b>TObjectQueue</b>). Next step will be to do the same for generic versions of those classes (<b>System.Generics.Collections</b>).
</p>
