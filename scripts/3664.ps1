$page = Invoke-WebRequest "http://www.apk.se"
$html = $page.parsedHTML
$products = $html.body.getElementsByTagName("TR")
$headers = @()
foreach($product in $products)
{
	$colID = 0;
	$hRow = $false
	$returnObject = New-Object Object
	foreach($child in $product.children)
	{	
		if ($child.tagName -eq "TH")
		{
			$headers += @($child.outerText)
			$hRow = $true
		}

		if ($child.tagName -eq "TD")
		{
			$returnObject | Add-Member NoteProperty $headers[$colID] $child.outerText
		}
		$colID++

	}
	if (-not $hRow) { $returnObject }
}
