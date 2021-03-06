function Get-IMDBMatch
{
    <#
    .Synopsis
       Retrieves search results from IMDB
    .DESCRIPTION
       This cmdlet posts a search to IMDB and returns the results.
    .EXAMPLE
       Get-IMDBMatch -Title 'American Dad!'
    .EXAMPLE
       Get-IMDBMatch -Title 'American Dad!' | Where-Object { $_.Type -eq 'TV Series' }
    .PARAMETER Title
       Specify the name of the tv show/movie you want to search for.

    #>

    [cmdletbinding()]
    param([Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
          [string[]] $Title)

    BEGIN { }

    PROCESS {
        foreach ($MediaTitle in $Title) {
            $IMDBSearch = Invoke-WebRequest -Uri "http://www.imdb.com/find?q=$($MediaTitle -replace " ","+")&s=all" -UseBasicParsing

            $FoundMatches = $IMDBSearch.Content -split "<tr class=`"findresult " | select -Skip 1 | % { (($_ -split "<TD class=`"result_text`">")[1] -split "</TD>")[0] } | Select-String -Pattern "fn_al_tt_"

            foreach ($Match in $FoundMatches) {

                $ID = (($Match -split "/title/")[1] -split "/")[0]
                $MatchTitle = (($Match -split ">")[1] -split "</a")[0]
                $Released = (($Match -split "</a> \(")[1] -split "\)")[0]
                $Type = (($Match -split "\) \(")[1] -split "\) ")[0]

                if ($Type -eq "") {
                    $Type = "Movie"
                }

                if ($ID -eq "") {
                    Continue
                }

                $returnObject = New-Object System.Object
                $returnObject | Add-Member -Type NoteProperty -Name ID -Value $ID
                $returnObject | Add-Member -Type NoteProperty -Name Title -Value $MatchTitle
                $returnObject | Add-Member -Type NoteProperty -Name Released -Value $Released
                $returnObject | Add-Member -Type NoteProperty -Name Type -Value $Type

                Write-Output $returnObject

                Remove-Variable ID, MatchTitle, Released, Type
    
            }

            Remove-Variable FoundMatches, IMDBSearch
        }
    }

    END { }
}


function Get-IMDBItem
{
    <#
    .Synopsis
       Retrieves information about a movie/tv show etc. from IMDB.
    .DESCRIPTION
       This cmdlet fetches information about the movie/tv show matching the specified ID from IMDB.
       The ID is often seen at the end of the URL at IMDB.
    .EXAMPLE
        Get-IMDBItem -ID tt0848228
    .EXAMPLE
       Get-IMDBMatch -Title 'American Dad!' | Get-IMDBItem

       This will fetch information about the item(s) piped from the Get-IMDBMatch cmdlet.
    .PARAMETER ID
       Specify the ID of the tv show/movie you want get. The ID has the format of tt0123456
    #>

    [cmdletbinding()]
    param([Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
          [string[]] $ID)

    BEGIN { }

    PROCESS {
        foreach ($ImdbID in $ID) {

            $IMDBItem = Invoke-WebRequest -Uri "http://www.imdb.com/title/$ImdbID" -UseBasicParsing

            $ItemInfo = (($IMDBItem.Content -split "<td id=`"overview-top`">")[1] -split "</td>")[0]

            $ItemTitle = (($ItemInfo -split "<span class=`"itemprop`" itemprop=`"name`">")[1] -split "</span>")[0]
            $Type = (((($ItemInfo -split "<div class=`"infobar`">")[1] -split "<")[0]).Trim() -split "`n")[0]
            
            if ($Type -eq 'TV Episode') {
                $Released = $null
            }
            else {
                $Released = (($ItemInfo -split "<span class=`"nobr`">")[1] -split "</span>")[0] -replace "^\(" -replace "\)$"
            }

            $Description = (((($ItemInfo -split "<p itemprop=`"description`">")[1] -split "</p>")[0] -split "<a href=`"")[0]).trim()
            $Rating = ((($ItemInfo -split "<div class=`"titlePageSprite star-box-giga-star`">")[1] -split "</div>")[0]).trim()
            try {
                $RuntimeMinutes = (((($ItemInfo -split "<time itemprop=`"duration`" datetime=")[1] -split ">")[1]).trim() -split " ")[0]
            }
            catch {
                $RuntimeMinutes = $null
            }

            if ($Type -eq "") {
                $Type = "Movie"
            }

            if ($Released -like "<a href=`"*") {
                $Released = (($Released -split "/year/")[1] -split "/")[0]
            }

            if ($Description -like '*Add a plot*') {
                $Description = $null
            }

            $returnObject = New-Object System.Object
            $returnObject | Add-Member -Type NoteProperty -Name ID -Value $ImdbID
            $returnObject | Add-Member -Type NoteProperty -Name Type -Value $Type
            $returnObject | Add-Member -Type NoteProperty -Name Title -Value $ItemTitle
            $returnObject | Add-Member -Type NoteProperty -Name Description -Value $Description
            $returnObject | Add-Member -Type NoteProperty -Name Released -Value $Released
            $returnObject | Add-Member -Type NoteProperty -Name RuntimeMinutes -Value $RuntimeMinutes
            $returnObject | Add-Member -Type NoteProperty -Name Rating -Value $Rating

            Write-Output $returnObject

            Remove-Variable IMDBItem, ItemInfo, ItemTitle, Description, Released, Type, Rating, RuntimeMinutes -ErrorAction SilentlyContinue
        }
    }

    END { }
}
