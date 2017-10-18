function Get-DistanceOnEarth {
<#
.SYNOPSIS
  Calculates distance between points on the Earth.
.DESCRIPTION
  Implementation of the Haversine equation to calculate distance over the surface of a sphere.
.INPUTTYPE
  Pipeline object with the following parameters: LATITUDE1 LONGITUDE1 LATITUDE2 LONGITUDE2
#>
    Begin
    {
        $toRad = 0.0174532925 # radians in 1 degree
        $R = 3963.1676  # approx. radius of earth in milies
        #$R = 6378.1  # approx. radius of earth in km
    }
    
    Process
    {
        $lat1 = $_.LATITUDE1
        $lon1 = $_.LONGITUDE1
        $lat2 = $_.LATITUDE2
        $lon2 = $_.LONGITUDE2
        $dLat = ($lat2 - $lat1) * $toRad
        $dLon = ($lon2 - $lon1) * $toRad
        $a = ( ( ([Math]::Sin($dLat/2)) * ([Math]::Sin($dLat/2)) ) + ([Math]::Cos($lat1 * $toRad) * [Math]::Cos($lat2 * $toRad) * ( ([Math]::Sin($dLon/2)) * ([Math]::Sin($dLon/2)) )))
        $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1-$a))
        $d = $R * $c
        $d = [Math]::Round($d,3)
        $_ | Add-Member -MemberType NoteProperty -Name Distance -Value $d
        Write-Output $_
    }
}
