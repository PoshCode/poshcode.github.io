#Get-GPOUNCPaths.ps1
#This script retrieves the UNC paths from all group policies in the domain

$gpos = get-gpo -all
foreach ($gpo in $gpos) {

    [string]$xmlReport = $gpo | Get-GPOReport -reporttype xml

    $searchResults = $xmlReport -split '["\n\r"|"\r\n"|\n|\r]' | where {$_} | Select-String -pattern '\\\\.*\\.*' -context 3

    foreach ($searchResult in $searchResults) {
        
        $returnParams = [ordered]@{}
        $returnParams.GUID = $gpo.id
        $returnParams.Name = $gpo.DisplayName
        $returnParams.Line = $searchResult.LineNumber
        $returnParams.Match = $searchResult.Line
        $returnParams.Context = $searchResult.ToString()

        # Output a search result 
        new-object PSObject -Property $returnParams

    }
}
