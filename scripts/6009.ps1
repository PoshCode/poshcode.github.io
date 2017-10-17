$30DaysFiles = Get-ChildItem $dataLocation | Where-object {
    ([datetime]::ParseExact($_.Name.Substring(4,6),"yyMMdd",$null) -gt (Get-Date).AddDays(-31)) -and `
    ([datetime]::ParseExact($_.Name.Substring(4,6),"yyMMdd",$null) -lt (Get-Date)) -and`
    
    # We also will check here to see if our $db already contains entries for the date. If so, not going to bother with it

    # In the next line, the $_.Date is referring, for example, to $db[0].Date whereas the $_.Name might refer to $30DaysFiles[0].Name
    (($db | Where-Object $_.Date -eq [datetime]::ParseExact($_.Name.Substring(4,6),"yyMMdd",$null).ToString("MM/dd/yyyy")) -eq $null)
    }
