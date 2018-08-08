function WinFirewall-Stoped(){
param (
$computer
)
c:\PsTools\PsExec.exe \\"$computer" sc stop sharedaccess
}
