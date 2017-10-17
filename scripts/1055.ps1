function get-ipinformation
{
process {
    (Get-WmiObject Win32_NetworkAdapterConfiguration -computer $_ ) | ? { $_.IPenabled } | 
    select (AS Server , __server, 
        DNSHostName ,  DNSHostName ,         
        Mac , Macaddress,
        Description, Description,
        DNSDomain , DNSDomain,
        FirstIPAddress ,{ ($_.IPAddress) | select -first 1 }, 
        IPAddressAll , { [string] $_.IPAddress} ,
        IPSubnet , {($_.IPSubnet) | select -first 1 } , 
        IPSubnetall , { [string] $_.IPSubnet },
        DefaultIPGateway, { ($_.DefaultIPGateway) | select -first 1 } ,
        DefaultIPGatewayALL, { [string] $_.DefaultIPGateway },
        DHCPEnabled , { [bool] $_.DHCPEnabled },
        DHCPServer,  DHCPServer,
        PrimaryDNSServer , { ( $_.DNSServerSearchOrder)[0]  },
        SecondaryDNSServer , { ( $_.DNSServerSearchOrder)[1]  },
        AllDNSServer , { [string] $_.DNSServerSearchOrder }, 
        WINSPrimaryServer , WINSPrimaryServer,
        WINSSecondaryServer , WINSSecondaryServer,
                
        #random ones
        DomainDNSRegistrationEnabled , DomainDNSRegistrationEnabled,
        FullDNSRegistrationEnabled , FullDNSRegistrationEnabled,
        DNSDomainSuffixSearchOrder, DNSDomainSuffixSearchOrder,
        WINSEnableLMHostsLookup , WINSEnableLMHostsLookup
       )
    } 
}

#requires the follow function
function new-selectexpression
{
if ($args.count -eq 1) { $theargs = $args[0] } else {$theargs= $args }
if ($theargs.count -gt 1)
{
for($loop=0;$loop -lt ($theargs.count-1);$loop+=2)
 { 
  @{Name=$theargs[$loop];Expression=$theargs[$loop+1]} 
 }
}
if (!($theargs.count % 2) -eq 0) {@{Name=$input[$input.count-1];Expression= invoke-Expression "{}" } }
}


