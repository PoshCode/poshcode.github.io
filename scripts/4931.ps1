#requires -version 2.0
Set-Alias clockres Get-ClockRes

function Get-ClockRes {
  <#
    .NOTES
        Author: greg zakharov
  #>
  begin {
    $cd = [AppDomain]::CurrentDomain
    $Attributes = 'AnsiClass, Class, Public, Sealed, BeforeFieldInit'
    
    if (!($cd.GetAssemblies() | ? {
      $_.FullName.Contains('NativeUtils')
    })) {
      $type = (($cd.DefineDynamicAssembly(
        (New-Object Reflection.AssemblyName('NativeUtils')), [Reflection.Emit.AssemblyBuilderAccess]::Run
      )).DefineDynamicModule('NativeUtils', $false)).DefineType('ClockRes', $Attributes)
      [void]$type.DefinePInvokeMethod('NtQueryTimerResolution', 'ntdll.dll',
        [Reflection.MethodAttributes]'Public, Static, PinvokeImpl',
        [Reflection.CallingConventions]::Standard, [Int32],
        @([Int32].MakeByRefType(), [Int32].MakeByRefType(), [Int32].MakeByRefType()),
        [Runtime.InteropServices.CallingConvention]::Winapi, [Runtime.InteropServices.CharSet]::Auto
      )
      $global:clockres = $type.CreateType()
    }
  }
  process {
    try {
      [Int32]$min = $max = $cur = 0
      if (($clockres::NtQueryTimerResolution([ref]$min, [ref]$max, [ref]$cur)) -ge 0) {
        'Current timer interval: {0} ms' -f ($cur / 10000)
        'Minimum timer interval: {0} ms' -f ($min / 10000)
        'Maximum timer interval: {0} ms' -f ($max / 10000)
      }
    }
    catch [Management.Automation.RuntimeException] {
      Write-Host $_.Exception.Message -fo Red
    }
  }
  end {''}
}
