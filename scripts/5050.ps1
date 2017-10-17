#requires -version 2.0
function ConvertFrom-Win32Error {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({$_.GetType().Name -eq 'Int32'})]
    [Int32]$ErrorCode
  )
  
  return (New-Object ComponentModel.Win32Exception($ErrorCode)).Message
}
