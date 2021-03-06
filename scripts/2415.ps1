###################################################################################################
#
# NAME: NBU-BackupReport.ps1
#
# AUTHOR: Martijn Jonker
#
# COMMENT: Script to create a backup report from Netbackup jobs on windows platform.
# Adjust variables below this section.
# The script generates a report every weekday. Monday report covers the weekend.
# To adjust this, edit lines 94-103 and 483-490
#
# The script calls Netbackup commandline tools to gather information.
# Job status is checked against three different arrays (Successful, partial, failed).
# Depending on Status, Client, Policy, Schedule and EndTime lines are either added to or
# removed from the arrays.
# The script gathers statistics per policy/server about the backup operation,
# (number of files backed up,size of files backed up and elapsed time),
# so servers is multiple policies will show up multiple times in the statistics.
# The script reports tape media and disk storage unit usage.
# The script e-mails the result
#
# Run the script interactively, or as a scheduled task.
#
# The script requires "<Programdir>\NetBackup\bin\admincmd" and
# "<Programdir>\NetBackup\bin\goodies" to be in the %path% ($Env:path) environment variable
# 
# The script was tested with NetBackup 6.5, 6.5.5 and 7.0,
# in a single master/media server environment.
#
# VERSION HISTORY:
# 1.0: Transcoded from .vbs to .ps1
# 1.1: Added E-mail notification
# 2.0: Rewrote logic for better efficiency
# 2.1: Minor tweaks to date/time formatting
# 3.0: Added Tape Media used for backup
#      Added Storage Unit Status
#      Added Backup statictics
# 3.1: Documented script
#      Minor efficiency tweaks
###################################################################################################
# --------------------------- Adjust variables below to suit your needs --------------------------- #
$StartTime = "17:00:00" # Starttime for backup operation, in NBU format
$Endtime = "17:00:00" # Endtime for backup operation, in NBU format
$OutputPth = "C:\scripts" # Path to $outputfile
$OutputFile = "BackupReport.txt" # Name of outputfile
$SmtpServer = "smtp.server" # Address of SMTP server
$From = "netbackup@company.com" # From e-mail address
$To = "report@company.com" # To e-mail address. Multiple addresses can be used, seperate by comma
$CC = "CC-Recipients.txt" # Textfile containing e-mail addresses to CC, one per line. Located in $outputpth
$ClientStringLength = 15 # Number of characters in the $client string, including whitespace
$PolicyStringLength = 25 # Number of characters in the $Policy string, including whitespace
$FileStringLength = 10 # Number of characters in the $Files string, including whitespace
$KBStringLength = 12 # Number of characters in the $KBs string, including whitespace
$ElapsedString = 10 # Number of characters in the $Elapsed string, including whitespace
#
# !> ---------------------------! Do not change anything beyond this point !--------------------------- <!
#
Switch (Test-Path $OutputPth) # Check if $OutputPth exists
{
 False # If $OutputPth does not exist
 {
  New-Item $OutputPth -ItemType Directory | Out-Null # Create $OutputPth
  Write-Host "Output Path did not exist, it was created: $OutputPth" -ForegroundColor "White" # Write to console
  Write-Host "----------" -ForegroundColor "Yellow" # Write to console
 }
}
$OutputStr = $OutputPth + "\" + $OutputFile # Combine $OutputPth and $OutputFile to a single string
# ---
$JobHeader = "STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED" # General header for backup job status
$ClientNotReported = @("";"Servers that did not (yet) report any activity";"----------------------------------------------";("CLIENT"+" "*($ClientStringLength-6))+("POLICY"+" "*($PolicyStringLength-6))) # initialize array for servers that did not report activity at the time of running the report and add header
$TotalOK = @() # Initialize array to contain the final results for all successful jobs
$TotalPartial = @() # Initialize array to contain the final results for all partially successful jobs
$TotalFail = @() # Initialize array to contain the final results for all failed jobs
$UsedPolSched = @() # Initialize array to contain policies and schedules used during backup operation, used to report on disk storageunits.
# ---
$NBU_BaseTime = get-date "1/1/1970 00:00:00" # Netbackup Basetime, used to calculate elapsed time
$TotalFiles = 0 # Initialize variable to contain the total number of files backed up
$TotalKB = 0 # Initialize variable to contain the total KiloBytes backed up
$NBUStats = @() # Initialize array to contain the backup operation statistics
$NBUStatsHeader = @("";"BACKUP STATISTICS";("CLIENT"+" "*($ClientStringLength-6))+("POLICY"+" "*($PolicyStringLength-6))+("FILES"+" "*($FileStringLength-5))+("SIZE"+" "*($KBStringLength-4))+("ELAPSED"+" "*($ElapsedString-7))) # Array containing header for backup statistics
$NBUStatsHeader += @("-"*$NBUStatsHeader[2].Length) # Add separator
# ---------------------------
Clear-Host
# Set the console foreground color
[console]::ForegroundColor = "White"
# --------------------------- write to console
Write-Host ""
Write-Host "============================================================" -ForegroundColor "Yellow"
Write-Host "                  NetBackup - Daily Report"
Write-Host "============================================================" -ForegroundColor "Yellow"
Write-Host ""
Write-Host ""
# ---------------------------
$Now = Get-date # Store current date and time
If (($Now.DayOfWeek -eq "Tuesday") -OR ($Now.DayOfWeek -eq "Wednesday") -OR ($Now.DayOfWeek -eq "Thursday") -OR ($Now.DayOfWeek -eq "Friday")) # For every weekday except monday
{
 $StartDate = "{0:MM\/dd\/yyyy $StartTime}" -f ($Now.AddDays(-1)) # set the startdate back one day, using the previously set starttime
}
If ($Now.DayOfWeek -eq "Monday") # For every monday
{
 $StartDate = "{0:MM\/dd\/yyyy $StartTime}" -f ($Now.AddDays(-3)) # set the startdate back three days (to encompass the weekend), using the previously set starttime
}
$EndDate = "{0:MM\/dd\/yyyy $Endtime}" -f ($Now) # set the enddate to today, using the previously set endtime
# ---------------------------
$NbuPolicyList = Invoke-Expression "bppllist" # Using NBU cmd get a list of all policies
ForEach ($Policy in $NbuPolicyList) # Process all listed policies
{
 # ---
 $OKHeader = @("";"Successful jobs during the $Policy backup") # header to add to below declared array
 $OKHeader += @("-"*$OKHeader[1].Length) # Add variable length horizontal separator
 $JobOK = New-Object System.Collections.ArrayList # Array to contain successful jobs
 $JobOK.Add($OKHeader) | Out-Null # Add header to array
 $JobOK.Add($JobHeader) | Out-Null # Add general header to array
 $JobOKCount=1 # Record count in array
 # ---
 $PartialHeader = @("";"Partially Successful jobs during the $Policy backup") # header to add to below declared array
 $PartialHeader += @("-"*$PartialHeader[1].Length) # Add variable length horizontal separator
 $JobPartial = New-Object System.Collections.ArrayList # Array to contain partially successful jobs
 $JobPartial.Add($PartialHeader) | Out-Null # Add header to array
 $JobPartial.Add($JobHeader) | Out-Null # Add general header to array
 $JobPartialCount=1 # Record count in array
 # ---
 $FailHeader = @("";"Failed jobs during the $Policy backup") # header to add to below declared array
 $FailHeader += @("-"*$FailHeader[1].Length) #Add variable length horizontal separator
 $JobFail = New-Object System.Collections.ArrayList # Array to contain failed jobs
 $JobFail.Add($FailHeader) | Out-Null # Add header to array
 $JobFail.Add($JobHeader) | Out-Null # Add general header to array
 $JobFailCount=1 # Record count in array
 # ---
 If ($Policy.Length -gt 16) # If policy name is longer than 16 chars
 {
  $PolicyFilter = $Policy.SubString(0,16).Trim() # Trim policy name down to 16 chars
 }
 Else
 {
  $PolicyFilter = $Policy
 }
 $PolicyDetails = Invoke-Expression "bppllist $Policy -L" # Using NBU cmd get policy details
 $PolicyActive =  $PolicyDetails | Select-String "Active" | %{$_.ToString().SubString(19).Trim()} # From policy details, get the policy status
 $PolicyType = $PolicyDetails | Select-String "Policy Type:" | %{$_.ToString().SubString(19).Trim()} # From policy details, get the policy type
 If ($PolicyActive -eq "yes") # If policy is active, process it, inactive policies are not processed
 {
  $PolicyClientList = $PolicyDetails | select-String "Client/HW/OS/Pri:" | Sort-Object # From policy details, get the list of clients
  ForEach ($ClientStr in $PolicyClientList)
  {
   $Client = $ClientStr.ToString().Split()[2] # Extrapolate Client name
   If ($Client.Length -gt $ClientStringLength) # For report makeup check lenght of the string
   {
	$ClientStringLength = $Client.Length+3 # If necessary add three characters whitespace to the string
   }
   $ClientJobList = Invoke-Expression "bperror.exe -client $Client -U -backstat -s info -d $StartDate -e $EndDate 2>&1"  | Select-String " $PolicyFilter" # Using NBU cmd get the jobs for currently processing client and narrow the selection of jobs to the currently processing policy
   #-- Start Statistics gathering for the currently processing policy and the currently processing client
   $ClientImages = Invoke-Expression "bpimagelist -client $Client -d $StartDate -e $EndDate 2>&1" | Select-String $Policy # Using NBU cmd get backup images for the currently processing client narrowed by the currently processing policy
   If (($ClientImages) -AND ($ClientImages.GetType().Name -ne "ErrorRecord")) # If backup images are available
   {
	ForEach ($Image in $ClientImages) # Process each backup image
    {
	 $Image = $Image.ToString().Split() # Convert the current backup image line to a string and split the string at every space
	 [Int32]$Files = $Image[19] # From the split string, get the number of files at row 19
	 [Int32]$KBs = $Image[18] # From the split string, get the KiloBytes at row 18
	 [Int32]$JobStart = $Image[13] # From the split string, get the start time (relative to the NBU_BaseTime in seconds) at row 13
     [Int32]$JobEnd = ($JobStart+[Int32]$Image[14]) #  From the split string, add the elapsed seconds at row 14 to the jobstart variable to get the endtime (relative to the NBU_BaseTime in seconds)
	 $JobStartTime = $NBU_BaseTime.AddSeconds($JobStart) # Add the seconds from jobstart to NBU_BaseTime to get a datetime object for starttime
     $JobEndTime = $NBU_BaseTime.AddSeconds($JobEnd) # Add the seconds from jobend to NBU_BaseTime to get a datetime object for endtime
	 $ElapsedTime = New-TimeSpan $JobStartTime $JobEndTime # Get a timespan for the elapsed time
	 $TotalElapsedTime = ($TotalElapsedTime+$ElapsedTime) # Add the timespan to the total elapsed time for this policy
	 $TotalFiles = ($TotalFiles+$Files) # Add the number of files to the total file count for this policy
	 $TotalKB = ($TotalKB+$KBs) # Add the KiloBytes to the total KiloBytes for this policy
	}
	$TotalKB = ($TotalKB*1024) # mulitply by 1024
	$GrandTotalKB = ($GrandTotalKB+$TotalKB) # Add totalkb to GrandTotalKB, aggregate for all policies
	$GrandTotalFiles = ($GrandTotalFiles+$TotalFiles) # Add totalfiles to GrandTotalFiles, aggregate for all policies
	If ($TotalKB -lt 1048576) # Format TotalKB to reflect:
	{
	 $TotalKBs = "{0:N} KB" -f $($TotalKB/1KB) # KiloBytes or,
	}
    If (($TotalKB -ge 1048576) -AND ($TotalKB -lt 1073741824))
	{
	 $TotalKBs = "{0:N} MB" -f $($TotalKB/1MB) # MegaBytes or,
	}
	If (($TotalKB -ge 1073741824) -AND ($TotalKB -lt 1099511627776))
 	{
	 $TotalKBs = "{0:N} GB" -f $($TotalKB/1GB) # GigaBytes or,
	}
	If ($TotalKB -ge 1099511627776)
    {
     $TotalKBs = "{0:N} TB" -f $($TotalKB/1TB) # TeraBytes
    }
    $TotalFiles = "{0:N0}" -f $TotalFiles # format the number for further processing
    $StatString = ($Client+" "*($ClientStringLength-$Client.Length))+($Policy+" "*($PolicyStringLength-$Policy.Length))+($TotalFiles+" "*($FileStringLength-$TotalFiles.Length))+($TotalKBs+" "*($KBStringLength-$TotalKBs.Length))+"$TotalElapsedTime" # Create a String per server, per policy with the following fields: CLIENT,POLICY,FILES,SIZE,ELAPSED
    $NBUStats += @($StatString) # Add the above string to the NBUStats array
	$TotalFiles = 0 # Reset variable
    $TotalKB = 0 # Reset variable
	$TotalKBs = 0 # Reset variable
	Clear-variable TotalElapsedTime # Reset variable
   }
   # --- End Statistics gathering
   If ($ClientJobList) # Process backup jobs for currently processing client if they are available
   {
	$ClientReported += @("$Client`t$PolicyType") # Add the client and policy name to array for checking
	ForEach ($Job in $ClientJobList) # Process each job
    {
     $Job = [String]$Job # Stringify the job
	 $StatusCode = $Job.SubString(0,7).Trim() # From string $job, extract statuscode
     If (($StatusCode -eq "STATUS") -OR (!$StatusCode)) # If $statuscode equals "status" or is emtpy
     {
      Continue # Skip this job
     }
     Else
     {
      $StatusCode = [Int]$StatusCode # Set statuscode as integer
     }
     $JobClient = $Job.SubString(7,14).Trim() # From string $job, extract clientname
     $JobPolicy = $Job.SubString(21,17).Trim() # From string $job, extract policyname
     $JobSchedule = $Job.SubString(38,11).Trim() # From string $job, extract schedule
	 If ($JobSchedule -match "Default") # If schedule matches "default",
	 {
	  Continue # skip this job
	 }
	 If ($UsedPolSched -notcontains "$Policy,$JobSchedule") # If this policy and schedule are not yet registered in the array,
	 {
	  $UsedPolSched += @("$Policy,$JobSchedule") # Register this policy and schedule in the array
	 }
     $JobNBServer = $Job.SubString(49,12).Trim() # From string $job, extract NBU master server
     $JobTimeComplete = $Job.SubString(61).Trim() # From string $job, extract time completed
	 # ---
	 $ReadOKClient = $JobOK[$JobOKCount].SubString(7,14).Trim() # From the $JobOK array read the $JobOKCount row and extract client name
	 $ReadOKPolicy = $JobOK[$JobOKCount].SubString(21,17).Trim() # From the $JobOK array read the $JobOKCount row and extract policy name
	 $ReadOKSchedule = $JobOK[$JobOKCount].SubString(38,11).Trim() # From the $JobOK array read the $JobOKCount row and extract schedule
	 $ReadOKTimeStamp = $JobOK[$JobOKCount].SubString(61).Trim() # From the $JobOK array read the $JobOKCount row and extract time completed
	 # ---
	 $ReadPartialClient = $JobPartial[$JobPartialCount].SubString(7,14).Trim() # From the $JobPartial array read the $JobPartialCount row and extract client name
	 $ReadPartialPolicy = $JobPartial[$JobPartialCount].SubString(21,17).Trim() # From the $JobPartial array read the $JobPartialCount row and extract policy name
	 $ReadPartialSchedule = $JobPartial[$JobPartialCount].SubString(38,11).Trim() # From the $JobPartial array read the $JobPartialCount row and extract schedule
	 $ReadPartialTimeStamp = $JobPartial[$JobPartialCount].SubString(61).Trim() # From the $JobPartial array read the $JobPartialCount row and extract time completed
	 # ---
	 $ReadFailClient = $JobFail[$JobFailCount].SubString(7,14).Trim() # From the $JobFail array read the $JobFailCount row and extract client name
	 $ReadFailPolicy = $JobFail[$JobFailCount].SubString(21,17).Trim() # From the $JobFail array read the $JobFailCount row and extract policy name
	 $ReadFailSchedule = $JobFail[$JobFailCount].SubString(38,11).Trim() # From the $JobFail array read the $JobFailCount row and extract schedule
	 $ReadFailTimeStamp = $JobFail[$JobFailCount].SubString(61).Trim() # From the $JobFail array read the $JobFailCount row and extract time completed
	 # --- Write progress to console
     $ClntStr = $Client+" "*($ClientStringLength-$Client.Length) # For interactive use only, get client name and add whitespace
	 Write-Host " Client: " -NoNewLine # Write to console,
	 Write-Host $ClntStr -NoNewLine -ForeGroundColor "Cyan" # The currently processing client
	 Write-Host "Status: " -NoNewLine # Write to console,
	 Switch ($StatusCode)
	 {
	  0
	  {
	   Write-Host $StatusCode -NoNewLine -ForeGroundColor "Green" # Status successful
	  }
	  1
	  {
	   Write-Host $StatusCode -NoNewLine -ForeGroundColor "Yellow" # Status partially successful
	  }
	  Default
	  {
	   Write-Host $StatusCode -NoNewLine -ForeGroundColor "Red" # Status failed
	  }
	 }
	 Write-Host "`tPolicy: " -NoNewLine # Write to console,
	 Write-Host $Policy -ForeGroundColor "Cyan" # The currently processing clients' policy
	 # ---
	 Switch ($StatusCode) # Process jobs by statuscode
	 {
	  {$StatusCode -eq 0} # If statuscode equals 0 (Successful), process job
	  {
	   If ($JobOKCount -eq 1) # If row count of the $JobOK array equals 1
	   {
	    $JobOK.Add($Job) | Out-Null # Add the currently processing job values to the array
	    $JobOKCount++ # Increment the row count
	   }
	   ElseIf (($JobClient -eq $ReadOKClient) -AND ($JobPolicy -eq $ReadOKPolicy) -AND ($JobSchedule -eq $ReadOKSchedule) -AND ($JobTimeComplete -ge $ReadOKTimeStamp)) # If Client, Policy and Schedule are the same, but the time completed is greater than the values read from the $JobOK array,
	   {
	    $JobOK[$JobOKCount] = $Job # Replace the read values with the currently processing job values
	   }
	   Else
	   {
	    $JobOK.Add($Job) | Out-Null # If all above logic is not true, add the currently processing job values to the array
	    $JobOKCount++ # Increment the row count
	   }
	   If (($JobPartialCount -gt 1) -AND ($JobClient -eq $ReadPartialClient) -AND ($JobPolicy -eq $ReadPartialPolicy) -AND ($JobSchedule -eq $ReadPartialSchedule) -AND ($JobTimeComplete -ge $ReadPartialTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobPartial Array, if currently processing job time completed is greater than the value of time completed in $JobPartial,
	   {
	    $JobPartial.Remove($JobPartial[$JobPartialCount]) | Out-Null # Remove the read values from the array
	    $JobPartialCount-- # Decrement the row count
	   }
	   If (($JobFailCount -gt 1) -AND ($JobClient -eq $ReadFailClient) -AND ($JobPolicy -eq $ReadFailPolicy) -AND ($JobSchedule -eq $ReadFailSchedule) -AND ($JobTimeComplete -ge $ReadFailTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobFail Array, if currently processing job time completed is greater than the value of time completed in $JobFail,
	   {
	    $JobFail.Remove($JobFail[$JobFailCount]) | Out-Null # Remove the read job values from the array
	    $JobFailCount-- # Decrement the row count
	   }
	  }
	  {$StatusCode -eq 1} # If statuscode equals 1 (Partially successful), process job
	  {
	   If ($JobPartialCount -eq 1) # If row count of the $JobPartial array equals 1
	   {
	    $JobPartial.Add($Job) | Out-Null # Add the currently processing job values to the array
	    $JobPartialCount++ # Increment the row count
	   }
	   Else
	   {
	    If (($JobClient -eq $ReadPartialClient) -AND ($JobPolicy -eq $ReadPartialPolicy) -AND ($JobSchedule -eq $ReadPartialSchedule) -AND ($JobTimeComplete -ge $ReadPartialTimeStamp)) # If Client, Policy and Schedule are the same, but the time completed is greater than the values read from the $JobPartial array,
	    {
	     $JobPartial[$JobPartialCount] = $Job # Replace the read values with the currently processing job values
	    }
	    Else
	    {
	     $JobPartial.Add($Job) | Out-Null # If all above logic is not true, add the currently processing job values to the array
	     $JobPartialCount++ # Increment the row count
	    }
	   }
	   If (($JobOKCount -gt 1) -AND ($JobClient -eq $ReadOKClient) -AND ($JobPolicy -eq $ReadOKPolicy) -AND ($JobSchedule -eq $ReadOKSchedule) -AND ($JobTimeComplete -ge $ReadOKTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobOK Array, if currently processing job time completed is greater than the value of time completed in $JobOK,
	   {
	    $JobOK.Remove($JobOK[$JobOKCount]) | Out-Null # Remove the read job $JobOK values from the array
	    $JobOKCount-- # Decrement the row count
	   }
	   If (($JobFailCount -gt 1) -AND ($JobClient -eq $ReadFailClient) -AND ($JobPolicy -eq $ReadFailPolicy) -AND ($JobSchedule -eq $ReadFailSchedule) -AND ($JobTimeComplete -ge $ReadFailTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobFail Array, if currently processing job time completed is greater than the value of time completed in $JobFail,
	   {
	    $JobFail.Remove($JobFail[$JobFailCount]) | Out-Null # Remove the read job $JobFail values from the array
	    $JobFailCount-- # Decrement the row count
	   }
	  }
	  {$StatusCode -gt 1} # If statuscode greater than 1 (Failed), process job
	  {
	   If ($JobFailCount -eq 1)
	   {
	    $JobFail.Add($Job) | Out-Null # Add the currently processing job values to the array
	    $JobFailCount++ # Increment the row count
	   }
	   Else
	   {
	    If (($JobClient -eq $ReadFailClient) -AND ($JobPolicy -eq $ReadFailPolicy) -AND ($JobSchedule -eq $ReadFailSchedule) -AND ($JobTimeComplete -ge $ReadFailTimeStamp)) # If Client, Policy and Schedule are the same, but the time completed is greater than the values read from the $JobFail array,
	    {
	     $JobFail[$JobFailCount] = $Job # Replace the read values with the currently processing job values
	    }
	    Else
	    {
	     $JobFail.Add($Job) | Out-Null # If all above logic is not true, add the currently processing job values to the array
	     $JobFailCount++ # Increment the row count
	    }
	   }
	   If (($JobOKCount -gt 1) -AND ($JobClient -eq $ReadOKClient) -AND ($JobPolicy -eq $ReadOKPolicy) -AND ($JobSchedule -eq $ReadOKSchedule) -AND ($JobTimeComplete -ge $ReadOKTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobOK Array, if currently processing job time completed is greater than the value of time completed in $JobOK,
	   {
	    $JobOK.Remove($JobOK[$JobOKCount]) | Out-Null # Remove the read job $JobOK values from the array
	    $JobOKCount-- # Decrement the row count
	   }
	   If (($JobPartialCount -gt 1) -AND ($JobClient -eq $ReadPartialClient) -AND ($JobPolicy -eq $ReadPartialPolicy) -AND ($JobSchedule -eq $ReadPartialSchedule) -AND ($JobTimeComplete -ge $ReadPartialTimeStamp)) # Check if client, policy and schedule are the same in the last row of the $JobPartial Array, if currently processing job time completed is greater than the value of time completed in $JobPartial,
	   {
	    $JobPartial.Remove($JobPartial[$JobPartialCount]) | Out-Null # Remove the read job $JobPartial values from the array
	    $JobPartialCount-- # Decrement the row count
	   }
	  }
	 }
	}
   }
   Else # If $ClientJobList is empty
   {
    If ($ClientReported -contains "$Client`t$PolicyType") # If client and schedule are present in the $ClientReported array
	{
	 Continue # Continue
	}
	Else # If client and schedule are NOT present in the $ClientReported array (line 195)
	{
     $CNRString = ($Client+" "*($ClientStringLength-$Client.Length))+($Policy+" "*($PolicyStringLength-$Policy.Length)) # Format a string with client and policy values
	 $ClientNotReported += @($CNRString) # Add the string value to the $ClientNotReported array
     Continue
	}
   }
  }
  If ($JobOK.Count -gt 2) # If the row count of $JobOK array is greater than 2,
  {
   $TotalOK += $JobOK # Add the values of $JobOK to $TotalOK
   If ($JobOK) {Clear-Variable JobOK} # Clear the array in preparation of processing the next policy
  }
  If ($JobPartial.Count -gt 2) # If the row count of $JobPartial array is greater than 2,
  {
   $TotalPartial += $JobPartial # Add the values of $JobPartial to $TotalPartial
   If ($JobPartial) {Clear-Variable JobPartial} # Clear the array in preparation of processing the next policy
  }
  If ($JobFail.Count -gt 2) # If the row count of $JobFail array is greater than 2,
  {
   $TotalFail += $JobFail # Add the values of $JobFail to $TotalFail
   If ($JobFail) {Clear-Variable JobFail} # Clear the array in preparation of processing the next policy
  }
 }
}
# ---
$NBUStats = $NBUStats | Sort-Object # Sort the NBUStats array
$GrandTotalFiles = "{0:N0}" -f $GrandTotalFiles # Format the value of GrandTotalFiles
If ($GrandTotalKB -lt 1048576) # Format GrandTotalKB to reflect,
{
 $GrandTotalKBs = "{0:N} KB" -f $($GrandTotalKB/1KB) # KiloBytes,
}
If (($GrandTotalKB -gt 1048576) -AND ($GrandTotalKB -lt 1073741824))
{
 $GrandTotalKBs = "{0:N} MB" -f $($GrandTotalKB/1MB) # MegaBytes,
}
If ($GrandTotalKB -gt 1073741824 -AND ($GrandTotalKB -lt 1099511627776))
{
 $GrandTotalKBs = "{0:N} GB" -f $($GrandTotalKB/1GB) # GigaBytes, or
}
If ($GrandTotalKB -gt 1099511627776)
{
 $GrandTotalKBs = "{0:N} TB" -f $($GrandTotalKB/1TB) #TeraBytes
}
$NBUStats += @("";"Total Files backedup: $GrandTotalFiles";"Total Data backedup: $GrandTotalKBs") # Add the aggregate values to the NBUStats array
# ---------------------------
Write-Host "" # Write to console
Write-Host "Checking for active jobs..." -ForegroundColor "Yellow" # Write to console
$ActivejobList = Invoke-Expression "bpdbjobs -ignore_parent_jobs" | Select-String "Active" # Using NBU cmd check for active jobs at the time of reporting
$ActiveJobs = @("";"Active jobs at the time of report") # Initialize ActiveJobs array and add header
$ActiveJobs += @("-"*$ActiveJobs[1].Length) #Add variable length horizontal separator
If ($ActivejobList) # If ActivejobList contains data
{
 ForEach ($ActiveJob in $ActiveJobList) # Process active jobs
 {
  $ActiveClient = $Activejob.ToString().SubString(0,112) # Get the first 112 characters from the job string
  $ActiveJobs += @($ActiveClient) # Add it to the ActiveJobs array
 }
}
# ---------------------------
Write-Host "" # Write to console
Write-Host "Getting tape media used..." -ForegroundColor "Yellow" # Write to console
$TapeMediaUsed = @("";"Tape Media used during backup") # Initialize array and add header
$TapeMediaUsed += @("-"*$TapeMediaUsed[1].Length) # Add variable length horizontal separator
$ColTapeMediaUsed = Invoke-Expression "bpimagelist -media -L -d $StartDate -e $EndDate" # Using NBU cmd get tape media used
$TapeMediaUsedCount = ($ColTapeMediaUsed | Select-String "Media ID:").Count # From ColTapeMediaUsed get the number of media used
[Int]$1=0 # Row number of "Media ID" in ColTapeMediaUsed
[Int]$2=2 # Row number of "Last Time Written" in ColTapeMediaUsed
[Int]$3=3 # Row number of "Times Written" in ColTapeMediaUsed
[Int]$4=4 # Row number of "Kilobytes" in ColTapeMediaUsed
For ($i=0; $i -le $TapeMediaUsedCount; $i++) # For the number of media used,
{
 $TapeMediaUsed += @($ColTapeMediaUsed[$1,$2,$3,$4];"") # Write the values to the array
 $1=$1+7 # Increment the row number by 7 for the next media used
 $2=$2+7 # Increment the row number by 7 for the next media used
 $3=$3+7 # Increment the row number by 7 for the next media used
 $4=$4+7 # Increment the row number by 7 for the next media used
}
# ---------------------------
Write-Host "" # Write to console
Write-Host "Getting disk storage units used..." -ForegroundColor "Yellow" # Write to console
$DiskStorageUnits = @("";"Disk Storage Units Status") # Initialize array and add header
$DiskStorageUnits += @("-"*$DiskStorageUnits[1].Length) # Add variable length horizontal separator
$ColDiskStorageUnits = Invoke-Expression "nbdevquery -listdv -stype BasicDisk -U" # Using NBU cmd to get disk storageunits
ForEach ($PolSched in $UsedPolSched) # Process policies/schedules used during backup operation (see line 215,74) to extract disk storageunit usage
{
 $PolSched=$PolSched.Split(",") # Split the $polSched string at the comma
 $UsedPolicy = $PolSched[0] # From the split string extract the Policyname
 $UsedSchedule = $PolSched[1] # From the split string extract the Schedule
 $UsedPolicyDetails = Invoke-Expression "bppllist $UsedPolicy -L" # Using NBU cmd get currently processing policy details
 $ScheduleStartLine = ($UsedPolicyDetails | Select-String "Schedule:.*$UsedSchedule").LineNumber-1 # From the policy details extract the linenumber where the used schedule details begin
 $Schedule = $UsedPolicyDetails[$ScheduleStartLine..$Usedpolicydetails.Count] # From above acquired linenumber select all lines to the last line of the policy details
 Try
 {
  $ScheduleEndLine = ($Schedule | Select-String "Schedule")[1].LineNumber-2 # Check if multiple schedule details are selected, by selecting the word "Schedule". If true acquire the linenumber of the second instance of the word "Schedule" and extract 2 lines
 }
 Catch
 {
  $ScheduleEndLine = $Usedpolicydetails.Count # If the above statement fails, it is the last schedule description in policy details, so the last line of the policydetails is also the last line of the schedule description
 }
 $Schedule = $Schedule[0..$ScheduleEndLine] # Final selection to acquire the schedule description
 $StorageUnitString = ($Schedule | Select-String "Residence:").ToString().SubString(19).Trim() # From the schedule details acquire the "residence" value
 If ($ColDiskStorageUnits -contains "Disk Pool Name      : $StorageUnitString") # If previously collected disk storageunits data, contains the StorageUnitString,
 {
  [Int]$ColStorageUnitLineNumber = ($ColDiskStorageUnits | Select-String "Disk Pool Name .*$StorageUnitString").LineNumber-1 # Get the linenumber for the line that contains "Disk Pool Name .*$StorageUnitString" and extract 1 to compensate for the fact that powershell starts counting at 0 instead of 1
  [Int]$1=$ColStorageUnitLineNumber # linenumber for "Disk Pool Name"
  [Int]$2=$ColStorageUnitLineNumber+4 # linenumber for "Total Capacity"
  [Int]$3=$ColStorageUnitLineNumber+5 # linenumber for "Free Space"
  [Int]$4=$ColStorageUnitLineNumber+6 # linenumber for "Use%"
  [Int]$5=$ColStorageUnitLineNumber+7 # linenumber for "Status"
  If ($DiskStorageUnits -notcontains "Disk Pool Name      : $StorageUnitString") # If array DiskStorageUnits does not contain a line like "Disk Pool Name      : $StorageUnitString",
  {
   $DiskStorageUnits += @($ColDiskStorageUnits[$1,$2,$3,$4,$5];"") # Add the disk storageunit details to the array
  }
 }
}
# ---------------------------
Write-Host "" # Write to console
Write-Host "Creating report..." -ForegroundColor "Yellow" # Write to console
Set-Content $OutputStr "" # initialize the output file
$ReportStart = "{0:dddd dd\-MM\-yyyy H:mm:ss}" -f $Now # Format date and time for the script start timestamp
If (($Now.DayOfWeek -eq "Tuesday") -OR ($Now.DayOfWeek -eq "Wednesday") -OR ($Now.DayOfWeek -eq "Thursday") -OR ($Now.DayOfWeek -eq "Friday"))  # For every weekday except monday
{
 $ReportingDate = "{0:dddd dd\-MM\-yyyy}" -f ($Now.AddDays(-1)) # Set the date back one day and format the date for the date of the backup operation
}
If ($Now.DayOfWeek -eq "Monday") # For every monday
{
 $ReportingDate = "{0:dddd dd\-MM\-yyyy}" -f ($Now.AddDays(-3)) # Set the date back three days and format the date for the date of the backup operation
}
$ReportHeader = @("Report Generated on $env:COMPUTERNAME, $ReportStart";"";"Backup report for $ReportingDate") # Array with multiline header
Add-Content $OutputStr $ReportHeader # Add the header to the output file
$ReportParts = @($TotalFail,$TotalPartial,$TotalOK) # Array containing the names of the arrays with the overall results of the backup operation
ForEach ($Part in $ReportParts) # For each array,
{
 If ($Part.Count -ge 3) # If the line count is greater than 3,
 {
  Add-Content $OutputStr $Part # Add the array to the output file
 }
}
If ($ActiveJobs.Count -gt 4) # If the line count is greater than 3,
{
 Add-Content $OutputStr $ActiveJobs # Add the array to the output file
}
If ($ClientNotReported.Count -gt 4) # If the line count is greater than 4,
{
 Add-Content $OutputStr $ClientNotReported # Add the array to the output file
}
If ($NBUStats.Count -ge 1) # If the line count is greater than 4,
{
 Add-Content $OutputStr $NBUStatsHeader # Add the header array to the output file
 Add-Content $OutputStr $NBUStats # Add the array to the output file
}
If ($TapeMediaUsed.Count -gt 3) # If the line count is greater than 3,
{
 Add-Content $OutputStr $TapeMediaUsed # Add the array to the output file
}
If ($DiskStorageUnits.Count -gt 3) # If the line count is greater than 3,
{
 Add-Content $OutputStr $DiskStorageUnits # Add the array to the output file
}
Add-Content $OutputStr "" # Add blank line to the output file
Add-Content $OutputStr "--------------------------------------------------" # Add a separator to the output file
$ReportEnd = "{0:dddd dd\-MM\-yyyy H:mm:ss}" -f (Get-Date) # Get and format the current date and time
$ReportFooter = @("Report finished on $env:COMPUTERNAME, $ReportEnd";"") # Array with multiline footer
Add-Content $OutputStr $ReportFooter # Add the footer to the output file
# ---------------------------
Write-Host "" # Write to console
Write-Host "Sending e-mail..." -ForegroundColor "Yellow" # Write to console
$MailBody = Get-Content $OutputStr | %{ "$_`r" } # Read and parse the contents of the output file
$CcRecipients = Get-Content ($OutputPth + "\" + $CC) # read the contents of the file containing CC recipients
$Attachment = $OutputStr # declare variable containing the path to the output file
$Msg = New-Object Net.Mail.MailMessage # Create new e-mail message object
$Att = New-Object Net.Mail.Attachment($Attachment) # Create new attachment object
$Smtp = New-Object Net.Mail.SmtpClient($SmtpServer) # Create new smtp client object
$Msg.From = $From # Add from address to the message
$Msg.To.Add($To) # Add to address to the message
$Msg.CC.Add($CcRecipients) # Add CC address(es) to the message
$Msg.Subject = "Backup report for last $ReportingDate" # Set the message subject
$Msg.Body = $MailBody # Add the bodytext to the message
$Msg.Attachments.Add($Att) # Add the attachment to the message
$Smtp.Send($Msg) # Send the message
$Att.Dispose() # Clear memory of the attachment
# ---------------------------
#Write-EventLog -LogName "Scripts" -Source "Reporting_Script" -EventID 30 -Message "Backup Report: Mail Sent" -EntryType "Information"
# ---------------------------
# reset the colors back to default
[console]::ResetColor()

@@ End of Script
@@ Below is an example of the actual output

Report Generated on NBUSRV, monday 06-12-2010 8:30:07

Backup report for friday 03-12-2010

Failed jobs during the FileBackup backup
----------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
156    SRV001        FileBackup       Week       NBUSRV      12/04/2010 15:17:48 

Failed jobs during the Linux_filebackup2 backup
-----------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
 71    SRV002        Linux_filebackup Week       NBUSRV      12/03/2010 18:17:54 

Partially Successful jobs during the FileBackup backup
------------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  1    NBUSRV        FileBackup       Week       NBUSRV      12/03/2010 23:56:46 

Partially Successful jobs during the FileBackup2 backup
-------------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  1    SRV003        FileBackup2      Week       NBUSRV      12/03/2010 20:44:03 

Partially Successful jobs during the NAS_FileBackup_SQL_WWW backup
------------------------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  1    SRV004        NAS_FileBackup_S Full       NBUSRV      12/04/2010 12:26:59 
  1    SRV005        NAS_FileBackup_S Full       NBUSRV      12/04/2010 00:02:49 

Partially Successful jobs during the PRTG backup
------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  1    SRV006        PRTG             Full       NBUSRV      12/04/2010 13:28:54 

Successful jobs during the CatalogBackup backup
-----------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    NBUSRV        CatalogBackup    Daily      NBUSRV      12/06/2010 08:11:56 

Successful jobs during the ExchangeBackup backup
------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV003        ExchangeBackup   Week       NBUSRV      12/04/2010 19:51:29 

Successful jobs during the FileBackup backup
--------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV007        FileBackup       Week       NBUSRV      12/04/2010 14:21:31 
  0    SRV008        FileBackup       Week       NBUSRV      12/03/2010 20:54:54 
  0    SRV009        FileBackup       Week       NBUSRV      12/04/2010 01:40:42 
  0    SRV010        FileBackup       Week       NBUSRV      12/04/2010 01:33:09 
  0    SRV004        FileBackup       Week       NBUSRV      12/03/2010 23:57:03 
  0    SRV011        FileBackup       Week       NBUSRV      12/04/2010 01:16:40 
  0    SRV012        FileBackup       Week       NBUSRV      12/04/2010 01:52:23 
  0    SRV013        FileBackup       Week       NBUSRV      12/04/2010 18:11:10 
  0    SRV014        FileBackup       Week       NBUSRV      12/04/2010 01:17:05 
  0    SRV015        FileBackup       Week       NBUSRV      12/04/2010 01:14:31 
  0    SRV016        FileBackup       Week       NBUSRV      12/04/2010 13:20:02 
  0    SRV017        FileBackup       Week       NBUSRV      12/04/2010 01:36:57 
  0    SRV005        FileBackup       Week       NBUSRV      12/04/2010 11:25:06 

Successful jobs during the FileBackup2 backup
---------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV018        FileBackup2      Week       NBUSRV      12/05/2010 14:49:59 

Successful jobs during the Linux_filebackup backup
--------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV019        Linux_filebackup Week       NBUSRV      12/03/2010 18:09:46 
  0    SRV020        Linux_filebackup Week       NBUSRV      12/03/2010 20:55:21 
  0    SRV021        Linux_filebackup Week       NBUSRV      12/03/2010 18:16:15 

Successful jobs during the MailboxBackup backup
-----------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV003        MailboxBackup    Week       NBUSRV      12/04/2010 02:22:32 

Successful jobs during the NAS_Daily_SRV018 backup
--------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV018        NAS_Daily_SRV018 Full       NBUSRV      12/05/2010 06:19:59 

Successful jobs during the NAS_FileBackup_Citrix backup
-------------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV015        NAS_FileBackup_C Week       NBUSRV      12/03/2010 19:49:17 
  0    SRV016        NAS_FileBackup_C Week       NBUSRV      12/03/2010 19:48:46 
  0    SRV017        NAS_FileBackup_C Week       NBUSRV      12/03/2010 19:49:29 

Successful jobs during the NAS_FileBackup_DCs backup
----------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV007        NAS_FileBackup_D Week       NBUSRV      12/03/2010 20:55:59 
  0    SRV008        NAS_FileBackup_D Week       NBUSRV      12/03/2010 20:33:49 

Successful jobs during the NAS_FileBackup_SQL_WWW backup
--------------------------------------------------------
STATUS CLIENT        POLICY           SCHED      SERVER      TIME COMPLETED
  0    SRV009        NAS_FileBackup_S Full       NBUSRV      12/04/2010 00:31:03 
  0    SRV010        NAS_FileBackup_S Full       NBUSRV      12/04/2010 10:21:18 
  0    SRV001        NAS_FileBackup_S Full       NBUSRV      12/03/2010 23:42:43 
  0    SRV013        NAS_FileBackup_S Full       NBUSRV      12/04/2010 00:23:24 

Servers that did not (yet) report any activity
----------------------------------------------
CLIENT         POLICY                   
SRV022         FileBackup2            
SRV023         ExchangeBackup           
SRV024         FileBackup                        
  
BACKUP STATISTICS
CLIENT         POLICY                   FILES     SIZE        ELAPSED   
------------------------------------------------------------------------
NBUSRV         CatalogBackup            7.209     7,97 GB     00:11:29
NBUSRV         FileBackup               32.870    25,60 GB    05:04:51
SRV001         FileBackup               312.592   118,36 GB   05:25:18
SRV001         NAS_FileBackup_SQL_WWW   189.777   84,10 GB    03:45:15
SRV002         Linux_filebackup2        98.381    3,81 GB     00:20:35
SRV003         ExchangeBackup           9         247,01 GB   09:59:45
SRV003         FileBackup2              51.021    9,15 GB     00:57:07
SRV003         MailboxBackup            192.399   5,45 GB     01:22:26
SRV004         FileBackup               111.210   56,53 GB    06:04:05
SRV004         NAS_FileBackup_SQL_WWW   61.901    28,16 GB    01:20:48
SRV005         FileBackup               102.547   185,43 GB   06:44:37
SRV005         NAS_FileBackup_SQL_WWW   43.621    78,96 GB    03:52:15
SRV006         PRTG                     48.992    13,36 GB    01:16:57
SRV007         FileBackup               74.042    27,96 GB    03:01:21
SRV007         NAS_FileBackup_DCs       37.012    13,92 GB    01:06:18
SRV008         FileBackup               76.314    14,05 GB    01:47:51
SRV008         NAS_FileBackup_DCs       38.157    7,00 GB     00:40:53
SRV009         FileBackup               135.311   182,96 GB   11:30:10
SRV009         NAS_FileBackup_SQL_WWW   74.393    91,12 GB    02:18:39
SRV010         FileBackup               118.870   155,18 GB   08:16:04
SRV010         NAS_FileBackup_SQL_WWW   67.660    57,78 GB    01:27:28
SRV011         FileBackup               29.968    5,80 GB     00:52:46
SRV012         FileBackup               84.197    11,41 GB    01:20:36
SRV013         FileBackup               164.644   259,76 GB   10:42:15
SRV013         NAS_FileBackup_SQL_WWW   81.413    129,37 GB   04:12:44
SRV014         FileBackup               34.022    5,87 GB     00:51:19
SRV015         FileBackup               60.459    16,21 GB    01:10:15
SRV015         NAS_FileBackup_Citrix    30.224    8,07 GB     00:22:53
SRV016         FileBackup               73.496    39,25 GB    01:48:33
SRV016         NAS_FileBackup_Citrix    36.742    19,55 GB    00:26:46
SRV017         FileBackup               195.726   47,95 GB    02:22:57
SRV017         NAS_FileBackup_Citrix    97.863    23,88 GB    00:33:53
SRV018         FileBackup2              5.964.297 505,46 GB   1.06:46:30
SRV018         NAS_Daily_SRV018         5.921.262 496,49 GB   1.02:24:36
SRV019         Linux_filebackup         108.119   2,17 GB     00:11:06
SRV020         Linux_filebackup         127.037   6,28 GB     02:57:13
SRV021         Linux_filebackup         132.949   7,69 GB     00:18:09

Total Files backedup: 15.016.706
Total Data backedup: 2,93 TB

Tape Media used during backup
-----------------------------
Media ID:          TAPE001
Last Time Written:       4-12-2010 12:47:33 (1291463253)
Times Written:     2311 (within this time period)
Kilobytes:         838688875 (within this time period)

Media ID:          TAPE002
Last Time Written:       3-12-2010 22:16:36 (1291410996)
Times Written:     1018 (within this time period)
Kilobytes:         139560051 (within this time period)

Media ID:          TAPE003
Last Time Written:       4-12-2010 12:47:29 (1291463249)
Times Written:     501 (within this time period)
Kilobytes:         481352638 (within this time period)

Media ID:          CATALOG
Last Time Written:        6-12-2010 8:02:04 (1291618924)
Times Written:     6 (within this time period)
Kilobytes:         8360274 (within this time period)



Disk Storage Units Status
-------------------------
Disk Pool Name      : DISK_POOL1
Total Capacity (GB) : 300.00
Free Space (GB)     : 280.76
Use%                : 6
Status              : UP

Disk Pool Name      : DISK_POOL2
Total Capacity (GB) : 5526.45
Free Space (GB)     : 2460.72
Use%                : 55
Status              : UP


--------------------------------------------------
Report finished on NBUSRV, monday 06-12-2010 8:30:51
