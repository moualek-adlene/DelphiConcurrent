# DelphiConcurrent

<em>DelphiConcurrent</em> is a new way to build Delphi applications which involve parallel code based on threads like applications servers.</br>
<em>DelphiConcurrent</em> provide to the programmers the internal mechanisms to write safer multi-thread code while taking a special care of performance and genericity.</br>

The main goals of this API are the following :</br>
<h3>1- Detect and Prevent DEADLOCKs before they occurs :</h3>
With <em>DelphiConcurrent</em>, a DEADLOCK is detected and automatically skipped - before he occurs - and the programmer has an explicit exception describing the multi-thread problem instead of a blocking DEADLOCK which kill the server with no output log;</br>
<h3>2- Detect Remaining Locks :</h3>
Every time a programmer lock a shared resource on a parallel application like a server he must explicitly don't forget to unlock this resource to make it available again to others threads on the application. But a programmer is a human being and in a big or complex application he can easily forget to do that in some cases. <em>DelphiConcurrent</em> handle this problem also by keeping trace of the programmer lock/unlook sequences and throwing an exception every time a shared resource is not unlocked at the good moment.</br>
<h3>3- Detect Bad Unlocks Sequences :</h3>
This is more an additional comfort than a real problem, because a programmer is not theoretically constrained to unlock a set of shared resources in a special order, but it is a good practice to do that in the correct order. So, <em>DelphiConcurrent</em> will also throws an exception every time the good unlock order is not respected.</br>
<h3>4- Provide High-Performance threading model based on the MRER model :</h3>
<em>DelphiConcurrent</em> implements the Multi-Read Exclusive-Write (MRER) threads synchronization model. This model of parallel threads execution is more efficient than the others synchronization schemas based on Critical-Sections or Monitors because it doesn't prevent parallel threads from reading at the same time from a shared resource, exclusive access is only needed when writing on the resource. The MRER is therefore the default synchronization model used in <em>DelphiConcurrent</em>, however others synchronization schemas (Critical-Sections and Monitors) are also implemented and can be easily used if necessary.</br>
