param(
    $Path = (Split-Path $PSHOME -Qualifier)
)

if($lnks -eq $null) {
    $lnks = ls $Path  -Recurse -Filter "*.lnk"
}
$wsh = New-Object -ComObject WScript.Shell;
foreach($lnk in $lnks) {
    $lnko = $wsh.CreateShortcut($lnk.fullname);
    
    $rtn = New-Object psobject -Property @{
        "FilePath" = $lnk.FullName;
        "TargetPath" = $lnko.TargetPath;
    };
    
    Add-Member -InputObject $rtn -MemberType NoteProperty -Name TargetExists -Value ($lnko.TargetPath -ne "" -and (Test-Path $lnko.TargetPath))
    Add-Member -InputObject $rtn -MemberType ScriptProperty -Name IsUNC -Value {return $this.TargetPath.StartsWith("\\"); }
    
    $rtn;
}
