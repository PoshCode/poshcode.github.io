function WinFirewall-Disabled(){
param (
$computer
)
c:\PsTools\PsExec.exe \\"$computer" sc config sharedaccess start= disabled
}
