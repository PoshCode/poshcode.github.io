#Autor:  Mateusz &#346;wietlicki 
#Site:   mateusz.swietlicki.net
#Create: 2010-10-04

function Invoke-Shutdown
{
    &"$env:SystemRoot\System32\shutdown.exe" -s
}
function Invoke-Reboot
{
    &"$env:SystemRoot\System32\shutdown.exe" -r
}
function Invoke-Logoff
{
    &"$env:SystemRoot\System32\shutdown.exe" -l
}
Set-Alias lg Invoke-Logoff

function Invoke-Standby
{
    &"$env:SystemRoot\System32\rundll32.exe" powrprof.dll,SetSuspendState Standby
}
Set-Alias csleep Invoke-Standby

function Invoke-Hibernate
{
    &"$env:SystemRoot\System32\rundll32.exe" powrprof.dll,SetSuspendState Hibernate
}
