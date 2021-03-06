########################################################
# This function will prompt the user asking if they want
# to start a transcript file. It will loop until the user
# types y or n. If the user selects y, the script will
# check to see if the transcript exists. If it doesn't
# it is created. If it does, the transcript file is created.
# The transcript started message, and folder creation
# message are all piped to null. Modified script from
# Shay's site http://blogs.microsoft.co.il/blogs/ScriptFanatic
########################################################
function Save-Transcript{
$global:TRANSCRIPT = "C:\Scripts\PowerShell\Transcripts\PSLOG_{0:dd-MM-yyyy}.txt" -f (Get-Date)
Start-Transcript -Append | out-null
}
 
do{$a = Read-Host "Do you want to start a transcript? y/n"}
Until($a -ne "") 
If($a -eq "y")
{
if (Test-Path C:\Scripts\PowerShell\Transcripts)
{
"C:\Scripts\PowerShell\Transcripts"
}
else
{
New-Item C:\Scripts\PowerShell\Transcripts -type directory | out-null
}
Save-Transcript
}
