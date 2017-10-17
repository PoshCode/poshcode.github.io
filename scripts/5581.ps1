function Remove-Alpha {
	param([Parameter(Mandatory=$true)]
		  [string]$ForegroundHex,
		  [string]$BackgroundHex = '#000000')
	
	Add-Type -Assembly System.Drawing -ErrorAction SilentlyContinue
	
	if(!$ForegroundHex.StartsWith('#')) {
		$ForegroundHex = '#' + $ForegroundHex
	}
	
	if(!$BackgroundHex.StartsWith('#')) {
		$BackgroundHex = '#' + $BackgroundHex
	}
	
	$fg = [System.Drawing.ColorTranslator]::FromHtml($ForegroundHex)
	$bg = [System.Drawing.ColorTranslator]::FromHtml($BackgroundHex)
	
	if ($fg.A -eq 255){
		return $fg
	}

	$alpha = $fg.A / 255.0
	$diff = 1.0 - $alpha
	return [System.Drawing.Color]::FromArgb(255,
		[byte]($fg.R * $alpha + $bg.R * $diff),
		[byte]($fg.G * $alpha + $bg.G * $diff),
		[byte]($fg.B * $alpha + $bg.B * $diff))
}
