Param($file,$cmd,[switch]$whatif,[switch]$verbose)
Begin{
    function Ping-Server {
        Param([string]$srv)
        $pingresult = Get-WmiObject win32_pingstatus -f "address='$srv'"
        if($pingresult.statuscode -eq 0) {$true} else {$false}
    }
    $servers = @()
}
Process{
    if($_)
    {
        if($_.ServerName){$servers += $_.ServerName}
        else{$servers += $_}
    }
}
End{
    if($file){Get-Content $file | %{$servers += $_}}
    foreach($server in $servers)
    {
        if(ping-server $server)
        {
            if($verbose){Write-Host "+ Processing Server $Server"}
            $mycmd = $cmd -replace "\%S\%",$Server
            if($whatif){Write-Host "  - WOULD RUN $mycmd"}
            else{if($verbose){Write-Host "  - Running $mycmd"};invoke-Expression $mycmd}
        }
        else
        {
            Write-Host "+ $Server FAILED PING" -foregroundcolor RED
        }
    } 
}
