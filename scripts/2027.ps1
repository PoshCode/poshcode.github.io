#MSDTC is needed by SQL Server Linked Servers
#This script checks whether MSDTC has been configured for network access
#See KB http://support.microsoft.com/default.aspx?scid=kb;en-us;816701 for steps to enable
#All values except AllowOnlySecureRpcCalls should be true
param($computerName=$env:computerName)

#On an x64 system the registry keys for MSDTC will only be accessible from an x64 shell.
#See http://gallery.technet.microsoft.com/ScriptCenter/en-us/6062bbfc-53bf-4f92-994d-08f18c8324c0 for details and workaround
#This script just checks for condition rather than workaround issue.

$is64 = [bool](gwmi win32_operatingsystem -computer $computerName | ?{$_.caption -like "*x64*" -or $_.OSArchitecture -eq'64-bit'})
$isShell32 = [bool]((Get-Process -Id $PID | ?{$_.path -like "*SysWOW64*"}) -or !([IntPtr]::Size -eq 8))

if ($is64 -and $isShell32)
{Write-Warning "Unable to open registry keys because $computerName is running an x64 OS. Script must be run from a PowerShell x64 shell" }
else
{
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$computerName)
    $msdtcKey = $reg.OpenSubKey("SOFTWARE\\Microsoft\\MSDTC")
    $securityKey = $msdtcKey.OpenSubKey("Security")
    new-object psobject -property @{ComputerName=$computerName;AllowOnlySecureRpcCalls=[bool]$msdtcKey.GetValue('AllowOnlySecureRpcCalls');TurnOffRpcSecurity=[bool]$msdtcKey.GetValue('TurnOffRpcSecurity');
                      NetworkDtcAccessAdmin=[bool]$securityKey.GetValue('NetworkDtcAccessAdmin');NetworkDtcAccessClients=[bool]$securityKey.GetValue('NetworkDtcAccessClients');
                      NetworkDtcAccessInbound=[bool]$securityKey.GetValue('NetworkDtcAccessInbound');NetworkDtcAccessOutbound=[bool]$securityKey.GetValue('NetworkDtcAccessOutbound');
                      NetworkDtcAccessTransactions=[bool]$securityKey.GetValue('NetworkDtcAccessTransactions');XaTransactions=[bool]$securityKey.GetValue('XaTransactions')}
}
