function Get-DirectoryTree {
  <#
    .SYNOPSIS
        Prints a directory tree.
    .EXAMPLE
        Get-DirectoryTree 'E:'
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]$PathName
  )
  
  function get([String]$path, [Int32]$deep=1) {
    try {
      [IO.Directory]::GetDirectories($path) | % {
        '{0}{1}--{2}' -f (' ' * 3 * $deep), [Char]166, (Split-Path -leaf $_)
        get $_ (++$deep)
        --$deep
      }
    }
    catch {$_.Exception.Message}
  }
  
  Write-Host $PathName -fo Magenta
  get $PathName
}
