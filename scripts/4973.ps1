#requires -version 2.0
function Find-AntiVirus([String]$VendorName) {
  <#
    .EXAMPLE
        PS C:\>Find-Antivirus 'Kaspersky'
        #or just (if you have enough rights)
        PS C:\>Find-AntiVirus
    .NOTES
        Author: greg zakharov
  #>
  try {
    if ([String]::IsNullOrEmpty($VendorName)) {
      (New-Object Management.ManagementClass(
        [Management.ManagementPath]('\\.\root\SecurityCenter:AntiVirusProduct')
      )).PSBase.GetInstances() | fl *
    }
    else {
      gci HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | ? {
        $_.Name -notmatch 'KB(\d+)'
      } | % {
        if ((gp $_.PSPath).Publisher -match $VendorName) { gp $_.PSPath }
      }
    }
  }
  catch [Management.Automation.MethodInvocationException] {
    $_.Exception.Message
  }
}
