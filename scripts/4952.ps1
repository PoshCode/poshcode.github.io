#the cool way
([String][Environment]::OSVersion.Version).Substring(0, 8)

#the ugly way
(gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | select @{N='Ver'; E={'{0}.{1}' -f $_.CurrentVersion, $_.CurrentBuildNumber}}).Ver

#the shortest way
([Regex]"(\d+\.){2}\d+").Match((cmd /c ver)[1]).Value

#the longest way
function Get-OSVersion {
  $bf = [Reflection.BindingFlags]
  
  $Win32Native = ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
    $_.ManifestModule.ScopeName.Equals('CommonLanguageRuntimeLibrary')
  }).GetType('Microsoft.Win32.Win32Native')
  
  $OSVERSIONINFO = $Win32Native.GetNestedType('OSVERSIONINFO', (32 -as $bf))
  $GetVersionEx = $Win32Native.GetMethod('GetVersionEx', (40 -as $bf), $null, @($OSVERSIONINFO), $null)
  
  $ver = $OSVERSIONINFO.GetConstructors((36 -as $bf))[0].Invoke($null)
  
  function get([String]$Filed) {
    return [String]$OSVERSIONINFO.GetField($Filed, (36 -as $bf)).GetValue($ver)
  }
  
  if ($GetVersionEx.Invoke($null, @($ver))) {
    '{0}.{1}.{2}' -f (get 'MajorVersion'), (get 'MinorVersion'), (get 'BuildNumber')
  }
}
