#requires -version 2.0
function Get-MimeType {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeLine=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    Add-Type -AssemblyName System.Web
    $FileName = cvpa $FileName
  }
  process {
    ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
      $_.FullName.Contains('System.Web')
    }).GetType(
      'System.Web.MimeMapping'
    ).GetMethod(
      'GetMimeMapping', [Reflection.BindingFlags]40
    ).Invoke(
      $null, @($FileName)
    )
  }
  end {}
}
