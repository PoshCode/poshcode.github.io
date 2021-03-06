function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='C:\Logs\PowerShellLog.log', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

try
{
$ErrorActionPreference='SilentlyContinue'
$Error.Clear()
$Path=$env:windir
Write-Log -Message "################ Script Started #############################" -Level Info
#$input_details= "hardware,10-12-2016-14-20,1;Organization,09-12-2016-15-50,2;"
$input_details= $args[0];
Write-Log -Message "The Input Details are : $input_details" -Level Info
$input_details= $input_details.Remove($input_details.Length -1)
$Inputs = $input_details -split ';' 

    foreach ($inps in $Inputs)
    {
            Write-Log -Message "###### Operation Inside Loop ######################" -Level Info
                $array=$inps.split(',')
                $global:schedule_name=$array[0]
                $global:Assessment_type=$array[0]
                $global:Date= $array[1]
                $global:interval = $array[2]

                $template = 'MM-dd-yyyy-HH-mm'
                $StartTime = [DateTime]::ParseExact($date, $template, $null) 

          If(!(& $Path\System32\schtasks.exe /query /TN "SHA_$schedule_name"))
            {
            "Task Not Existed with the name SHA_$schedule_name. Creating the Task."
            Write-Log -Message "Task Not Existed with the name SHA_$schedule_name. Creating the Task." -Level Info
                $TaskName = "SHA_$schedule_name"
                $TaskDescr = "Automated Scheduled Task from Powershell"
                $TaskCommand = "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
                $TaskScript = '"C:\Users\rdutta\Desktop\Scripts\'+"$Assessment_type.ps1"+'"'
                $TaskArg = "-Executionpolicy unrestricted -file $TaskScript"
                [DateTime]$TaskStartTime = $StartTime
            Write-Log -Message "Task Name: $TaskName" -Level Info
            Write-Log -Message "TaskDescription : $TaskDescr" -Level Info
            Write-Log -Message "Task Script: $TaskScript" -Level Info
            Write-Log -Message "Task Start Date & Time : $TaskStartTime " -Level Info
            

                        $service = new-object -ComObject("Schedule.Service")
                        # connect to the local machine.

                        $service.Connect()
                        $rootFolder = $service.GetFolder("\")
                        $TaskDefinition = $service.NewTask(0)
                        $TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
                        $TaskDefinition.Settings.Enabled = $true
                        $TaskDefinition.Settings.AllowDemandStart = $true
                        $TaskDefinition.Settings.StartWhenAvailable = $true
                        $TaskDefinition.Settings.StopIfGoingOnBatteries=$false
                        $TaskDefinition.Settings.DisallowStartIfOnBatteries=$false
                        $TaskDefinition.Settings.MultipleInstances=2
                        $taskdefinition.Settings.WakeToRun=$true
                        $triggers = $TaskDefinition.Triggers
                        $trigger = $triggers.Create(1) # Creates a "One time" trigger
                        $trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
                        $time_interval=New-TimeSpan -Minutes $interval
                        $time_interval=$time_interval.TotalSeconds
                        $trigger.Repetition.Interval= "PT"+"$time_interval"+"S"
                        $trigger.Enabled = $true
                        $TaskDefinition.Principal.RunLevel =1
                        $Action = $TaskDefinition.Actions.Create(0)
                        $action.Path = "$TaskCommand"
                        $action.Arguments = "$TaskArg"
                        # In Task Definition,
                        #   6 indicates "the task will not execute when it is registered unless a time-based trigger causes it to execute on registration." 
                        #   5 indicates "Indicates that a Local System, Local Service, or Network Service account is being used as a security context to run the task.In this case, its the SYSTEM"
                        $rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5) | Out-Null
                        "Scheduled Task has been created successfully with the name SHA_$schedule_name"
                        Write-Log -Message "Scheduled Task has been created successfully with the name SHA_$schedule_name" -Level Info
                        Write-Log -Message "#########################################################################################" -Level Info


               }

        elseIf(& $Path\System32\schtasks.exe /query /TN "SHA_$schedule_name")
            {
            "Task Existed with the name SHA_$schedule_name. Updating the Task."
            Write-Log -Message "Task Existed with the name SHA_$schedule_name. Updating the Task." -Level Info
                $TaskName = "SHA_$schedule_name"
                $TaskDescr = "Automated Scheduled Task from Powershell"
                $TaskCommand = "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
                $TaskScript = '"C:\Users\rdutta\Desktop\Scripts\'+"$Assessment_type.ps1"+'"'
                $TaskArg = "-Executionpolicy unrestricted -file $TaskScript"
                [DateTime]$TaskStartTime = $StartTime
                Write-Log -Message "Task Name: $TaskName" -Level Info
                Write-Log -Message "TaskDescription : $TaskDescr" -Level Info
                Write-Log -Message "Task Script: $TaskScript" -Level Info
                Write-Log -Message "Task Start Date & Time : $TaskStartTime " -Level Info
            

                        $service = new-object -ComObject("Schedule.Service")
                        # connect to the local machine.

                        $service.Connect()
                        $rootFolder = $service.GetFolder("\")
                        $TaskDefinition = $service.NewTask(0)
                        $TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
                        $TaskDefinition.Settings.Enabled = $true
                        $TaskDefinition.Settings.AllowDemandStart = $true
                        $TaskDefinition.Settings.StartWhenAvailable = $true
                        $TaskDefinition.Settings.StopIfGoingOnBatteries=$false
                        $TaskDefinition.Settings.DisallowStartIfOnBatteries=$false
                        $TaskDefinition.Settings.MultipleInstances=2
                        $taskdefinition.Settings.WakeToRun=$true
                        $triggers = $TaskDefinition.Triggers
                        $trigger = $triggers.Create(1) # Creates a "One time" trigger
                        $trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
                        $time_interval=New-TimeSpan -Minutes $interval
                        $time_interval=$time_interval.TotalSeconds
                        $trigger.Repetition.Interval= "PT"+"$time_interval"+"S"
                        $trigger.Enabled = $true
                        $TaskDefinition.Principal.RunLevel =1
                        $Action = $TaskDefinition.Actions.Create(0)
                        $action.Path = "$TaskCommand"
                        $action.Arguments = "$TaskArg"
                        # In Task Definition,
                        #   6 indicates "the task will not execute when it is registered unless a time-based trigger causes it to execute on registration." 
                        #   5 indicates "Indicates that a Local System, Local Service, or Network Service account is being used as a security context to run the task.In this case, its the SYSTEM"
                        $rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5) |Out-Null
                        "Scheduled Task with the name SHA_$schedule_name has been updated successfully"
                        Write-Log -Message "Scheduled Task with the name SHA_$schedule_name has been updated successfully" -Level Info
                        Write-Log -Message "#########################################################################################" -Level Info
                        
            }
    }
}
catch
{Write-Log -Message $_.Exception.Message -Level Error}
Finally
{Write-Log -Message $Error -Level Error}
