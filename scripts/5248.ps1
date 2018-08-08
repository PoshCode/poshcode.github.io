function Get-IPFromAD {
	
    import-module ActiveDirectory
    $PATH = "C:\Reports\$(get-date -UFormat "%Y%m%d%A-%H%M")-AD_DNS_Report.csv"
    get-adcomputer -filter * | % { 
        
        $computer = $_.Name
        $record = @{"Computer" = $computer}

        try {
            $ip = [System.Net.Dns]::GetHostEntry($computer).AddressList.IPAddressToString
            $record.Add("IPAddress", $ip)        
        }

        catch {
            $record.Add("IPAddress", "NULL")
        }
            New-Object PSObject -property $record
       
       } | export-csv -path $PATH

}

