Clear
    $Host.UI.RawUI.WindowTitle = "Quitting Time Clock"
    $Size = $Host.UI.RawUI.WindowSize
    $Size.Width = 30
    $Size.Height = 3
    $Host.UI.RawUI.WindowSize = $Size
Write-Host "What is today's quitting time?"
$qt = Read-Host "(HH:mm:ss)"
If($qt -eq "") {$qt = "16:00:01"} # Default quitting time is 4pm

Do {Clear
$tm = Get-Date -Format HH:mm:ss

# Every five minutes toggle the Scroll Lock key to prevent screen saver
If($tm.Substring(4,4) -eq "0:00" -or $tm.Substring(4,4) -eq "5:00"){
    $shell = New-Object -com "Wscript.Shell"
    $shell.sendkeys(“{ScrollLock}{ScrollLock}”)
    $shell.Dispose}

# Countdown timer code
    $ts = New-Timespan $(get-date) $qt
    Write-Host $([string]::Format("Time Remaining: {0:d2}:{1:d2}:{2:d2}",
    $ts.hours, $ts.minutes, $ts.seconds)) -ForegroundColor Cyan

# Display current time code
    Write-Host "         " -NoNewline
    Write-Host $tm -ForegroundColor Yellow
    sleep 1 }
Until ($tm -ge $qt)

# Start countdown to Logoff - five minutes after 'quitting time'
$LOTime = (Get-Date).AddMinutes(5).ToString("HH:mm:ss")
Do {Clear
    $LOCount = New-TimeSpan $(Get-Date) $LOTime
    Write-Host $([string]::Format("Logoff in: {0:d2}:{1:d2}:{2:d2}",
    $LOCount.Hours, $LOCount.Minutes, $LOCount.Seconds)) -ForegroundColor Red
    Sleep 1}
Until ($LOCount.Minutes -eq 0 -and $LOCount.Seconds -eq 0)
Shutdown /L /F
