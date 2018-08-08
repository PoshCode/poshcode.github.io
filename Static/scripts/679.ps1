########################################################################################################################
# NAME
#     Set-RDPSetting
#
# SYNOPSIS
#     Adds or updates a named property to an existing RDP file.
#
# SYNTAX
#     Edit-RDP [-Path] <string> [-Name] <string> [[-Value] <object>] [-PassThru]
#
# DETAILED DESCRIPTION
#     The Edit-RDP cmdlet can be used to add or update properties in an existing RDP file.  This cmdlet can properly
#     translate boolean values or strings containing boolean or integer values for properties that are integers.
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
#         Specifies the name of the property to set.
#
#         Required?                    false
#         Position?                    2
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Value <Object>
#         Specifies the value to set the property to.
#
#         Required?                    false
#         Position?                    3
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -PassThru <SwitchParameter>
#         Passes thru an object that represents the RDP file to the pipeline.  By default, this cmdlet does
#         not pass any objects through the pipeline.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
# INPUT TYPE
#     
#
# RETURN TYPE
#     System.IO.FileInfo
#
# NOTES
#
#     -------------------------- EXAMPLE 1 --------------------------
#
#     C:\PS>Set-RDPSetting -Path C:\myserver.rdp -Name "full address" -Value "myotherserver"
#
#
#     This command changes the name of the server to connect to.
#
#
#     -------------------------- EXAMPLE 2 --------------------------
#
#     C:\PS>Set-RDPSetting -Path C:\myserver.rdp -Name "redirectclipboard" -Value $true
#
#
#     This command turns on redirection of the clipboard from the remote computer.
#
#
#     -------------------------- EXAMPLE 3 --------------------------
#
#     C:\PS>Get-RDPSetting -Path C:\template.rdp | Set-RDPSetting -Path C:\myserver.rdp | Start-RDP
#
#
#     This command updates all the settings in "myserver.rdp" with the corresponding values from "template.rdp",
#     and then opens a connection with the resulting file.
#
#

#Function global:Set-RDPSetting {
    param(
        [string]$Path = $(throw "A path to a RDP file is required."),
        [string]$Name = "",
        [Object]$Value = "",
        [switch]$Passthru
    )
    
    begin {
        if (Test-Path $path) {
               $content = Get-Content -Path $path
        } else {
            throw "Path does not exist."
        }
        
        $datatypes = @{
            'allow desktop composition' = 'i';
            'allow font smoothing' = 'i';
            'alternate shell' = 's';
            'audiomode' = 'i';
            'authentication level' = 'i';
            'auto connect' = 'i';
            'autoreconnection enabled' = 'i';
            'bitmapcachepersistenable' = 'i';
            'compression' = 'i';
            'connect to console' = 'i';
            'desktopheight' = 'i';
            'desktopwidth' = 'i';
            'disable cursor setting' = 'i';
            'disable full window drag' = 'i';
            'disable menu anims' = 'i';
            'disable themes' = 'i';
            'disable wallpaper' = 'i';
            'displayconnectionbar' = 'i';
            'domain' = 's';
            'drivestoredirect' = 's';
            'full address' = 's';
            'gatewaycredentialssource' = 'i';
            'gatewayhostname' = 's';
            'gatewayprofileusagemethod' = 'i';
            'gatewayusagemethod' = 'i';
            'keyboardhook' = 'i';
            'maximizeshell' = 'i';
            'negotiate security layer' = 'i';
            'password 51' = 'b';
            'prompt for credentials' = 'i';
            'promptcredentialonce' = 'i';
            'port' = 'i';
            'redirectclipboard' = 'i';
            'redirectcomports' = 'i';
            'redirectdrives' = 'i';
            'redirectposdevices' = 'i';
            'redirectprinters' = 'i';
            'redirectsmartcards' = 'i';
            'remoteapplicationmode' = 'i';
            'screen mode id' = 'i';
            'server port' = 'i';
            'session bpp' = 'i';
            'shell working directory' = 's';
            'smart sizing' = 'i';
            'username' = 's';
            'winposstr' = 's'
        }
    }
    
    process {
        if ($_.Name) {
            $tempname = $_.Name
            $tempvalue = $_.Value
            # Convert value
            if ($datatypes[$tempname] -eq 'i') {
                if (($tempvalue -eq $true) -or ($tempvalue -imatch '^true$')) {
                    $tempvalue = 1
                } elseif (($tempvalue -eq $false) -or ($tempvalue -imatch '^false$') -or ($tempvalue -eq '')) {
                    $tempvalue = 0
                } elseif ($tempvalue -match '^[0-9]+$') {
                    $tempvalue = [int]$tempvalue
                }
            } else {
                $tempvalue = [string]$tempvalue
            }
            
            # Set or update property
            $found = $false
            $content = $content | ForEach-Object {
                if ($_ -match "^$tempname") {
                    "${tempname}:$($datatypes[$tempname]):$tempvalue"
                    $found = $true
                } else {$_}
            }
            if (!$found) {
                $content += @("${tempname}:$($datatypes[$tempname]):$tempvalue")
            }
        }
    }
    
    end {
        if ($name) {
            # Convert value
            if ($datatypes[$name] -eq 'i') {
                if (($value -eq $true) -or ($value -imatch '^true$')) {
                    [int]$value = 1
                } elseif (($value -eq $false) -or ($value -imatch '^false$') -or ($value -eq '')) {
                    [int]$value = 0
                } elseif ($value -match '^[0-9]+$') {
                    [int]$value = $value
                }
            } else {
                [string]$value = $value
            }
            
            # Set or update property
            $found = $false
            $content = $content | ForEach-Object {
                if ($_ -match "^$name") {
                    "${name}:$($datatypes[$name]):$value"
                    $found = $true
                } else {$_}
            }
            if (!$found) {
                $content += @("${name}:$($datatypes[$name]):$value")
            }
        }
        
        $content | Set-Content -Path $path
        if ($passthru) {
            Get-ChildItem -Path $path
        }
    }
#}
