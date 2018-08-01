# validate given IP address as an IPAdress (given string input)
PARAM($IP=$(read-host "Enter any IP Address"))

## YOU could do this, but ...
# $IP -match "(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})" -and -not ([int[]]$matches[1..4] -gt 255)

## you shouldn't parse things yourself when it's in the framework. You might make a mistake ;-)
trap { return $false }
[IPAddress]$IP  # Just cast it to an IPAddress ... if it's valid, it will work.
return $true
