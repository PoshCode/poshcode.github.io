########################################################################################################################
# NAME
#     Start-RDP
#
# SYNOPSIS
#     Opens a remote desktop connection to another computer.
#
# SYNTAX
#     Start-RDP [[-Server] <string>] [[-Width] <int>] [[-Height] <int>]
#     Start-RDP -Path <string> [[-Width] <int>] [[-Height] <int>]
#
# DETAILED DESCRIPTION
#     The Start-RDP cmdlet opens a new Remote Desktop connection using the Microsoft Terminal Services Client.
#     Connection settings can be specified by argument or read from a standard RDP file.
#
# PARAMETERS
#     -Server <string>
#         Specifies the name of the server to connect to.  May also include an IP address, domain, and/or port.
#
#         Required?                    false
#         Position?                    1
#         Default value                
#         Accept pipeline input?       true
#         Accept wildcard characters?  false
#
#     -Width <int>
#         Specifies the desired width of the resolution for the connection (for non-full screen connections).
#
#         Required?                    false
#         Position?                    2
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Height <int>
#         Specifies the desired height of the resolution for the connection (for non-full screen connections).
#
#         Required?                    false
#         Position?                    3
#         Default value                
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Path <string>
#         Specifies the path to an RDP file to connect with (resolution settings can be overridden using the
#         -Width and -Height parameters.
#
#         Required?                    false
#         Position?                    4
#         Default value                
#         Accept pipeline input?       true
#         Accept wildcard characters?  false
#
#     -Console <SwitchParameter>
#         Connect to a Windows Server 2003 console session.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Admin <SwitchParameter>
#         Connect to a Windows Server 2008 administrator session.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Fullscreen <SwitchParameter>
#         Open connection in full screen mode.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Public <SwitchParameter>
#         Run Remote Desktop in public mode.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
#     -Span <SwitchParameter>
#         Span the Remote Desktop connection across multiple monitors.  Each monitor must have the same height
#         and be arranged vertically.
#
#         Required?                    false
#         Position?                    named
#         Default value                false
#         Accept pipeline input?       false
#         Accept wildcard characters?  false
#
# INPUT TYPE
#     String,System.IO.FileInfo
#
# RETURN TYPE
#     
#
# NOTES
#
#     -------------------------- EXAMPLE 1 --------------------------
#
#     C:\PS>Start-RDP
#
#
#     This command opens the Terminal Services Client connection dialog to specify a connection.
#
#
#     -------------------------- EXAMPLE 2 --------------------------
#
#     C:\PS>Start-RDP -Server myserver -Width 1024 -Height 768
#
#
#     This command opens a new Remote Desktop connection to the server named "myserver" in a window with 1024x768 resolution.
#
#
#     -------------------------- EXAMPLE 3 --------------------------
#
#     C:\PS>Start-RDP -Server myserver -Fullscreen
#
#
#     This command opens a new full screen Remote Desktop connection to the server named "myserver".
#
#
#     -------------------------- EXAMPLE 4 --------------------------
#
#     C:\PS>Start-RDP -Path C:\myserver.rdp
#
#
#     This command opens a new Remote Desktop connection using the specified RDP file.
#
#

#Function global:Start-RDP {
    param(
        [string]$Server = "",
        [int]$Width = "",
        [int]$Height = "",
        [string]$Path = "",
        [switch]$Console,
        [switch]$Admin,
        [switch]$Fullscreen,
        [switch]$Public,
        [switch]$Span
    )

    begin {
        $arguments = ""
        $dimensions = ""
        $processed = $false

        if ($admin) {
            $arguments += "/admin "
        } elseif ($console) {
            $arguments += "/console "
        }
        if ($fullscreen) {
            $arguments += "/f "
        }
        if ($public) {
            $arguments += "/public "
        }
        if ($span) {
            $arguments += "/span "
        }

        if ($width -and $height) {
            $dimensions = "/w:$width /h:$height"
        }
    }

    process {
        Function script:executePath([string]$path) {
            Invoke-Expression "mstsc.exe '$path' $dimensions $arguments"
        }
        Function script:executeArguments([string]$Server) {
            Invoke-Expression "mstsc.exe /v:$server $dimensions $arguments"
        }

        if ($_) {
            if ($_ -is [string]) {
                if ($_ -imatch '\.rdp$') {
                    if (Test-Path $_) {
                        executePath $_
                        $processed = $true
                    } else {
                        throw "Path does not exist."
                    }
                } else {
                    executeArguments $_
                    $processed = $true
                }
            } elseif ($_ -is [System.IO.FileInfo]) {
                if (Test-Path $_.FullName) {
                    executePath $_.FullName
                    $processed = $true
                } else {
                    throw "Path does not exist."
                }
            } elseif ($_.Path) {
                if (Test-Path $_.Path) {
                    executePath $_.Path
                    $processed = $true
                } else {
                    throw "Path does not exist."
                }
            } elseif ($_.DnsName) {
                executeArguments $_.DnsName
                $processed = $true
            } elseif ($_.Server) {
                executeArguments $_.Server
                $processed = $true
            } elseif ($_.ServerName) {
                executeArguments $_.ServerName
                $processed = $true
            } elseif ($_.Name) {
                executeArguments $_.Name
                $processed = $true
            }
        }
    }

    end {
        if ($path) {
            if (Test-Path $path) {
                Invoke-Expression "mstsc.exe '$path' $dimensions $arguments"

            } else {
                throw "Path does not exist."
            }
        } elseif ($server) {
            Invoke-Expression "mstsc.exe /v:$server $dimensions $arguments"
        } elseif (-not $processed) {
            Invoke-Expression "mstsc.exe $dimensions $arguments"
        }
    }
#}
