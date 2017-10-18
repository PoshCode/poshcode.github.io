function Get-UcsServerVlan {
    Get-UcsServiceProfile | Foreach-Object {
        $sp = $_
        $sp | Get-UcsVnic | Foreach-Object {
            $vn = $_
            $vn | Get-UcsVnicInterface | Foreach-Object {
                $output = New-Object psobject –property @{
                    Server = $sp.Name
                    Vnic = $vn.name
                    Vlan = $_.name
                }
                Write-Output $output
            }
        }
    }
}
