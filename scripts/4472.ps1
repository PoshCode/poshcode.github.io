# Include trailing backslash
$dstFolder = "D:\SomeExportDirectory\"
$evtsession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession($env:computername)
[string[]] $ProviderList = $evtsession.GetProviderNames() | Select-String asp 
for($i=0;$i -lt $ProviderList.Length;$i++){ 
    $evtQuery = "*[System/Provider/@Name=`""+$ProviderList[$i]+"`"]"
    $dst = $dstFolder+$env:computername+"_"+($ProviderList[$i]).replace(" ","_")+".evtx"
    if(Test-Path -Path $dst){Remove-Item -Path $dst -Force}
    $evtsession.ExportLog('Application','LogName',$evtQuery,$dst)
}
