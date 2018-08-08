#.Synopsis
#  Sets my favorite prompt functions
#.Notes
#  I put the id in my prompt because it's very, very useful.
#
#  Invoke-History, and my Expand-Alias and Get-PerformanceHistory all take command history IDs
#  You can tab-complete with "#<id>[Tab]" ... and more
#
#  For example, the following commands:
#  r 4
#  ## r is an alias for invoke-history, so this reruns your 4th command
#
#  #6[Tab]
#  ## will tab-complete whatever you typed in your 6th command (now you can edit it)
#
#  Expand-Alias -History 6,8,10 > MyScript.ps1
#  ## generates a script from those history items
#
#  GPH -id 6, 8
#  ## compares the performance of those two commands ...
#
[CmdletBinding(DefaultParameterSetName="PowerLine")]
param(
   # Controls how much history we keep in the command log between sessions
   [Int]$PersistentHistoryCount = 300,

   # If set, we use a pasteable prompt with <# #> around the prompt info
   [Parameter(ParameterSetName="Pasteable")]
   [Alias("copy","demo")]
   [Switch]$Pasteable,

   # If set, use a simple, clean prompt (otherwise use a fancy multi-line prompt)
   [Parameter(ParameterSetName="Clean")]
   [Switch]$Clean,

   # Use a fancy multi-line prompt
   [Parameter(ParameterSetName="MultiLine")]
   [Switch]$MultiLine,
   
   # Use a powerline inspired prompt which requires PowerLine fonts. My new default.
   # See https://github.com/powerline/fonts for a collection of great monospace fonts
   [Parameter(ParameterSetName="PowerLine")]
   [Switch]$PowerLine,

   # Maximum history count
   [Int]$MaximumHistoryCount = 2048,
   # The main prompt foreground color
   [ConsoleColor]$ForegroundColor = "White",
   [ConsoleColor]$AlternateColor = "DarkGray",
   # The ERROR prompt foreground color
   [ConsoleColor]$ErrorColor = $(
      if($Host.PrivateData.ErrorForegroundColor -is [ConsoleColor]) { 
         $Host.PrivateData.ErrorForegroundColor
      } else { "DarkRed" }),
   # The prompt background (should probably match your console background)
   [ConsoleColor]$Background = "DarkGreen"
)
end {
   # Regression bug?
   [ConsoleColor]$global:PromptForegroundColor = $ForegroundColor
   [ConsoleColor]$global:PromptErrorColor = $ErrorColor
   [ConsoleColor]$global:PromptBackgroundColor = $Background
   [ConsoleColor]$global:PromptAlternateColor = $AlternateColor

   $global:MaximumHistoryCount = $MaximumHistoryCount
   $global:PersistentHistoryCount = $PersistentHistoryCount

   # Some stuff goes OUTSIDE the prompt function because it doesn't need re-evaluation

   # I set the window title in my prompt function, because I want the current PATH location there,
   # rather than in my prompt where it takes up too much space.

   # But I want other stuff too. I  calculate an initial prefix for the window title
   # The title will show the PowerShell version, user, current path, and whether it's elevated or not
   # E.g.:"PoSh3 Jaykul@HuddledMasses (ADMIN) - C:\Your\Path\Here (FileSystem)"
   if(!$global:WindowTitlePrefix) {
      $global:WindowTitlePrefix = "PS$($PSVersionTable.PSVersion.Major) ${Env:UserName}@${Env:UserDomain}"

      # if you're running "elevated" we want to show that:
      $PSProcessElevated = ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
                                 new-object Security.Principal.WindowsPrincipal (
                                 [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
                              ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

      if($PSProcessElevated) {
         $global:WindowTitlePrefix += " (ADMIN)"
      }
   }

   ## Global first-run (profile or first prompt)
   if($MyInvocation.HistoryId -eq 1) {
      if(Test-Path Variable:Global:ProfileDir -EA 0) {
         Set-Variable ProfileDir (Split-Path $Profile.CurrentUserAllHosts -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue
      }
      ## Import my history
      Import-CSV $ProfileDir\.poshhistory | Add-History
   }
   $global:VcsStatusEnabled = Get-Command Write-VcsStatus -ListImported -ErrorAction SilentlyContinue

   if($Pasteable) {
      # The pasteable prompt starts with "<#PS " and ends with " #>"
      #   so that you can copy-paste with the prompt and it will still run
      function global:prompt {
         # FIRST, make a note if there was an error in the previous command
         $err = !$?
         # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
         if(Get-PSProvider AlphaFileSystem -ErrorAction Ignore) {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider AlphaFileSystem).ProviderPath
         } else {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
         }
         try {
            # Also, put the path in the title ... (don't restrict this to the FileSystem)
            $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix,(Convert-Path $pwd),$pwd.Provider.Name
         } catch {}

         # Determine what nesting level we are at (if any)
         $Nesting = "$([char]0xB7)" * $NestedPromptLevel

         # Generate PUSHD(push-location) Stack level string
         $Stack = "+" * (Get-Location -Stack).count

         # I used to use Export-CliXml, but Export-CSV is a lot faster
         $null = Get-History -Count $PersistentHistoryCount | Export-CSV $ProfileDir\.poshhistory
         # Output prompt string
         Write-host "<#PS " -NoNewLine -fore $global:PromptAlternateColor

         # If there's an error, set the prompt foreground to the error color...
         if($err) { $bg = $global:PromptErrorColor } else { $bg = $global:PromptBackgroundColor }
         # Notice: no angle brackets, makes it easy to paste my buffer to the web
         Write-Host "[${Nesting}$($myinvocation.historyID)${Stack}]" -NoNewLine -Foreground $bg
         Write-host " #>" -NoNewLine -fore $global:PromptAlternateColor
         # Hack PowerShell ISE CTP2 (requires 4 characters of output)
         if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
            return "$("$([char]8288)"*3) "
         } else {
            return " "
         }
      }
   } elseif($Clean) {
      function global:prompt {
         # FIRST, make a note if there was an error in the previous command
         $err = !$?
 
         # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
         [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
         
         try {
            # Also, put the path in the title ... (don't restrict this to the FileSystem)
            $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix, $pwd.Path,  $pwd.Provider.Name
         } catch {}
         
         # Determine what nesting level we are at (if any)
         $Nesting = "$([char]0xB7)" * $NestedPromptLevel
 
         # Generate PUSHD(push-location) Stack level string
         $Stack = "+" * (Get-Location -Stack).count
         
         # I used to use Export-CliXml, but Export-CSV is a lot faster
         $null = Get-History -Count $PersistentHistoryCount | Export-CSV $ProfileDir\.poshhistory
 
         # Output prompt string
         # If there's an error, set the prompt foreground to "Red", otherwise, "Yellow"
         if($err) { $fg = $global:PromptErrorColor } else { $fg = $global:PromptForegroundColor }
         # Notice: no angle brackets, makes it easy to paste my buffer to the web
         Write-Host "[${Nesting}$($myinvocation.historyID)${Stack}]:" -NoNewLine -Fore $fg
         # Hack PowerShell ISE CTP2 (requires 4 characters of output)
         if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
            return "$("$([char]8288)"*3) "
         } else {
            return " "
         }
      }
   } elseif($MultiLine) {
      function global:prompt {
         # FIRST, make a note if there was an error in the previous command
         $err = !$?

         # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
         if(Get-PSProvider AlphaFileSystem -ErrorAction Ignore) {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider AlphaFileSystem).ProviderPath
         } else {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
         }

         try {
            # Also, put the path in the title ... (don't restrict this to the FileSystem)
            $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix, (Convert-Path $pwd), $pwd.Provider.Name
         } catch {}

         # Determine what nesting level we are at (if any)
         $Nesting = "$([char]0xB7)" * $NestedPromptLevel

         # Generate PUSHD(push-location) Stack level string
         $Stack = "+" * (Get-Location -Stack).count

         # I used to use Export-CliXml, but Export-CSV is a lot faster
         $null = Get-History -Count $PersistentHistoryCount | Export-CSV $ProfileDir\.poshhistory

         # Output prompt string
         # If there's an error, set the prompt foreground to "Red", otherwise, "Yellow"
         if($err) { $fg = $global:PromptErrorColor } else { $fg = $global:PromptForegroundColor }
         # Notice: no angle brackets, makes it easy to paste my buffer to the web
         Write-Host '&#9556;' -NoNewLine -Foreground $global:PromptAlternateColor
         Write-Host " $(if($Nesting){"$Nesting "})#$($MyInvocation.HistoryID)${Stack} " -Background $global:PromptBackgroundColor -Foreground $fg -NoNewLine
         if($global:VcsStatusEnabled) {
            Write-VcsStatus
         }
         Write-Host ' '
         Write-Host '&#9562;&#9552;&#9552;&#9552;&#9557;' -Foreground $global:PromptAlternateColor -NoNewLine
         # Hack PowerShell ISE CTP2 (requires 4 characters of output)
         if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
            return "$("$([char]8288)"*3) "
         } else {
            return " "
         }
      }
   } else { # PowerLine
      function global:prompt {
         # FIRST, make a note if there was an error in the previous command
         $err = !$?

         $e = [char]0x1b   # ESC=27 for ANSI sequences
         # PowerLine font characters
         $SRIGHT = [char]0xe0b0 # Solid, right facing triangle
         $RIGHT = [char]0xe0b1 # right facing triangle
         $LOCK = [char]0xe0a2 # Padlock
         $BRANCH = [char]0xe0a0 # Branch symbol
         $RAQUO = [char]0x203a # Single right-pointing angle quote ›
         $GEAR = [char]0x2699 # The settings icon, I use it for debug
         $EX = [char]0x27a6 # The X that looks like a checkbox.
         $POWER = [char]0x26a1 # The Power lightning-bolt icon
         $MID = [char]0xB7 # Mid dot (I used to use this for pushd counters)

         # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
         if(Get-PSProvider AlphaFileSystem -ErrorAction Ignore) {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider AlphaFileSystem).ProviderPath
         } else {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
         }
         
         try {
            # Also, put the path in the title ... (don't restrict this to the FileSystem)
            $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix, (Convert-Path $pwd),  $pwd.Provider.Name
         } catch {}

         # Determine what nesting level we are at (if any)
         $Nesting = "$GEAR" * $NestedPromptLevel

         # Generate PUSHD(push-location) Stack level string
         $Stack = (Get-Location -Stack).count

         # I used to use Export-CliXml, but Export-CSV is a lot faster
         $null = Get-History -Count $PersistentHistoryCount | Export-CSV $ProfileDir\.poshhistory

         # Output prompt string
         # If there's an error, set the prompt foreground to "Red", otherwise, "Yellow"
         if($err) { $bg = $global:PromptErrorColor } else { $bg = $global:PromptBackgroundColor }
         # Notice: no angle brackets, makes it easy to paste my buffer to the web
         if($Stack) {
            Write-Host $RAQUO$Stack -Fore White -Back DarkGray -NoNewLine
            Write-Host $SRIGHT -Fore DarkGray -Back $bg -NoNewLine
         }
         Write-Host "${Nesting}$($myinvocation.historyID)" -Fore $global:PromptForegroundColor -Back $bg -NoNewLine

         if($global:VcsStatusEnabled) {
            Write-Host $SRIGHT -Foreground $bg -Background DarkYellow -NoNewLine
            # It's worth noting that I have my own PSGit module...
            Write-VcsStatus
         } else {
            Write-Host $SRIGHT -Foreground $bg -NoNewLine
         }


         # Write-Host "[${Nesting}$($myinvocation.historyID)${Stack}]:" -NoNewLine -Fore $fg
         # Hack PowerShell ISE CTP2 (requires 4 characters of output)
         if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
            return "$("$([char]8288)"*3) "
         } else {
            return " "
         }
      }
   } 
}

