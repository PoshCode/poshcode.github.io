
  #############################################################################################
#
# NAME: Show-EventLog.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:06/08/2013
#
# COMMENTS: Load function for Showing the windows event logs on a server in Out-GridView
# ————————————————————————
# Define a server an event log the number of events and display
# pipe to this and then to out-gridview to only show Errors -      where {$_.entryType -match "Error"}

Function Show-EventLog ($Server,$log,$Latest)
{
Get-EventLog  -computername $server -log $log -newest $latest | Out-GridView
}
