# Export sharepoint web contents with powershell like
# stsadm -o export -url http://localhost:80/wiki -filename export.cab -overwrite -versions 1
#
# http://www.sharepointblogs.com/mossms/default.aspx
# http://msdn2.microsoft.com/en-us/library/microsoft.sharepoint.deployment.aspx

param ( [string] $sitename = "http://localhost:80", [string] $relweburl = "/wiki")

# Load Assembly
[void] [System.Reflection.Assembly]::Load("Microsoft.SharePoint, Version=12.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c") 


$spsite = new-object Microsoft.SharePoint.SPSite($SiteName)
$webpart = $spsite.openweb($relweburl, $false)


# Check type
if (!$webpart -is [Microsoft.SharePoint.SPWeb]) {
  Write-Host "Wrong type to export!" -foregroundcolor red
  exit
}


[System.Guid] $webguid = $webpart.ID
# $webguid.toString()


# Select Object to Export
[Microsoft.SharePoint.Deployment.SPExportObject] $exportObject = new-object Microsoft.SharePoint.Deployment.SPExportObject
$exportObject.Id = $webguid   
$exportObject.Type = [Microsoft.SharePoint.Deployment.SPDeploymentObjectType]::Web
$exportObject.ExcludeChildren = $FALSE
$exportObject.IncludeDescendants = [Microsoft.SharePoint.Deployment.SPIncludeDescendants]::All

# Export Settings
[Microsoft.SharePoint.Deployment.SPExportSettings] $expSettings = new-object Microsoft.SharePoint.Deployment.SPExportSettings
$expSettings.SiteUrl = $sitename
$expSettings.ExportObjects.Add($exportObject)
$expSettings.ExportMethod = [Microsoft.SharePoint.Deployment.SPExportMethodType]::ExportAll # Or ExportChanges
$expSettings.FileCompression = $TRUE
$expSettings.OverwriteExistingDataFile = $TRUE
$expSettings.BaseFileName = "export.cab"
$expSettings.IncludeSecurity = [Microsoft.SharePoint.Deployment.SPIncludeSecurity]::None # Or All
$expSettings.FileLocation = "."
$expSettings.LogFilePath = "./export.log"
$expSettings.IncludeVersions = [Microsoft.SharePoint.Deployment.SPIncludeVersions]::LastMajor
$expSettings.ExcludeDependencies = $FALSE
$expSettings.Validate()
# Show Settings
$expSettings

# Now Export
[Microsoft.SharePoint.Deployment.SPExport] $export = new-object Microsoft.SharePoint.Deployment.SPExport($expSettings)
$export.Run()

Write-Host "Done!"

trap [Exception] { 
      write-host $("`tTRAPPED: " + $_.Exception.GetType().FullName)
      write-host $("`tTRAPPED: " + $_.Exception.Message) 
      break
}
