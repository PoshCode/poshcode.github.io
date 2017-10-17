function Set-Countdown([Single]$Timer) {
  <#
    .EXAMPLE
        PS C:\> Set-Countdown 0.3
        Set timer on 17 seconds.
  #>
  begin {
    $end = (date).AddMinutes($Timer)
    $spn = New-TimeSpan (date) $end
  }
  process {
    while($spn -gt 0) {
      $spn = New-TimeSpan (date) $end
      Write-Host ("`r{0:d2}:{1:d2}:{2:d2}" -f $spn.Hours, $spn.Minutes, `
                                               $spn.Seconds) -no -fo Cyan
    }
  }
  end {
    #some action
    ""
  }
}
