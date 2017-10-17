function Set-PSObjectDefaultProperties {
    param(
          [PSObject]$Object,
          [string[]]$DefaultProperties
         )
    
    $name = $Object.PSObject.TypeNames[0]     
    
    $xml = "<?xml version='1.0' encoding='utf-8' ?><Types><Type>"
    
    $xml += "<Name>$($name)</Name>"
    
    $xml += "<Members><MemberSet><Name>PSStandardMembers</Name><Members>"
    
    $xml += "<PropertySet><Name>DefaultDisplayPropertySet</Name><ReferencedProperties>"
    
    foreach( $default in $DefaultProperties ) {
        $xml += "<Name>$($default)</Name>"
    }
    
    $xml += "</ReferencedProperties></PropertySet></Members></MemberSet></Members>"

	$xml += "</Type></Types>"
    
    $file = "$($env:Temp)\$name.ps1xml"
    
    Out-File -FilePath $file -Encoding "UTF8" -InputObject $xml -Force
    
    $typeLoaded = $host.Runspace.RunspaceConfiguration.Types | where { $_.FileName -eq  $file }
    
    if( $typeLoaded -ne $null ) {
        Write-Host "Type Loaded"
        Update-TypeData
    }
    else {
        Update-TypeData $file
    }
}

