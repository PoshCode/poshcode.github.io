function Get-WmiNSTree {
  param(
    [Parameter(Mandatory=$true)]
    [String]$NameSpace
  )
  
  function get([String]$root, [Int32]$deep=1) {
    (New-Object Management.ManagementClass(
        $root, [Management.ManagementPath]'__NAMESPACE', $null
      )
    ).PSBase.GetInstances() | sort | % {
      '{0}|__{1}' -f (' ' * 3 * $deep), $_.Name
      get $($root + '\' + $_.Name) (++$deep)
      --$deep
    }
  }
  
  try {get $NameSpace} catch {Write-Warning 'namespace does not exist!'}
}

#examples
#Get-WmiNSTree 'root' - prints all available namespaces
#Get-WmiNSTree 'root\rsop' - prints all namespaces of root\rsop namespace
#and etc.
