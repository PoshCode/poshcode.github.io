function Get-WmiNSTree {
  <#
    .SYNOPSIS
        Prints WMI NameSpaces tree.
    .EXAMPLE
        Get-WmiNSTree
    .EXAMPLE
        Get-WmiNSTree 'root\default'
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [String]$NameSpace = 'root'
  )
  
  function get([String]$root, [Int32]$deep=1) {
    (New-Object Management.ManagementClass(
        $root, [Management.ManagementPath]'__NAMESPACE', $null
      )
    ).PSBase.GetInstances() | sort | % {
      '{0}{1}--{2}' -f (' ' * 3 * $deep), [Char]31, $_.Name
      get $($root + '\' + $_.Name) (++$deep)
      --$deep
    }
  }
  
  try {get $NameSpace} catch {Write-Warning 'wrong namespace!'}
}
