# ==============================================================================================
#
# Microsoft PowerShell Source File — Created with SAPIEN Technologies PrimalScript 2007
#
# NAME: SCOM-RunRemoteExecutable.ps1
#
# AUTHOR: Jeremy D. Pavleck , Pavleck.NET
# DATE  : 9/13/2008
#
# COMMENT: This is a Proof Of Concept script written in response to a mailing list request to
#               enable OpsMgr to sound an audible alert on a remote admin PC, such as a console in a
#               NOC.
#               This is to be run as a Notification Command Channel.
#
# NOTES/WARNING: This script uses a remote WMI call to spawn a process on a named server. As
#               such, there are security issues to keep in mind. I haven’t added the code to allow you
#               to use alternate credentials, but use http://poshcode.org/501 as a jumping off point.
#               If you’re running the OpsMgr services under a domain account, add that user to the local
#               administrators group on the machine you want to run this command. If you’re using local
#               system, add RMS\Local System to the admin group.
#               RUN AT YOUR OWN RISK!
#
# VERSIONS:
#               v1.0 - 09/12/2008 - Initial version
#               v1.1 - 09/13/2008 - On the advice of Pete Zerger, added a throttling routine to prevent
#                                                       to many executions during an alert storm
#               v1.2 - 09/13/2008 - Changed variable names to make it a more ‘run remote executable’ script
#
# ==============================================================================================

# User Settings
$remoteMachine = "adminconsole.pavleck.net"
# The location to the executable. This is the path on the REMOTE machine.
$myExe = "C:\Program Files\Real Alternative\Media Player Classic\mplayerc.exe"
$myExeParams = "C:\Windows\Media\tada.exe" # Paramters to pass to the executable, such as the location of the sound file, etc.
                                                                                   # Leave blank if none are needed
# Registry &amp; throttling settings
$myKey = "SCOM_PowerShell_Scripts" # Reg key name to use
$myValueName = "LastRunTime" # Data value
$interval = 5 # Wait at least this long, in minutes
# Initialize a couple things
$firstRun = $False
$throttle = $False

# We use the OpsMgr API only because it’s a very quick and simple way to log to the eventviewer
$momAPI = New-Object -comObject "MOM.ScriptAPI"
# LogScriptEvent Severities
$momErr = 1
$momWarn = 2
$momInfo = 4
# Setup some event ids to use
$errID = 11000
$warnID = 11001
$infoID = 11002

$myName = $MyInvocation.MyCommand.Name # Grab script name

### Registry throttling settings
# First see if our key exists, if not, create it and populate it with the current date/time
# and set $firstRun to $True
If(!$(Test-Path HKLM:\SOFTWARE\$myKey)) {
        New-Item -Path HKLM:\Software\$myKey
        New-ItemProperty -Path HKLM:\SOFTWARE\$myKey -Name $myValueName -Value (Get-Date)
        $firstRun = $True
        }

# If this isn’t the first run, compare previous time with current time - if last run is $interval
# minutes ago or higher, carry on, otherwise exit
If(!($firstRun)) {
        $lastRun = (Get-ItemProperty -Path HKLM:\SOFTWARE\$myKey).$myValueName
        Set-ItemProperty -Path HKLM:\SOFTWARE\$myKey -Name $myValueName -Value (Get-Date)
                If(((Get-Date) - [DateTime]$lastRun).TotalMinutes -ge $interval) {
                $throttle = $False
                } else {
                $throttle = $True
                }
        }

# Function DecipherRetCode accepts an integer, and returns the failure assigned to that code.
# This only returns the most common failures, such as permissioning and the like
Function DecipherRetCode([int]$retCode) {
        switch ($retCode) {
                0 {return "Success"}
                2 {return "Access Denied"}
                3 {return "Insufficient Privilege"}
                8 {return "Unknown Failure"}
                21 {return "Invalid Parameter"}
                default {return "$($retCode) is uncommon, and will need to be researched manually. "}
        }
}

# This line is actually the entire script.
If($throttle) {
        # Throttling - cancel response
        $momAPI.LogScriptEvent($myName, $warnID, $momWarn, "Notification Workflow requested that $($myname) run, but last response ran less then $($interval) minutes ago. Exiting.")
        $momAPI = $null
        exit
} else {
$retCode = ([WMICLASS]"\\$remoteMachine\root\cimv2:win32_process").Create("$myExe $myExeParams")
        # If $retCode = 0 ($false) exit the If, anything else is $True, and will log it
        If($retCode) {
                $momAPI.LogScriptEvent($myName, $errID, $momErr, "Error creating process. Error Code: $($retcode) Error Message: $(DecipherRetCode $retCode)")
        }
$momAPI = $null
exit
}
