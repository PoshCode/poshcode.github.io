Set-Alias sudo Invoke-RunAs

function Invoke-RunAs {
  <#
    .LINK
        Follow me on twitter @gregzakharov
        http://msdn.microsoft.com/en-US/library/system.diagnostics.aspx
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$Program,
    
    [Parameter(Mandatory=$false)]
    [String]$Arguments,
    
    [Parameter(Mandatory=$false)]
    [Switch]$LoadProfile = $false,
    
    [Security.SecureString]$UserName = (Read-Host "Admin name" -as),
    [Security.SecureString]$Password = (Read-Host "Enter pass" -as)
  )
  
  function str([Security.SecureString]$s) {
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    )
  }
  
  $psi = New-Object Diagnostics.ProcessStartInfo
  $psi.Arguments = $Arguments
  $psi.Domain = [Environment]::UserDomainName
  $psi.FileName = $Program
  $psi.LoadUserProfile = $LoadProfile
  $psi.Password = $Password
  $psi.UserName = (str $UserName)
  $psi.UseShellExecute = $false
  
  [void][Diagnostics.Process]::Start($psi)
}
