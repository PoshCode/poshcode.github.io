$maintenanceGroup = {
    New-SCOMManagementGroupConnection -ComputerName SERVERNAME
    Get-SCOMGroup -DisplayName "Maintenance Group Citrix" | Get-SCOMClassInstance | sort dislayname | select -ExpandProperty Displayname
    }

return $maintenanceGroup
