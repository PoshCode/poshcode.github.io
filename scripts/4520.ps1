function Get-WifiProfiles {
$tmpFolder = Join-Path $env:temp ([Guid]::NewGuid().ToString().Replace('-',''))
mkdir $tmpFolder | Out-Null

netsh wlan export profile key=clear folder=$tmpFolder | Out-Null

gci $tmpFolder\*.xml | % { 
    $data = [xml] (gc $_)
    New-Object PSObject -Property @{
        Name = $data.WLANProfile.name
        SSID = $data.WLANProfile.SSIDConfig.SSID.name
        ConnType = $data.WLANProfile.connectionType
        ConnMode = $data.WLANProfile.connectionMode
        AuthType = $data.WLANProfile.MSM.security.authEncryption.authentication
        Encryption = $data.WLANProfile.MSM.security.authEncryption.encryption
        KeyType = $data.WLANProfile.MSM.security.sharedKey.keyType
        Key = $data.WLANProfile.MSM.security.sharedKey.keyMaterial
    }
}


#Clean Up
ri -Force -Recurse -Path $tmpFolder
}
