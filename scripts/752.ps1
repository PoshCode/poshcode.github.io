function Get-StockQuote {
	param($symbols)

	process {
		$s = new-webserviceproxy -uri http://www.webservicex.net/stockquote.asmx

		foreach ($symbol in $symbols) {
			$result = [xml]$s.GetQuote($symbol)
			$result.StockQuotes.Stock
		}
	}
}

# Example:
# Get-StockQuote VMW, EMC | select Symbol, Last
