function Get-HarddriveModel {
  <#
    .NOTES
        Author: greg zakharov
  #>
  $key = 'HKLM:\SYSTEM\CurrentControlSet'
  (gp (
      Join-Path $key (
        'Enum\' + (gp (Join-Path $key 'Services\Disk\Enum')).('0')
      )
    )
  ).FriendlyName
}
