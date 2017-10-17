function Get-ProtectionInfo([String]$Computer = '.', [Switch]$Toggle) {
  <#
    .SYNOPSIS
        Retrieves basic information about deployed security pockets such as
        antivirus and firewall.
    .EXAMPLE
        PS C:\>Get-ProtectionInfo
        Gets info about antivirus.
    .EXAMPLE
        PS C:\>Get-ProtectionInfo
        Gets info about firewall.
  #>
  switch ($Toggle) {
    $true   {$sig = 'FirewallProduct'}
    default {$sig = 'AntiVirusProduct'}
  }
  
  (New-Object Management.ManagementClass(
    [Management.ManagementPath]('\\' + $Computer + '\root\SecurityCenter:' + $sig)
  )).PSBase.GetInstances() | select displayName, companyName, versionNumber | fl
}
