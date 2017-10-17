#requires -version 2.0
function Get-MacAddress {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  if ([String]::IsNullOrEmpty((arp -a | ? {$_ -match '0x\w+'}))) {
    Write-Warning "could not parse ARP table.`n`n"
    return
  }
  
  ([Regex]"(\d{2}\s){6}").Match(
    (route print | ? {$_.StartsWith($matches[0])})
  ).Value.Trim() -replace ' ', '-'
}
