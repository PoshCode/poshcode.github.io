$custSpec = New-OSCustomizationSpec -Type NonPersistent -OSType Windows -OrgName TestOrgName -FullName TestFullName -Workgroup TestWorkgroup
$custSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.23.121.228 -SubnetMask 255.255.248.0 -Dns 10.23.108.1 -DefaultGateway 10.23.108.1
New-VM -Name MyDeployedVM -Template $template -VMHost $vmHost -OSCustomizationSpec $custSpec 

