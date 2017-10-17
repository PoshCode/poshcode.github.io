#Got distracted


1..1000 | %{1..80 | % {Write-Host (' '*(Get-Random -Maximum 5 -Minimum 0)) -BackgroundColor ([enum]::GetNames([system.consolecolor]) | Get-Random -Count 1) -ForegroundColor ([enum]::GetNames([system.consolecolor]) | Get-Random -Count 1) -NoNewline}}
