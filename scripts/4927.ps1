<#
  .DESCRIPTION
      Returns the current original equipment manufacter (OEM)
      code page identifier for the operating system.
  .NOTES
      Author: greg zakharov
#>
[PSObject].Assembly.GetType(
  'System.Management.Automation.EncodingConversion'
).GetNestedType(
  'NativeMethods', [Reflection.BindingFlags]32
).GetMethod(
  'GetOEMCP', [Reflection.BindingFlags]40
).Invoke($null, @())
