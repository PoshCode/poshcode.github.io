# validate given IP address as an IPAdress (given string input)
PARAM($ip=$(read-host "Enter any IP Address"))

try
{
    #parse fills missing octets with zeros in the order of 3rd, 2nd, 1st
    #("127.1" becomes "127.0.0.1") ("192.168.1" becomes "214.0.0.1") ("1" becomes "0.0.0.1")

    #test if converted IP matches original IP. If invalid, throws MethodInvocationException
    return [system.net.IPAddress]::parse("$ipAddress").IPAddressToString -eq "$ipAddress"
}
catch{return $false}

