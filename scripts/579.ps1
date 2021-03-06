# Description: 	Create Events in Application log
# Date:			03-05-2007
# Author:		Stefan Stranger & Ken 
# Explanation:	If you only wish to write to the event log you must do two things. The first is to create or specify a Source. 
#				The second is to call the WriteEntry method. The source would be your application name, by default, 
#				if you create a source that is new then your log entry will be written to the Application Log. To WriteEntry method does the actual writing to the Event Log.
#				ev.WriteEntry(&#65533;My event text&#65533;, System.Diagnostics.EventLogEntryType.Information, myeventid)
# Changes:		Ken made changes in the Write-Eventlog function: 1) modified it so that you can log events in any Event Log using the Source to look up which log to use, 
#				added a check in to ask if the user wants to create the missing Source in the Application log rather than just creating it, 
#               never know when you will msispell a source ;) 3) Modified the question for description to also say or Params/Param[1].



#Check if user is admin
function get-Admin {
 $ident = [Security.Principal.WindowsIdentity]::GetCurrent()
 
 foreach ( $groupIdent in $ident.Groups ) {
  if ( $groupIdent.IsValidTargetType([Security.Principal.SecurityIdentifier]) ) {
   $groupSid = $groupIdent.Translate([Security.Principal.SecurityIdentifier])
   if ( $groupSid.IsWellKnown("AccountAdministratorSid") -or $groupSid.IsWellKnown("BuiltinAdministratorsSid")){
    return $true
   }
  }
 }
 return $false
}

$Result = get-Admin

if ($Result -eq $False) 
  {
    write-host "Better be an admin for this script."
	#exit
  }

function Write-EventLog { 
   param ([string]$source = $(read-host "Please enter Event Source"), [string]$type = $(read-host "Please enter Event Type [Information, Warning, Error]"), [int]$eventid = $(read-host "Please enter EventID"), [string]$msg = $(read-host "Please enter Event Description or Params/Param[1] value"))
   #Create the source, if it does not already exist.
   if(![System.Diagnostics.EventLog]::SourceExists($source))
   {
      #Create based on user response
      [string]$create = $(read-host "Source doesn't exist. Do you want to create in the Application Log? [Yes or No]")
      if(($create -eq "Yes") -or ($create -eq "Y"))
      {
         [System.Diagnostics.EventLog]::CreateEventSource($source,'Application')
         $logfile = 'Application'
         write-host "Source created and registered in the $logfile Log"
      }
      else
      {
         write-host "** Script Terminated ** User didn't want to create missing Source"
         exit 0
      }
   }
   else 
   {
      $logfile = [System.Diagnostics.EventLog]::LogNameFromSourceName($source,'.')
      write-host "Source exists and is registered in the $logfile Log"
   }
   #Check if Event Type is correct
   switch ($type) 
   { 
      "Information" {} 
      "Warning" {} 
      "Error" {} 
      default {"Event type is invalid";exit}
   }
   $log = New-Object System.Diagnostics.EventLog 
   $log.set_log($logfile) 
   $log.set_source($source)
   $log.WriteEntry($msg,$type,$eventid)
}

Write-Eventlog
Write-Host "Event created"