# SIG # Begin signature block
# MIIXxAYJKoZIhvcNAQcCoIIXtTCCF7ECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWsSE+gyt15h+b/PXDQZNJ3GM
# 3oOgghL3MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUmMIIEDqADAgECAhACXbrxBhFj1/jVxh2rtd9BMA0GCSqGSIb3DQEBCwUAMHIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJ
# RCBDb2RlIFNpZ25pbmcgQ0EwHhcNMTUwNTA0MDAwMDAwWhcNMTYwNTExMTIwMDAw
# WjBtMQswCQYDVQQGEwJVUzERMA8GA1UECBMITmV3IFlvcmsxFzAVBgNVBAcTDldl
# c3QgSGVucmlldHRhMRgwFgYDVQQKEw9Kb2VsIEguIEJlbm5ldHQxGDAWBgNVBAMT
# D0pvZWwgSC4gQmVubmV0dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AJfRKhfiDjMovUELYgagznWf+HFcDENk118Y/K6UkQDwKmVyVOvDyaVefjSmZZcV
# NZqqYpm9d/Iajf2dauyC3pg3oay8KfXAADLHgbmbvYDc5zGuUNsTzMUOKlp9h13c
# qsg898JwpRpI659xCQgJjZ6V83QJh+wnHvjA9ojjA4xkbwhGp4Eit6B/uGthEA11
# IHcFcXeNI3fIkbwWiAw7ZoFtSLm688NFhxwm+JH3Xwj0HxuezsmU0Yc/po31CoST
# nGPVN8wppHYZ0GfPwuNK4TwaI0FEXxwdwB+mEduxa5e4zB8DyUZByFW338XkGfc1
# qcJJ+WTyNKFN7saevhwp02cCAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrEuXsq
# CqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBQV0aryV1RTeVOG+wlr2Z2bOVFAbTAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1
# oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1n
# MS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3Vy
# ZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUH
# AgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEBBHgw
# djAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsGAQUF
# BzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNz
# dXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0B
# AQsFAAOCAQEAIi5p+6eRu6bMOSwJt9HSBkGbaPZlqKkMd4e6AyKIqCRabyjLISwd
# i32p8AT7r2oOubFy+R1LmbBMaPXORLLO9N88qxmJfwFSd+ZzfALevANdbGNp9+6A
# khe3PiR0+eL8ZM5gPJv26OvpYaRebJTfU++T1sS5dYaPAztMNsDzY3krc92O27AS
# WjTjWeILSryqRHXyj8KQbYyWpnG2gWRibjXi5ofL+BHyJQRET5pZbERvl2l9Bo4Z
# st8CM9EQDrdG2vhELNiA6jwenxNPOa6tPkgf8cH8qpGRBVr9yuTMSHS1p9Rc+ybx
# FSKiZkOw8iCR6ZQIeKkSVdwFf8V+HHPrETCCBTAwggQYoAMCAQICEAQJGBtf1btm
# dVNDtW+VUAgwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTEzMTAyMjEyMDAwMFoX
# DTI4MTAyMjEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNl
# cnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAPjTsxx/DhGvZ3cH0wsxSRnP0PtFmbE620T1f+Wo
# ndsy13Hqdp0FLreP+pJDwKX5idQ3Gde2qvCchqXYJawOeSg6funRZ9PG+yknx9N7
# I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrskacLCUvIUZ4qJRdQtoaPpiCwgla4cSocI
# 3wz14k1gGL6qxLKucDFmM3E+rHCiq85/6XzLkqHlOzEcz+ryCuRXu0q16XTmK/5s
# y350OTYNkO/ktU6kqepqCquE86xnTrXE94zRICUj6whkPlKWwfIPEvTFjg/Bougs
# UfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8np+mM6n9Gd8lk9ECAwEAAaOCAc0wggHJ
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4
# MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsME8GA1UdIARIMEYwOAYKYIZIAYb9bAAC
# BDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAoG
# CGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAfBgNVHSME
# GDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQsFAAOCAQEAPuwN
# WiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh134LYP3DPQ/Er4v97yrfIFU3sOH20ZJ1
# D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63XX0R58zYUBor3nEZOXP+QsRsHDpEV+7qv
# tVHCjSSuJMbHJyqhKSgaOnEoAjwukaPAJRHinBRHoXpoaK+bp1wgXNlxsQyPu6j4
# xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC/i9yfhzXSUWW6Fkd6fp0ZGuy62ZD2rOw
# jNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG/AeB+ova+YJJ92JuoVP6EpQYhS6Skepo
# bEQysmah5xikmmRR7zGCBDcwggQzAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAv
# BgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EC
# EAJduvEGEWPX+NXGHau130EwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCJgd9hsbmcPjBjj/+Xc
# 2JM/jyCVMA0GCSqGSIb3DQEBAQUABIIBAAcz0rqIYSbTYqb9O5BenE9HNsUZkRkA
# q8pwiTktIw5MvG3imi9hLJbK5dSL3y9Wo/pAa2GgWQ0VkWcaXRUqui+LuWmjBSzw
# Zu9/iKwwkUEtbTgmsyhS8dRljmtNweG/TK3seLQ71l/roAHN03XKez6cWmOwStLH
# 89iVKZJac+kQwmXntkdYb5ymVShzeeyp51+3hyEjh+21pOGKz2wQZS3ilCQ8NX0/
# oqV8Knc2f8HEU5+H9kMqpGlUFA15buTLqgDwnyqGVfxs8ksuxoUAGvg9UPgo37fV
# 5uW5yecY44u1nRvrilzbpKLHd2K0eoPFKTSn1EM6mpb1l8UMemF9OQOhggILMIIC
# BwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UE
# ChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUg
# U3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUr
# DgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
# DxcNMTYwNTEwMjEyNjMyWjAjBgkqhkiG9w0BCQQxFgQUzKqNDqfEqnrKGX6TKg3N
# yRzoGhgwDQYJKoZIhvcNAQEBBQAEggEAb0GgJkFs/luVAYMHz1juDaVoI3oEZRwQ
# awCZOblQxVGT/3Ksb0hkarUWCLyA1KIK6lcAoDAYrTygzJ7eyQ0kKsg57wzfcXBh
# uMbpgubuHa35maqoG8JAKgdZgDMNNn30Gq1UTHzyPKzWK3aOWI8u0i8Sc38wD/HK
# Cb9qtqXqkYgPP9fIVfKgycGhkJ096+N5AAOEaKsCetTf/u9QSFIp4CAl7+qumjTy
# ynjhTOyzv9mA4gC7uXMYBm/q6gjb06TD9TMQ3jLvWn6Lp8wPIqpUWvZZr0+hHESh
# JUBU/U2lj/3W+udH28iOTTKGDRax1g4tM6ZugB5WX/OelrS2f6Pkww==
# SIG # End signature block

