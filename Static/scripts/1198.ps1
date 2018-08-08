Coresponding to the Scripting Guy blog "How Can I Both Save Information in a File and Display It on the Screen?"
(http://blogs.technet.com/heyscriptingguy/archive/2009/07/07/hey-scripting-guy-how-can-i-both-save-information-in-a-file-and-display-it-on-the-screen.aspx):
My comment is:
All of the above is cool but can't work if you want your Write-Host or Write-Debug to be redirected to file as well as printing to console.

Maybe the Scripting Guy can explain why (AFAIK these cmdlets are already redirecting their output).

so these examples don't work!:

Write-Debug "blablabla" > File.txt

Write-Debug "blablabla" | Out-File -filepath C:\File.txt

Write-Debug "blablabla" | Tee -filepath C:\File.txt

Here's the function I finally use:

Function WriteToDebug ([string]$DebugMessage)

{

$ScriptOut = ((Get-Date -format G )  + "`t$DebugMessage" )

Out-File -FilePath $LogFileDebug -Append -InputObject $ScriptOut

Write-Debug "$ScriptOut"

}

Where i replaced every Write-Debug in the script to WriteToDebug.
