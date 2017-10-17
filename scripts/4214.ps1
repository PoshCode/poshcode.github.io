# Copy this to Documents\WindowsPowerShell\Modules\
# Generates extmap for a given strong-named assembly
# example:
#   ToExtMap "System.Threading.Tasks.dll" | Out-File -encoding ASCII System.Threading.Tasks.extmap.dll
function ToExtMap($assemblyPath) {
   $fullPath = (Get-ChildItem -filter $assemblyPath).FullName
   $fileName = (Get-ChildItem -filter $assemblyPath).Name
   $assembly = [System.Reflection.AssemblyName]::GetAssemblyName($fullPath)
   $assemblyName = $assembly.Name
   $assemblyVersion = $assembly.Version
   $publicKeyToken = -join($assembly.GetPublicKeyToken() | % {$_.ToString("X2") })
   @"
<?xml version="1.0" encoding="utf-8" ?>
<manifest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema">

  <assembly>
    <name>$assemblyName</name>
    <version>$assemblyVersion</version>
    <publickeytoken>$publicKeyToken</publickeytoken>
    <relpath>$fileName</relpath>
    <extension downloadUri="$assemblyName.zip" />
  </assembly>

</manifest>
"@

}
