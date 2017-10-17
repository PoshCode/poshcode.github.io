#function Find-InstalledNETFrameworks {
  $dot = [PSObject].Assembly.GetType('System.Management.Automation.PsUtils').GetMethod(
    'IsDotNetFrameworkVersionInstalled', [Reflection.BindingFlags]'NonPublic, Static'
  )
  '2.0', '3.0', '3.5', '4.0', '4.5' | % {
    'Version {0} -> Installed {1}' -f $_, $dot.Invoke($null, @([Version]$_))
  }
#}
