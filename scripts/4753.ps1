#function Find-InstalledNETFrameworks {
  $asm = [PSObject].Assembly.GetType('System.Management.Automation.PsUtils')
  $dot = $asm.GetMethod(
    'IsDotNetFrameworkVersionInstalled', [Reflection.BindingFlags]'NonPublic, Static'
  )
  $asm.GetNestedType('FrameworkRegistryInstallation', 'NonPublic').GetFields(
    [Reflection.BindingFlags]'NonPublic, Static'
  ) | % {
    'Version {0, 13} -> Installed {1}' -f $_.Name, $dot.Invoke($null, @([Version]$_.GetValue($null)))
  }
#}
