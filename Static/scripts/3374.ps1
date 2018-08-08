function Start-Countdown{
<#
	.Synopsis
	 Initiates a countdown on your session.  Can be used instead of Start-Sleep.
	 Use case is to provide visual countdown progress during "sleep" times
	 
	.Example
	 Get-Countdown -Seconds 10
	 
	 This method will clear the screen and display descending seconds
	
	.Example
	 Get-Countdown -Seconds 10 -ProgressBar
	 
	 This method will display a progress bar on screen without clearing.
	 	 
	.Link
	 http://www.vtesseract.com/
	.Description
====================================================================
Author(s):		Josh Atwell <josh.c.atwell@gmail.com>
File: 			Start-Countdown.ps1
Date:			2012-04-19
Revision: 		1.0
References:		www.vtesseract.com

====================================================================
Disclaimer: This script is written as best effort and provides no 
warranty expressed or implied. Please contact the author(s) if you 
have questions about this script before running or modifying
====================================================================
#>
Param(
[INT]$Seconds = (Read-Host "Enter seconds to countdown from"),
[Switch]$ProgressBar,
[String]$Message = "Blast Off!"
)
Clear-Host
while ($seconds -ge 1){
If($ProgressBar){
	Write-Progress -Activity "Countdown" -SecondsRemaining $Seconds -Status "Time Remaining"
	Start-Sleep -Seconds 1
}ELSE{
	Write-Output $Seconds
	Start-Sleep -Seconds 1
	Clear-Host
}
$Seconds --
}
Write-Output $Message
}
