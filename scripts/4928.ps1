<#
  .DESCRIPTION
      Two ways uncover SecureString.
  .NOTES
      Author: greg zakharov
#>
function Show-StringA([Security.SecureString]$s = $(Read-Host "Input something" -as)) {
  [PSObject].Assembly.GetType('System.Management.Automation.Utils').GetMethod(
    'GetStringFromSecureString', [Reflection.BindingFlags]40
  ).Invoke($null, @($s))
}

function Show-StringB([Security.SecureString]$s = $(Read-Host "Input something" -as)) {
  [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
  )
}
