function Get-NType {
  <#
    .NOTES
        Author: greg zakharov
  #>
  $types = @{WinNT='WorkStation';ServerNT='Server';LanmanNT='DomainController'}
  $types[(gp HKLM:\SYSTEM\CurrentControlSet\Control\ProductOptions).ProductType]
}
