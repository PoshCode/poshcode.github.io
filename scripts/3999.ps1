# Be sure to include the tailing backslash "\"
$DstFolder = "D:\somefolder\"

$EvtSession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession($env:computername)

[string[]] $ProviderList = $EvtSession.GetProviderNames() | Select-String asp

for($i=0;$i -lt $ProviderList.Length;$i++){
    $EvtQuery = "*[System/Provider/@Name=`""+$ProviderList[$i]+"`"]"
    $Dst = $DstFolder+$env:computername+"_"+($ProviderList[$i]).replace(" ","_")+".evtx"
    if(Test-Path -Path $Dst){Remove-Item -Path $Dst -Force}
    $EvtSession.ExportLogAndMessages('Application','LogName',$EvtQuery,$Dst)
}
