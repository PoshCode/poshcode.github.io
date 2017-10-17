
	##### Get current Content-ID in Preamble.xml
	cat ./Preamble.xml | findstr Content-ID: > ./Content-ID
	$ID = Get-Content ./Content-ID
	$ID = $ID.substring(13,15)

	##### Replace Content-ID in Preamble.xml
	( Get-Content ./Preamble.xml ) -replace "$ID" , "$STAMP" | 
	Set-Content ./Preamble.xml

