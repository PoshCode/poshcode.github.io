param(
    $url = (Read-Host "Url? e.g http://www.maxfinance.pt/img/frame5.jpg")
)
begin {
$tmgroot = new-object -comobject FPC.Root
$tmgarray = $tmgroot.GetContainingArray() 
$myCache = $tmgArray.Cache.CacheContents
$regex = ‘([a-zA-Z]{3,})://([\w-\.]+)(/[\w- ./?%&=]*)*?’
}
process {
    if($url -match $regex) {
        $hostname = $Matches[2]
        $ip =[System.Net.Dns]::GetHostAddresses($hostname) | select -ExpandProperty IPAddressToString
        $cachedUrl = $url.Replace($Matches[0], "zttp://$ip/$hostname")
        try {
            $myCache.FetchUrl("", $cachedUrl ,0,0) #  "","zttp://83.240.174.194/www.maxfinance.pt/img/frame7.jpg",customTTL,fpcTtlIfNon
            Write-host -ForegroundColor green "Done clearing $cachedUrl"
        } 
        catch {
            if($_.Exception.Message.Contains("The system cannot find the file specified")) {
                Write-Warning "Cache Hit not found!"
            }
            else
            {
                throw
            }
        }
    }
    else
    {
        write-warning "Error parsing url"
        $Matches
    }
}
