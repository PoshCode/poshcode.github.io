#
# import-VCBImage.ps1    : use the Converter to import a VCB created disk image into a datacenter
#
# Author:       LucD
#
# History:
#
#       v1.0 20/09/09   first version
#
$I2VImageDir = <directory where the VCB images are stored>
$I2VShare = <Sharename of the $I2VImageDir directory>
$tgtDatacenter = <Target-datacenter>
$I2Vuser = <account with access to the image directory and to the datacenter>
$I2Vpassword = <password of the $I2Vuser account>
$I2Vhost = <hostname where the images are stored>
$ConvProgDir = "$env:ProgramFiles (x86)\VMware\Infrastructure\Converter Enterprise" 
$ConvService = "vmware-converter" 
$I2Vprog = "converter-tool.exe" 

# Template XML file for Convertor job
$p2v = [xml]@"
<p2v version="2.2" xmlns="http://www.vmware.com/v2/sysimage/p2v" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/v2/sysimage/p2v p2vJob.xsd" xsi:type="P2VJob">
  <source>
    <hostedSpec networkPassword="" networkUsername="" path=""/>
  </source>
  <dest>
    <managedSpec datastore="" folder="" host="" resourcePool="" vmName="">
      <creds host="" port="0" type="sessionId" username="" password="" />
    </managedSpec>
  </dest>
  <importParams diskType="VMFS" preserveHWInfo="true" removeSystemRestore="false" targetProductVersion="PRODUCT_MANAGED">
    <nicMappings/>
    <diskLocations/>
  </importParams>
  <postProcessingParams/>
</p2v>
"@

# Function will start a DOS commmand and wait for it to finish
#
function Invoke-Cmd{
	param($cmd, $arguments)

	$global:StdOut = ""
	$global:StdErr = ""

	$pStart = new-object System.Diagnostics.ProcessStartInfo
	$pStart.Filename = $cmd
	$pStart.Arguments = $arguments
	$pStart.UseShellExecute = $false
	$pStart.ErrorDialog = $false
	$pStart.CreateNoWindow = $True
	$pStart.RedirectStandardOutput = $true
	$pStart.RedirectStandardError = $true
	$myProcess = [System.Diagnostics.Process]::Start($pStart)

	$myOutput = $myProcess.StandardOutput
	$myErrOutput = $myProcess.StandardError
	$global:StdOut = $myOutput.ReadToEnd()
	$global:StdErr = $myErrOutput.ReadToEnd()

	$myProcess.WaitForExit()

	$myProcess.ExitCode
}

# Function that builds the Converter XML file and launches the job
#
function Import-VCBImage{
	param($vmName, $portgroup) 
# Check if directory exists 
	if((Get-Item -path ($I2VImageDir + "\*") | Where-Object {$_.Name -eq $vmName} | Measure-Object).Count -ne 1){
		Write-Host "Snapshot directory not found for " $vmName 
		return 
	} 
# Determine target VmHost and target Datastore based on largest free space on datastore 
	$selectESX = "" 
	$selectDS = "" 
	$selectFree = 0 
	Get-Datacenter $tgtDatacenter | Get-VMHost | % { 
		$tmpESX = $_.Name 
		$_ | Get-Datastore | % { 
			if($_.FreeSpaceMb -gt $selectFree){ 
				$selectESX = $tmpESX 
				$selectDS = $_.Name 
				$selectFree = $_.FreeSpaceMb 
			} 
		} 
	} 
# Check if sufficient free space on ESXi server 
	if(((Get-Item -path ($I2VImageDir + "\" + $vmName + "\*") | Measure-Object -property Length -sum).Sum / 1mb) -gt $selectFree){
		Write-Host "Not enough free disk space on" $selectFree 
		return 
	} 
# Find VMX file 
	$vmxName = (Get-Item -path ($I2VImageDir + "\" + $vmName + "\*") | Where-Object {$_.Name -like "*.vmx"}).Name
# Update fields in XML tree 
	$p2v.p2v.source.hostedSpec.path = "\\" + $I2Vhost + "\" + $I2VShare + "\" + $vmName + "\" + $vmxName
	$p2v.p2v.source.hostedSpec.networkUsername = $I2Vuser
	$p2v.p2v.source.hostedSpec.networkPassword = $I2Vpassword 
	$p2v.p2v.dest.managedSpec.creds.username = $I2Vuser 
	$p2v.p2v.dest.managedSpec.creds.password = $I2Vpassword 
	$p2v.p2v.dest.managedSpec.datastore = $selectDS 
	$p2v.p2v.dest.managedSpec.host = $selectESX 
	$p2v.p2v.dest.managedSpec.folder = "" 
	$p2v.p2v.dest.managedSpec.resourcePool = "" 
	$V2VvmName = $vmName + "-" + $tgtDatacenter + "-" + (Get-Date -format yyyyMMdd-HHmmss)
	$p2v.p2v.dest.managedSpec.vmName = $V2VvmName 
	$p2v.p2v.dest.managedSpec.creds.host = $I2Vhost 
	$p2v.p2v.dest.managedSpec.creds.username = $I2Vuser 
	$p2v.p2v.dest.managedSpec.creds.password = $I2Vpassword 
# As a security measure the RDM machines are connected to the isolated network 
	$NIC = $p2v.CreateElement("nicMapping") 
	$network = $p2v.CreateAttribute("network") 
	$network.psbase.Value = $portgroup
	$dummy = $NIC.SetAttributeNode($network) 
	$p2v.p2v.importParams["nicMappings"].AppendChild($NIC) 
# Save the XML file 
	$XMLfile = $I2VImageDir + "\" + "I2V-" + $vmName + ".xml" 
	$p2v.Save($XMLfile) 
# Start Convertor service if it is not running. 
	if((Get-Service -name $ConvService).Status -eq "Stopped"){ 
		Start-Service -name $ConvService 
	} 
# Start the import 
# ! parameters are case-sensitive ! (--vchost is not accepted, must be --vcHost) ! 
	$myarg = "--vcHost " + $I2Vhost + " --jobExec " + $XMLfile + " --vcCred " + $I2Vuser + ":" + $I2Vpassword 
	$mycmd = $ConvProgDir + "\" + $I2Vprog 
	$rc = Invoke-Cmd $mycmd $myarg 

# Remove older DRM guest(s) (if present AND if V2V completed successfully) 
	if($rc -eq 0){ 
		foreach($vm in (Get-Datacenter $tgtDatacenter | Get-VM ($vmName + "-" + $tgtDatacenter + "*") | where {$_.Name -ne $V2VvmName})){ 
			$vm | Remove-VM - DeleteFromDisk:$true - Confirm:$false 
		} 
	} 
} 

# Sample call
# Import-VCBImage "PC1" "isolated"


