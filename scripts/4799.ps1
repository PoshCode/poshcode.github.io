Set-Alias clockres Get-ClockRes

function Get-ClockRes {
  begin {
    try { $asm = [ClockRes] } catch [Management.Automation.RuntimeException] {
      $AsmBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(
        (New-Object Reflection.AssemblyName('NatMet')), [Reflection.Emit.AssemblyBuilderAccess]::Run
      )
      $ModBuilder = $AsmBuilder.DefineDynamicModule('NatMet', $false)
      $Attributes = 'AnsiClass, Class, Public, Sealed, BeforeFieldInit'
      $TypBuilder = $ModBuilder.DefineType('ClockRes', $Attributes)
      [void]$TypBuilder.DefinePInvokeMethod('GetSystemTimeAdjustment', 'kernel32.dll',
        [Reflection.MethodAttributes]22, [Reflection.CallingConventions]1, [Boolean],
        @([UInt32].MakeByRefType(), [UInt32].MakeByRefType(), [Boolean].MakeByRefType()),
        [Runtime.InteropServices.CallingConvention]::Winapi, 'Auto'
      )
      $asm = $TypBuilder.CreateType()
    }
    
    [UInt32]$Adjustment = 0
    [UInt32]$Increment = 0
    [Boolean]$AdjustmentDisabled = $false
  }
  process {
    [void]$asm::GetSystemTimeAdjustment([ref]$Adjustment, [ref]$Increment, [ref]$AdjustmentDisabled)
    Write-Host Current timer interval: $($Increment / 10000.0) ms. -fo Yellow
  }
  end {''}
}
