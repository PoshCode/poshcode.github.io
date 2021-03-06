We have 3 HV Hosts. One is a free standing system, and the other two form our main system hosting all VMS. I am trying initially to backup a VM on the "sandbox" machine, but I receive the following output...

PS C:\scripts> Backup-VMs -BackupDriveLetter x -VMHost sandbox -VMNames hillsbox -Verbose
Starting Hyper-V virtual machine backup for host sandbox at:
03/20/2014 11:45:12

Attempting to backup the following VMs:
HILLSBOX

Do not cancel the export process as it may cause unpredictable VM behavior
Get-WmiObject : Invalid namespace "root\virtualization"
At C:\program files\modules\hyperv\VM.ps1:70 char:13
+             Get-WmiObject -computername $Server -NameSpace $HyperVNamespace -Que ...
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Get-WmiObject], ManagementException
    + FullyQualifiedErrorId : GetWMIManagementException,Microsoft.PowerShell.Commands.GetWmiObjectCommand

T : Missing an argument for parameter 'text'. Specify a parameter of type 'System.String' and try again.
At C:\program files\modules\backup-vms.ps1:497 char:8
+                     T -text
+                       ~~~~~
    + CategoryInfo          : InvalidArgument: (:) [T], ParameterBindingException
    + FullyQualifiedErrorId : MissingArgument,T

HeartBeat Service for HILLSBOX is responding . Save state and export aborted for HILLSBOX

Exporting finished

Finished backup of sandbox at:
03/20/2014 11:45:13
The operation took 0.01 minutes

Any ideas?
