function Get-VMKeyExchangeProperty
{
    param($VMName, $Name)

    $kec = get-ciminstance -ClassName msvm_computersystem -namespace root\virtualization\v2 | where elementname -eq $VMName | Get-CimAssociatedInstance -ResultClassName MSVM_KvpExchangeComponent -Namespace root\virtualization\v2
    $xml = [xml]"<root>$($kec.GuestIntrinsicExchangeItems)</root>"

    $nav = $xml.CreateNavigator().SelectSingleNode("root/INSTANCE/PROPERTY[@NAME='Name']/VALUE[child::text() = '$Name']")
    if ($nav -ne $null)
    {
        $nav.MoveToParent() | Out-Null
        $nav.MoveToParent() | Out-Null

        $nav.SelectSingleNode("PROPERTY[@NAME='Data']/VALUE/child::text()").Value
    }
}

<# 
FullyQualifiedDomainName
OSName
OSVersion
CSDVersion
OSMajorVersion
OSMinorVersion
OSBuildNumber
OSPlatformId
ServicePackMajor
ServicePackMinor
SuiteMask
ProductType
OSVendor
OSSignature
OSEditionId
ProcessorArchitecture
IntegrationServicesVersion
NetworkAddressIPv4
NetworkAddressIPv6
RDPAddressIPv4
RDPAddressIPv6
#>
