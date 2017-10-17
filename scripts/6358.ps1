# this script is a part of Func module (https://github.com/gregzakh/Func)
function Set-Privilege {
  param(
    [Parameter(Position=0)]
    [ValidateRange(2, 35)]
    [UInt32]$Privilege = 19, #SeShutdownPrivilege
    
    [Parameter(Position=1)]
    [Switch]$Enable = $true
  )
  
  begin {
    $ptr, $null = Get-ProcAddress ntdll RtlAdjustPrivilege
    $RtlAdjustPrivilege = Set-Delegate $ptr `
         '[Action[UInt32, Boolean, Boolean, Text.StringBuilder]]'
    $ret = New-Object Text.StringBuilder
  }
  process {
    $RtlAdjustPrivilege.Invoke($Privilege, $Enable, $false, $ret)
  }
  end {}
}
