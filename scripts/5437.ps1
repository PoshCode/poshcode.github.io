$ErrorActionPreference = 1

[void](
  Set-Variable -Name z_ -Value (Join-Path HKCU:\Software (
    -join (1..7 | % {$rnd = New-Object Random}{[Char]$rnd.Next(97, 122)})
  )) -Option constant -Scope global -PassThru
)
[void](New-Item $z_)

if (!(Test-Path $z_)) {
  Write-Warning 'something is wrong!'
  break
}

[void](
  Register-EngineEvent -SourceIdentifier (
    [Management.Automation.PSEngineEvent]::Exiting
  ) -Action {Remove-Item $z_}
)
