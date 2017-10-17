########################################################################################################################
# NAME
#     Get-RDPSetting
#
# SYNOPSIS
#     Gets some (with filter) or all properties from a RDP file.
#
# SYNTAX
#     Edit-RDP [-Path] <string> [-Name] <string> [[-Value] <object>] [-PassThru]
#
# DETAILED DESCRIPTION
#     This retrieves the properties for a saved RDP connection from a RDP file.  The Name parameter can filter the 
#     list of properties to be returned.
#
# PARAMETERS
#     -Path <string>
#         Specifies the path to the RDP file.
#
#         Required?                    true
#         Position?                    1
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Name <string>
#         Specifies the name of the property or properties to get.  Acts as a filter.
#
#         Required?                    false
#         Position?                    2
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  true
#
# INPUT TYPE
#     
#
# RETURN TYPE
#     System.Management.Automation.PSCustomObject#RDPConnectionSetting
#
# NOTES
#
#     -------------------------- EXAMPLE 1 --------------------------
#
#     C:\PS>Get-RDPSetting -Path C:\myserver.rdp
#
#
#     This command gets all the properties of the "myserver" RDP file.
#
#
#     -------------------------- EXAMPLE 2 --------------------------
#
#     C:\PS>Get-RDPSetting -Path C:\myserver.rdp -Name "r*"
#
#
#     This command returns all the properties that start with "r" from the "myserver" RDP file.
#
#

#Function global:Get-RDPSetting {
    param(
        [string]$Path = $(throw "A path to a RDP file is required."),
        [string]$Name = "*"
    )

    $connection = Get-ChildItem -Path $path

    Get-Content -Path $Path | ForEach-Object {
        [Void] ($_ -match '^([^:]*):([^:]*):(.*)$')
        $settingname = $Matches[1]
        $type = $Matches[2]
        $value = $Matches[3]
        
        if ($settingname -like $Name) {
            switch ($type) {
                'b' { $datatype = "byte[]" }
                'i' { $datatype = "integer" }
                default { $datatype = "string" }
            }
            
            $object = "" | Select-Object Name,DataType,Value,Connection
            $object.Name = $settingname
            $object.DataType = $datatype
            $object.Value = $value
            $object.Connection = $connection.FullName
            $object.PSObject.TypeNames.Insert(0,"$($object.PSObject.TypeNames[0])#RDPConnectionSetting")
            $object
        }
    }
#}
