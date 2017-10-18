# Get-ProcessCount uses 2 main variables, server and process name.
# Process name is typically the end exe, such as "svchost.exe"
# Will accept unnamed args (Get-ProcessCount servername processname)
# or named args (Get-ProcessCount -Computer servername -Process processname)
Function Get-ProcessCount([string]$process, [string]$computer = "localhost", [switch]$guess) {
$i = 0
$procList = Get-WmiObject -Class Win32_Process -Computer $computer
	foreach($proc in $procList) {
		If($proc.name -eq $process)
		{
			$i++
		}
	}
	
	Function Try-Guessing([string]$process) {
		foreach($proc in $procList) {
			If($proc.Name -match $process) {
				$possible += @($($proc.name))
				}
		}
		If($possible.Count -ge 1) {
			$uniq = $possible | Get-Unique
			foreach($proc in $uniq) {
				Write-Host "Did you mean $($proc)?" -ForeGroundColor Magenta
				}
		} else {
		Write-Host "I tried guessing, but I couldn't find $($process) that way, either. Sorry." -ForeGroundColor Green
		}
	}	
If($i -ge 1) {
	Write-Host "There are $i instances of $process on $computer" -ForegroundColor Green
	} else {
	Write-Host "0 instances of $process found on $computer" -ForegroundColor Green
	Try-Guessing $process
	}
}

