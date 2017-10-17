 
function AddPortForward {
    param(
        [String] $Connection,
        [UInt16] $SrcPort,
        [String] $DstHost,
        [UInt16] $DstPort
    )
    $baseSessionFolder = 'Software\SimonTatham\PuTTY\Sessions'
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($baseSessionFolder + "\" + $Connection, $true)
    $currentValue = $key.GetValue("PortForwardings")
    $newValue = $currentValue + "L" + $SrcPort + "=" + $DstHost + ":" + $DstPort + ","
    $key.SetValue("PortForwardings", $newValue, [Microsoft.Win32.RegistryValueKind]::String)
 }

function GetPortForwards {
    $baseSessionFolder = 'HKCU:\Software\SimonTatham\PuTTY\Sessions'
    gci $baseSessionFolder | % {
    $key = $_
    $key.GetValue("PortForwardings").Split(',', [System.StringSplitOptions]::RemoveEmptyEntries) | % {
        $parts = $_.Split('=')
        New-Object PSObject -Property @{
            Connection = $key.PSChildName
            SRC = $parts[0]
            DST = $parts[1]
        }
    }
 }
}
