function Get-HarddriveModel {
  <#
    .NOTES
        Author: greg zakharov
  #>
  (gp (
      Join-Path $key (
        'Enum\' + (gp (Join-Path ($key = 'HKLM:\SYSTEM\CurrentControlSet') 'Services\Disk\Enum')).('0')
      )
    )
  ).FriendlyName
}
