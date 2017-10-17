#requires -version 2.0
Set-Alias fgac Find-GACAssembly

function Find-GACAssembly {
  <#
    .EXAMPLE
        PS C:\> Find-GACAssembly accessibility
    .EXAMPLE
        PS C:\> fgac System.DirectoryServices.AccountManagement
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]$AssemblyName
  )
  
  if (!(
    -join $AssemblyName[$AssemblyName.LastIndexOf('.')..$AssemblyName.Length]).ToLower().Equals('.dll')
  ) { $AssemblyName += '.dll' }
  
  $asm = [IO.Directory]::GetFiles(([Regex]"(?<=file:///)(.*)(?=GAC)").Match(
    ([AppDomain]::CurrentDomain.GetAssemblies()[0].Evidence | ? {
      $_.Value -ne $null
  }).Value), '*.dll', [IO.SearchOption]::AllDirectories) | ? { $_ -match $AssemblyName }
  
  if ($asm -eq $null) {
    Write-Host Nothing found.`n -fo Yellow
    break
  }
  
  try {
    $asm = ([Regex]"\/").Replace($asm, '\')
    New-Object PSObject -Property @{
      Path     = $asm
      FullName = [Reflection.AssemblyName]::GetAssemblyName($asm)
      Machine  = [Reflection.AssemblyName]::GetAssemblyName($asm).ProcessorArchitecture
    } | Format-List
  }
  catch {
    $_.Exception.Message
  }
}
