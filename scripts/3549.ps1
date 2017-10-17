param(
$RootFolder = "\\server1\users",
$NewRootFolder = "\\server2\users",
$LogFolder = "C:\Projects\HomeDirs",
$NewSubFolders = @("Documents","Favorites","Desktop","Links","Contacts"),
$domain = "domain",
[switch]$SetACL
)
$UserFolders = gci -Path $RootFolder | ?{$_.PSIsContainer}
$UserFolders | foreach-object -Process {
	#create new homedrive
	$NewUserFolder =  $NewRootFolder + "\" + $_.name
	New-Item -Path $NewUserFolder -ItemType "Directory"
	if ($SetACL){
		#set ACL rules for new homedrive
		$acl = Get-Acl $NewUserFolder
		$Owner = New-Object System.Security.Principal.NTAccount($domain, $_.name)
		#$acl.SetOwner($Owner) #not possible with set-acl
		$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Owner,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
		$acl.SetAccessRule($rule)
		Set-Acl $NewUserFolder $acl
		}
	#create required subfolders per homedrive
	$NewSubFolders | foreach{New-Item -Path $($NewUserFolder + "\" + $_) -type directory}
	#build robocopy job per homedrive
	$LogFile = $LogFolder + "\" + $_.name + ".log"
	$JobName = $_.name + "_RCsync"
	$CommandString = "robocopy $($_.FullName) $($NewUserFolder + "\Documents") /COPYALL /MIR /FFT /Z /Log+:$LogFile"
	start-job -Scriptblock {invoke-Expression $input} -name $JobName -InputObject $CommandString
    }
#Wait for all jobs
Get-Job | Wait-Job
#Get all job results
Get-Job | Receive-Job
