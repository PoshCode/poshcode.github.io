# 1. Create a simple customizations spec:
$custSpec = New-OSCustomizationSpec -Type NonPersistent -OSType Windows `
    -OrgName “My Organization” -FullName “MyVM” -Domain “MyDomain” `
    –DomainUsername “user” –DomainPassword “password”
# 2. Modify the default network customization settings:
$custSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping `
    -IpMode UseStaticIP -IpAddress 192.168.121.228 -SubnetMask 255.255.248.0 `
    -Dns 192.168.108.1 -DefaultGateway 192.168.108.1
# 3. Deploy a VM from a template using the newly created customization:
New-VM -Name “MyNewVM” -Template $template -VMHost $vmHost `
    -OSCustomizationSpec $custSpec

