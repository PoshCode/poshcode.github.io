function Get-VolumeId {
  $arr = @()
  $script:key = 'HKLM:\SYSTEM\MountedDevices'
  function pak([string]$mat) { return (gi $key | % {$_.Property} | ? {$_ -match $mat}) }
  pak 'Dos' | % {$h1 = @{}}{$h1.$_ = (gp -Path $key -Name $_).$_}
  pak 'Volume' | % {$h2 = @{}}{$h2.$_ = (gp -Path $key -Name $_).$_}
  
  foreach ($i in $h1.Keys) {
    foreach ($j in $h2.Keys) {
      if ([string]$h1.Item($i) -eq [string]$h2.Item($j)) {
        $arr += $i.Split('\')[2] + ' = ' + $j
      }
    }
  }
  $arr | sort
}
