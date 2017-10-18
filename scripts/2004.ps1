# 1. Create a simple customizations spec
$custSpec = New-OSCustomizationSpec -Type NonPersistent -OSType Windows -OrgName TestOrgName -FullName TestFullName -Workgroup TestWorkgroup
# 2. Modify the default network customization settings
$custSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress 10.23.121.228 -SubnetMask 255.255.248.0 -Dns 10.23.108.1 -DefaultGateway 10.23.108.1
# 3. Deploy a VM from template using the newly created customization
New-VM -Name MyDeployedVM -Template $template -VMHost $vmHost -OSCustomizationSpec $custSpec 

