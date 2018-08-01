#requires -version 2
Function Get-GoogleSpreadSheets {
    param(
        $userName = $(throw 'Please specify a user name'),
        $password = $(throw 'Please specify a password')
    )

    Add-Type -Path "C:\Program Files\Google\Google Data API SDK\Redist\Google.GData.Client.dll"
    Add-Type -Path "C:\Program Files\Google\Google Data API SDK\Redist\Google.GData.Extensions.dll"
    Add-Type -Path "C:\Program Files\Google\Google Data API SDK\Redist\Google.GData.Spreadsheets.dll"

    $service = New-Object Google.GData.Spreadsheets.SpreadsheetsService("TestGoogleDocs")
    $service.setUserCredentials($userName, $password)
    $query = New-Object Google.GData.Spreadsheets.SpreadsheetQuery
    $feed = $service.Query($query)

    $feed.Entries |
        foreach {
            $_.Title.Text
         
            $_.Links | 
                ? {$_.rel -eq "http://schemas.google.com/spreadsheets/2006#worksheetsfeed"} |
                % {
                    $query = New-Object Google.GData.Spreadsheets.WorksheetQuery($_.Href)
                    $feed = $service.Query($query)
                    $feed.Entries |
                    % {
                        $_.Title.Text
                        $_.Links | 
                        ? { $_.rel -eq "http://schemas.google.com/spreadsheets/2006#listfeed"} |
                        % {                        
                            $listQuery = New-Object Google.GData.Spreadsheets.ListQuery($_.Href)
                            $feed = $service.Query($listQuery)
                            "Worksheet has $($feed.Entries.Count) rows:"
                            $feed.Entries |
                            % {
                                $_.Elements |
                                % {
                                    Write-Host -NoNewline "$($_.value)`t"
                                }
                                Write-Host
                            }
                        }
                    } 
                }
        }
}        


