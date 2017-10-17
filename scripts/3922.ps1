<#
	.TITLE
		Haal-WisMasLeerling.ps1
	.AUTHOR
		Paul Wiegmans  (p [dot] wiegmans [at] bonhoeffer [dot] nl)
	.DATE
		2013-01-30  
	.DESCRIPTION
		Send a webquery to Schoolmaster Magister web service and request data 
		from the list WISMASLEERLING. 
		Doe een webquery naar Magister webservice en haal de lijst WISMASLEERLING op.
	.NOTES
	.LINK
		http://ict.bonhoeffer.nl
#>

Import-Module ActiveDirectory
Set-StrictMode -Version 2

$mijnpad = Split-Path -parent $MyInvocation.MyCommand.Definition
$mijnbasename = $([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition))

$logging = $true			# geef uitvoer naar logfile
$outputting = $true			# geef uitvoer naar console
$outputVreemdetekens = $true # geef uitvoer naar console indien vreemde tekens opgemerkt

$aantal = 0

$SOAPLayout = "WISMASLEERLINGEN"
$SOAPusername = "username"
$SOAPpasswd = "password"

Function Write-Log ($tekst) {
	<# stuur uitvoer naar een logfile en naar console #>
	$logtekst = ("{0:0###}: {1}" -f ($aantal, $tekst))
	if ($outputting) {	
		Write-Host $logtekst
	}
	if ($Logging) {
		#$logtekst | Out-File "$mijnpad\$mijnbasename.log" -Append 
	}
}

function Doe-Webquery ([string]$Url, [System.Text.Encoding]$encoding = [System.Text.Encoding]::UTF7) {
	# .SYNOPSIS
	#	Voert een SOAP webquery uit
	# .DESCRIPTION
	#	Voert een SOAP webquery uit.
	#	Retourneert het resultaat van de qebquery in een array met string
	# .PARAMETER Url
	#	De URL van de webquery
	# .PARAMETER ENcoding
	#	De [system.text.encoding] encoding van de webquery
	# .EXAMPLE
	#	$lines = Doe-Webquery "https://bonhoeffer.swp.nl:8800/doc?Bladibla..."
	# .NOTES
	# 	Auteur: Paul Wiegmans
	#	Datum:	30 mrt 2012
	
	$request = [System.Net.WebRequest]::Create($Url)
	try {
		$response = $request.GetResponse()
	}
	catch [Net.WebException] {
    	Write-Host $_.Exception.ToString()
		exit
	}

	$requestStream = $response.GetResponseStream()
	# We must read the Magister webquery in UTF7 to preserve the accents!
	$readStream = new-object System.IO.StreamReader( $requestStream, $Encoding )

	$result = $readStream.ReadToEnd() -split "`n"  # convert to array of strings

	$readStream.Close()
	$response.Close()
	return $result
}

Function Ophalen-Magister () {
	<# Haal leerlinglijst op van Magister via SOAP #>
	# kale URL is https://bonhoeffer.swp.nl:8800/doc?Function=GetData&Library=Data&SessionToken=adfeeder%3Belo.33&Layout=Basistest&Parameters=leerjaar%3D1213&Type=CSV
	$SOAPUrl = "https://bonhoeffer.swp.nl:8800/doc?Function=GetData"`
		+"&Library=Data&SessionToken=$SOAPusername%3B$SOAPpasswd&Layout=$SOAPlayout"`
		+"&Parameters=leerjaar%3D1213&Type=CSV"
	$iso88591 = [System.Text.Encoding]::GetEncoding("ISO-8859-1")
	$UTF7 = [System.Text.Encoding]::UTF7
	$data = Doe-Webquery $SOAPUrl	$UTF7
    
    if ($data -is [string]) {
        if (($data.contains("Fout")) -or ($data.contains('ResultMessage'))) {
            # haal opnieuw met andere encoding zodat foutmelding zichtbaar wordt.
			$data = Doe-Webquery $SOAPUrl $iso88591 
			Write-Log $SOAPUrl
            Throw "Webquery retourneert fout (1): $data"
        }
    }                 
        
	if ($data[0] -is [string]) {
        if ($data[0].contains("Fout_nummer") ) {
            Write-Log $SOAPUrl
    		Throw "Webquery retourneert fout (2): $data"
        }            
	}
	return  ($data | Out-String) -replace "`r`r","`r"
}

function VerwijderVreemdeTekens($n) {
	<# vervangt alle niet-alfabettekens door gelijkende alfabettekens #>
	$VervangTabel = @(`
	"ñn","êe","ëe","èe","ée","áa","äa","öo","óo","ïi","úu","ûu","çc","ŠS","šs","šs","ýy","-","'")
	# 'Moûrik' Ibánez' 'Šromofský' 
	foreach ($letter in $VervangTabel) {
		$n = $n -replace $letter[0], $letter[1]
	}
	return $n
}

Function VertaalTekens ($n) {
	<# VertaalTekens vervangt alle vreemde tekens uit webquery naar de juiste tekens, 
		voor speciaal geval Šromofský . Dit doet een eerst conversie van vreemde tekens 
		uit de data in ANSI-codering naar herkenbare vreemde tekens, zodat deze later 
		vervangen, door romeinse tekens. Leer de code door uitvoer "onvertaald.txt" 
		te zien in hexeditor XVI32.
	#>
	return $n -replace [char]138, "Š" -replace [char]0x9a, "š"
}


# --------------------------------------------------------------------
# ---                           M A I N                            ---
# --------------------------------------------------------------------
	
Write-Host " "
Write-Log "Start --- "

	# resultaat bestaat uit regels tekst gescheiden door 0D, 0D, 0A 
	# dit is gelijk aan `r `r `n 

$onvertaald = Ophalen-magister
$onvertaald | Out-File "$mijnpad\onvertaald.txt"

$csv = vertaaltekens $onvertaald | ConvertFrom-Csv -Delimiter ";"  # maak array met records
$csv | Export-CSV -Path "$mijnpad\wismasleerling.csv" -Encoding UTF8 -NoTypeInformation
Write-Log ("Gegevens in webquery: {0}" -f $csv.count)
if (($csv.Count -lt 1490) -or ($csv.Count -ge 1570)) {
	throw "Webquery geeft onwaarschijnlijk aantal resultaten. Uitvoering stopt."
}
$csv | Out-GridView; exit

