#requires -version 5
function Get-LoadedDrivers {
  <#
    .SYNOPSIS
        Get list of the loaded drivers.
    .NOTES
        Author: greg zakharov
  #>
  begin {
    if (($$ = [PSObject].Assembly.GetType(
      'System.Management.Automation.TypeAccelerators'
    ))::Get.Keys -notcontains 'Marshal') {
      [void]$$::Add('Marshal', [Runtime.InteropServices.Marshal])
    }
    
    $NtQuerySystemInformation = [Regex].Assembly.GetType(
      'Microsoft.Win32.NativeMethods'
    ).GetMethod('NtQuerySystemInformation')
    $ret = 0
  }
  process {
    try {
      $ptr = [Marshal]::AllocHGlobal(1024)
      if ($NtQuerySystemInformation.Invoke($null, ($par = [Object[]]@(
          11, $ptr, 1024, $ret
      ))) -ne 0) {
        $ptr = [Marshal]::ReAllocHGlobal($ptr, [IntPtr]$par[3])
        if ($NtQuerySystemInformation.Invoke($null, @(11, $ptr, $par[3], 0)) -ne 0) {
          throw New-Object InvalidOperationException('Unable get correct buffer length.')
        }
      }
      
      0..([Marshal]::ReadInt32($ptr) - 1) | % {$i = 12}{
        New-Object PSObject -Property @{
          Address = '0x{0:x}' -f [Marshal]::ReadInt32($ptr, $i)
          Size    = [Marshal]::ReadInt32($ptr, $i + 4)
          Path    = ([Marshal]::PtrToStringAnsi([IntPtr](
              $ptr.ToInt64() + $i + 20), 256
          )).Split("`0")[0]
        }
        $i += 20 + 256 + 8
      } | Select-Object Address, Size, Path
    }
    catch {
      $_.Exception
    }
    finally {
      if ($ptr) {
        [Marshal]::FreeHGlobal($ptr)
      }
    }
  }
  end {
    [void]$$::Remove('Marshal')
  }
}
