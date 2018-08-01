#requires -version 2.0
function Get-AVLocation {
  <#
    .DESCRIPTION
        Looks for a path of installed antivirus.
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$VendorName
  )
  
  try {
    gci HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | % {
      if ($_.PSChildName.EndsWith('}')) {
        if ((gp $_.PSPath).Publisher -match $VendorName) {
          (gp $_.PSPath).InstallLocation
        }
      }
    }
  }
  catch {
    $_.Exception.Message
  }
}
