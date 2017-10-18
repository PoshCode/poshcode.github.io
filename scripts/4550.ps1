# You can add this line in your profile instead of here... 
Set-PSBreakpoint -Variable BreakOnException -Mode ReadWrite

Write-Host "Enter"

# then just add this where you want to enable breaking on exceptions
trap { $BreakOnException; continue }

Write-Host "Starting"
throw "stones"
Write-Host "Ending"
