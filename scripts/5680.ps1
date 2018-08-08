$PSConfig = Get-ItemProperty "HKLM:\$([PSObject].Assembly.GetType(
  'System.Management.Automation.Utils'
).GetMethod(
  'GetRegistryConfigurationPath', [Reflection.BindingFlags]40
).Invoke($null, @($null)))\*" | Select-Object Path, ExecutionPolicy

$PSConfig.ExecutionPolicy #it equals Get-ExecutionPolicy
$PSConfig.Path #it equals ($PSHome + '\powershell.exe')
