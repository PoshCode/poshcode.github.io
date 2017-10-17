function Get-GrowthRate {
	param( $Start, $End, $Period ) 
@@	$rate = [math]::Abs( [math]::Pow( ( $End / $Start ),( 1 / ($Period - 1 ) ) - 1 )
	"{0:P}" -f $rate
}
