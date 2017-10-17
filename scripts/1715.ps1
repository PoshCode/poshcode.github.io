﻿#requires -version 2.0
PARAM ( 
   [Parameter(Position=1, Mandatory=$true)]
   [ValidateSet("wmv","wmvhigh","ppt", "mp4")] 
   [String]$MediaType,
   [string]$Destination = $PWD
)
if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and -not ( # Vista and ...
   new-object Security.Principal.WindowsPrincipal (
      [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
   ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {
   
Write-Warning @"
On VISTA and above, BITS limits the number of jobs in the queue to 300 jobs and the number of jobs that a non-administrator user can create to 60 jobs.

You MUST run this script from an elevated host if you're on Vista, Windows 7, or Server 2008
"@
}
   
Import-Module BitsTransfer
Push-Location $Destination
$Extension = $(switch -wildcard($MediaType){"wmv*"{"wmv"} "mp4"{"mp4"} "ppt"{"pptx"}})
$BaseUrl = "http://ecn.channel9.msdn.com/o9/mix/10/{0}/{2}.{1}"

"CL01", "CL02", "CL03", "CL06", "CL07", "CL08", "CL09", "CL10", "CL13", "CL14", 
"CL15", "CL16", "CL17", "CL18", "CL19", "CL20", "CL21", "CL22", "CL23", "CL24", 
"CL25", "CL26", "CL27", "CL28", "CL29", "CL30", "CL50", "CL51", "CL52", "CL53", 
"CL54", "CL55", "CL56", "CL58", "CL59", "CL60", "DS01", "DS02", "DS03", "DS04", 
"DS05", "DS06", "DS07", "DS08", "DS09", "DS10", "DS11", "DS12", "DS13", "DS14", 
"DS15", "DS16", "EX01", "EX02", "EX03", "EX04", "EX06", "EX07", "EX10", "EX11", 
"EX12", "EX13", "EX14", "EX15", "EX16", "EX17", "EX18", "EX19", "EX20", "EX21", 
"EX22", "EX23", "EX25", "EX26", "EX27", "EX28", "EX29", "EX30", "EX31", "EX32", 
"EX33", "EX34", "EX35", "EX36", "EX37", "EX38", "EX39", "EX50", "EX51", "EX52", 
"EX53", "EX55", "EX56", "FTL01", "FTL02", "FTL03", "FTL50", "FTL51", "KEY01", 
"KEY02", "PR01", "PR02", "SVC01", "SVC02", "SVC03", "SVC04", "SVC05", "SVC06", 
"SVC07", "SVC08", "SVC09", "SVC10", "SVC12", "SVC50" | 
ForEach { Start-BitsTransfer -Source $($BaseUrl -f  $MediaType, $Extension, $_) -Async }
Pop-Location

Write-Host "You may now use Get-BitsTransfer to check on the status of the downloads. By default, failed transfers will be retried every 10 minutes for two weeks."
# SIG # Begin signature block
# MIIQpAYJKoZIhvcNAQcCoIIQlTCCEJECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmuwkLIvcY4HgxR1/UfjBbLhG
# vJ+ggg3ZMIIGyzCCBbOgAwIBAgICAIMwDQYJKoZIhvcNAQEFBQAwgYwxCzAJBgNV
# BAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUg
# RGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBD
# bGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRlIE9iamVjdCBDQTAeFw0wOTEyMjIw
# NjAwMTlaFw0xMTEyMjMxMTE2NTdaMIHIMSAwHgYDVQQNExcxMTc2NjEtcTdtZGI4
# Y28zaGhBbXAxMjELMAkGA1UEBhMCVVMxEjAQBgNVBAgTCVdpc2NvbnNpbjESMBAG
# A1UEBxMJR3JlZW5kYWxlMS0wKwYDVQQLEyRTdGFydENvbSBWZXJpZmllZCBDZXJ0
# aWZpY2F0ZSBNZW1iZXIxGDAWBgNVBAMTD1N0ZXZlbiBNdXJhd3NraTEmMCQGCSqG
# SIb3DQEJARYXc3RldmVAdXNlcG93ZXJzaGVsbC5jb20wggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQC94TIYIjVOhj2zKhUQngQ5nxqPCCH6/nsKe49FNqgE
# SPG2PRX9WBNdYIg1QXhpkw16bw+1PItHJi6vjZ7OiYyrS1Sui6iUnQ3Nt40I1H7N
# Hn4i5yn7AcFgUUCBpQgUXEc+10pZUnJ7mY1BqJJGXrDve8I2NxkDPiPwNnm6xqwO
# XkeaWSYpxKv/QXI6J+wnSSvrcMZegMxZ8TbMT7ihNCt8Y+UVlKF7g4jcRjnGzn5h
# F5qJodmgIIuQGkuKspTzqDrIMelJHqZTyvHWBjtA09zkDpMpDlhMP6A4Lu2vpIrc
# 8Ztb9FAFD/+oTLo1cz80QjY2I7rM3oxAWwsdGrCkIn09AgMBAAGjggL3MIIC8zAJ
# BgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDA6BgNVHSUBAf8EMDAuBggrBgEFBQcD
# AwYKKwYBBAGCNwIBFQYKKwYBBAGCNwIBFgYKKwYBBAGCNwoDDTAdBgNVHQ4EFgQU
# nU30uCjZk+GBJq9f25DWwbMRxhQwHwYDVR0jBBgwFoAU0E4PQJlsuEsZbzsouODj
# iAc0qrcwggFCBgNVHSAEggE5MIIBNTCCATEGCysGAQQBgbU3AQIBMIIBIDAuBggr
# BgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0Bggr
# BgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBk
# ZjCBtwYIKwYBBQUHAgIwgaowFBYNU3RhcnRDb20gTHRkLjADAgEBGoGRTGltaXRl
# ZCBMaWFiaWxpdHksIHNlZSBzZWN0aW9uICpMZWdhbCBMaW1pdGF0aW9ucyogb2Yg
# dGhlIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5IFBvbGljeSBhdmFp
# bGFibGUgYXQgaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjBjBgNV
# HR8EXDBaMCugKaAnhiVodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9jcnRjMi1jcmwu
# Y3JsMCugKaAnhiVodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnRjMi1jcmwuY3Js
# MIGJBggrBgEFBQcBAQR9MHswNwYIKwYBBQUHMAGGK2h0dHA6Ly9vY3NwLnN0YXJ0
# c3NsLmNvbS9zdWIvY2xhc3MyL2NvZGUvY2EwQAYIKwYBBQUHMAKGNGh0dHA6Ly93
# d3cuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczIuY29kZS5jYS5jcnQwIwYD
# VR0SBBwwGoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUA
# A4IBAQDAKxouOZbRGXHT2avNItDoYlnhoLXypJnLUiRX9LXoOSh5Tlj6EQPJuXyG
# pqVDzPfN3YdqmqTSSVay7r7ndOa+VvyPppIc4xE7nMuSPT8HUej96sDJI0QBbQM2
# +OoEVl/ZXcsPbaIGKVKkPFS3nTJ54UNxPKfHUK71IimVyhMQY/KaucD0BuU9Guqi
# 8rh2eYqm2BKkD8RHJxSbTCoMY1g83B/pvaGs2bI7OCwL+sfICFQhoRzY7RLE2Rvy
# maIr9CzN7EBTNYWSr56j/0vuvNFCn0htw2rspyN8ZS+pa3lc/MiWoLVJ09HwJ1pK
# C1soqH5vqdPHHDkw1E5qY8uraRCRMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0B
# AQUFADB9MQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkG
# A1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UE
# AxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMDcxMDI0MjIw
# MTQ1WhcNMTIxMDI0MjIwMTQ1WjCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
# YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
# IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRl
# cm1lZGlhdGUgT2JqZWN0IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEAyiOLIjUemqAbPJ1J0D8MlzgWKbr4fYlbRVjvhHDtfhFN6RQxq0PjTQxRgWzw
# FQNKJCdU5ftKoM5N4YSjId6ZNavcSa6/McVnhDAQm+8H3HWoD030NVOxbjgD/Ih3
# HaV3/z9159nnvyxQEckRZfpJB2Kfk6aHqW3JnSvRe+XVZSufDVCe/vtxGSEwKCaN
# rsLc9pboUoYIC3oyzWoUTZ65+c0H4paR8c8eK/mC914mBo6N0dQ512/bkSdaeY9Y
# aQpGtW/h/W/FkbQRT3sCpttLVlIjnkuY4r9+zvqhToPjxcfDYEf+XD8VGkAqle8A
# a8hQ+M1qGdQjAye8OzbVuUOw7wIDAQABo4ICfzCCAnswDAYDVR0TBAUwAwEB/zAL
# BgNVHQ8EBAMCAQYwHQYDVR0OBBYEFNBOD0CZbLhLGW87KLjg44gHNKq3MIGoBgNV
# HSMEgaAwgZ2AFE4L7xqkQFulF2mHMMo0aEPQQa7yoYGBpH8wfTELMAkGA1UEBhMC
# SUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdp
# dGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAnBgNVBAMTIFN0YXJ0Q29tIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5ggEBMAkGA1UdEgQCMAAwPQYIKwYBBQUHAQEEMTAv
# MC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
# YAYDVR0fBFkwVzAsoCqgKIYmaHR0cDovL2NlcnQuc3RhcnRjb20ub3JnL3Nmc2Nh
# LWNybC5jcmwwJ6AloCOGIWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL3Nmc2NhLmNy
# bDCBggYDVR0gBHsweTB3BgsrBgEEAYG1NwEBBTBoMC8GCCsGAQUFBwIBFiNodHRw
# Oi8vY2VydC5zdGFydGNvbS5vcmcvcG9saWN5LnBkZjA1BggrBgEFBQcCARYpaHR0
# cDovL2NlcnQuc3RhcnRjb20ub3JnL2ludGVybWVkaWF0ZS5wZGYwEQYJYIZIAYb4
# QgEBBAQDAgABMFAGCWCGSAGG+EIBDQRDFkFTdGFydENvbSBDbGFzcyAyIFByaW1h
# cnkgSW50ZXJtZWRpYXRlIE9iamVjdCBTaWduaW5nIENlcnRpZmljYXRlczANBgkq
# hkiG9w0BAQUFAAOCAgEAUKLQmPRwQHAAtm7slo01fXugNxp/gTJY3+aIhhs8Gog+
# IwIsT75Q1kLsnnfUQfbFpl/UrlB02FQSOZ+4Dn2S9l7ewXQhIXwtuwKiQg3NdD9t
# uA8Ohu3eY1cPl7eOaY4QqvqSj8+Ol7f0Zp6qTGiRZxCv/aNPIbp0v3rD9GdhGtPv
# KLRS0CqKgsH2nweovk4hfXjRQjp5N5PnfBW1X2DCSTqmjweWhlleQ2KDg93W61Tw
# 6M6yGJAGG3GnzbwadF9BUW88WcRsnOWHIu1473bNKBnf1OKxxAQ1/3WwJGZWJ5Ux
# hCpA+wr+l+NbHP5x5XZ58xhhxu7WQ7rwIDj8d/lGU9A6EaeXv3NwwcbIo/aou5v9
# y94+leAYqr8bbBNAFTX1pTxQJylfsKrkB8EOIx+Zrlwa0WE32AgxaKhWAGho/Ph7
# d6UXUSn5bw2+usvhdkW4npUoxAk3RhT3+nupi1fic4NG7iQG84PZ2bbS5YxOmaII
# sIAxclf25FwssWjieMwV0k91nlzUFB1HQMuE6TurAakS7tnIKTJ+ZWJBDduUbcD1
# 094X38OvMO/++H5S45Ki3r/13YTm0AWGOvMFkEAF8LbuEyecKTaJMTiNRfBGMgnq
# GBfqiOnzxxRVNOw2hSQp0B+C9Ij/q375z3iAIYCbKUd/5SSELcmlLl+BuNknXE0x
# ggI1MIICMQIBATCBkzCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29t
# IEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25p
# bmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1lZGlh
# dGUgT2JqZWN0IENBAgIAgzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFjAjBgkqhkiG9w0BCQQxFgQUqXZyhT3gPb/yztv37JLm
# MK4u2YUwDQYJKoZIhvcNAQEBBQAEggEAr3pUvFrxGYAyWsVPDHQXkEry1vupa04M
# 0DJqCEb7lFFzDc56MKtOxr2L59+wOLN6go1KV7njbaQ5FbVC2CX8bIgeoiCXIKp0
# bsClIXTkViqS1BDcOxGM6RaQOzqFCy+8e5ahimkR+jxYGNTM2MnqEeHw8mY582ZU
# WOVnMYeF5pV+UQFsV/ri+jLk0BVHqkpMFy4F3BqeBH5U0jQ8Ai9Vh4OAfoDEdkAD
# aV+A5IVZmhUEuTG0v8MFeQM8XDU70NeusQleY3o98RlRT7/UW/MbOFxeM8Ogzyl2
# aIkAqJBpca3PlnaVVWWoNlTb3pjKkByLmEMkMMAnamBS2PJmauWlQg==
# SIG # End signature block

