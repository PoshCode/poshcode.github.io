# This function does a HTTP GET against the vCloud 5.1 API using our current API session.
# It accepts any vCloud HREF.
function Get-vCloud51($href)
{
 $request = [System.Net.HttpWebRequest]::Create($href)
 $request.Accept = "application/*+xml;version=5.1"
 $request.Headers.add("x-vcloud-authorization",$global:DefaultCIServers[0].SessionId)
 $response = $request.GetResponse()
 $streamReader = new-object System.IO.StreamReader($response.getResponseStream())
 $xmldata = $streamreader.ReadToEnd()
 $streamReader.close()
 $response.close()
 return $xmldata
}
 
# This function gets an OrgVdc via 1.5 API, then 5.1 API.
# It then returns the HREF for the storage profile based on the $profilename and
 
function Get-storageHref($orgVdc,$profileName)
{
 $orgVdc51 = Get-vCloud51 $orgVdc.Href
 $storageProfileHref = $orgVdc51.vdc.VdcStorageProfiles.VdcStorageProfile | Where-Object{$_.name -eq "$profileName"} | foreach {$_.href}
 return $storageProfileHref
}
 
# Get vApp, Storage Profile and OrgvDC names
 
$vappName = read-host "vApp name"
$profileName = read-host "Storage Profile"
$orgVdcName = read-host "Org vDC Name"
 
$orgVdc = get-orgvdc $orgVdcName
 
#Get storage profile HREF

$profileHref = "https://vCD-server/api/vdcStorageProfile/871be6dc-71f4-4745-b1f2-d6566930204c"

 
# Change each VM's Storage Profile in the vApp
 
$CIvApp = Get-CIVApp $vappName
Foreach ($CIVM in ($CIvApp | Get-CIVM)) {
 $newSettings = $CIVM.extensiondata
 $newSettings.storageprofile.name = "$profileName"
 $newSettings.storageprofile.Href = $profileHref
 Write-Host "Changing the storage profile for $CIVM.name to $profileName"
 $newSettings.UpdateServerData()
}
