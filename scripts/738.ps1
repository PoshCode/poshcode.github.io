# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2007
# 
# NAME: Battery-Prompt.ps1
# 
# AUTHOR: Jeremy D. Pavleck , Pavleck.NET
# DATE  : 12/18/2008
# 
# COMMENT: Lists the percentage of battery remaining above your prompt inside the console.
#	Difficulty level: OVER 9000!!!!!!!!!!!!!!!!
# 
# ==============================================================================================
$GLOBAL:BatteryDisplayAtPercent = 101 # When should get start displaying status
									  # Anything over 100 means to show it all
Function GLOBAL:Get-BattLevel($minLevel) {
$charge = (Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining
If(!$charge) {break} # Not on a laptop, or no battery, so exit
Switch($charge) {
{($charge -ge 101) -and ($minLevel -ge 101)} {Write-Host "Batt: CHARGING" -ForeGroundColor Green}
{($charge -ge 80) -and ($charge -le 100) -and ($charge -le $minLevel)} {Write-Host "Batt: $charge%" -ForeGroundColor Green}
{($charge -ge 40) -and ($charge -le 79) -and ($charge -le $minLevel)} {Write-Host "Batt: $charge%" -ForeGroundColor Yellow}
{($charge -ge 16) -and ($charge -le 39) -and ($charge -le $minLevel)} {Write-Host "Batt: $charge%" -ForeGroundColor Magenta}
{($charge -ge 1) -and ($charge -le 15) -and ($charge -le $minLevel)} {Write-Host "Batt: $charge%" -ForeGroundColor Red}
default {break}
	}
 }
 
function prompt() {
Get-BattLevel $GLOBAL:BatteryDisplayAtPercent
}

