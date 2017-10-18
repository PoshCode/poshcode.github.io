Param([string]$server)
Begin{
    function CheckRegKey{
        param([string]$srv)
        $key = "Software\Microsoft\Windows\CurrentVersion\Uninstall"
        $type = [Microsoft.Win32.RegistryHive]::LocalMachine
        $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $Srv)
        $regKey = $regKey.OpenSubKey($key)
        foreach($sub in $regKey.GetSubKeyNames())
        {
            if($regKey.OpenSubKey($sub).GetValue("DisplayName"))
            {
                $regKey.OpenSubKey($sub).GetValue("DisplayName")                
            }
            else
            {
                $sub
            }
        }
    }
    $process = @()
}
Process{
    if($_)
    {
        $process += $_
    }
}
End{
    if($Server)
    {
        $process += $Server
    }
    foreach($s in $process)
    {
        CheckRegKey $s
    }
}
