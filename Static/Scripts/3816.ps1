function Repair-ScriptQuotes {
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$path
    )
    if ( !( Test-Path $path ) ) {
        Write-Warning "'$path' does not exist."
        Continue
    }
        

    (( Get-Content $path) |  
        ForEach-Object {
            # replace double quotes
            [Net.WebUtility]::HtmlDecode($_)
        } | 
            ForEach-Object {
                # replace double quotes
                $_ -replace "(\u201c|\u201d|\u201e)",[char]34
            } | 
                ForEach-Object {
                    # replace single quotes
                    $_ -replace "(\u2018|\u2019|\u201a)",[char]39
                } | 
                    ForEach-Object {
                        # replace dash
                        $_ -replace "(\u2013)",[char]45
                    } | 
                        ForEach-Object {
                            # replace tab with four spaces
                            $_ -replace "`t",(" " * 4)
                        }) | 
                            Set-Content $path
    Write-Host "Done"
}

