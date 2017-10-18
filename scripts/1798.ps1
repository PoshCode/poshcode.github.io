####### Log deletions in all sites in a web application ######

############# http://iLoveSharePoint.com ##################
############## by Christian Glessner ######################

################ begin config #################

# Url of the web application to audit. Don't forget to activate the delete audit log on sites you want to log.
$targetWebAppUrl = "http://localhost:100"

# Url of the web that contains the list to log (list must contains the following columns: "Title" (text), "Event Url" (Url), "Item Type" (text), "Event" (text), "Occurred" (DateTime), "User" (text)"
$logWebUrl = "http://localhost:100"

# Title of the log list
$logListTitle ="Audit"

################# end config ##################

$lastRunPropName = "_iLSP_lastAuditTimestamp"

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SharePoint')

$logSite = New-Object Microsoft.SharePoint.SPSite($logWebUrl)
$logWeb = $logSite.OpenWeb()
$logList = $logWeb.Lists[$logListTitle]

$targetWebApp = [Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($(New-Object Uri($targetWebAppUrl)))

if($targetWebApp.Properties.ContainsKey($lastRunPropName) -eq $false)
{
	$targetWebApp.Properties[$lastRunPropName] = [DateTime]::MinValue
	$targetWebApp.Update()
}

$lastRun = [DateTime]::Parse($targetWebApp.Properties[$lastRunPropName].ToString())
$newRun = [DateTime]::Now.ToUniversalTime()

foreach($site in $targetWebApp.Sites)
{	
	$query = New-Object Microsoft.SharePoint.SPAuditQuery($site)
	$query.AddEventRestriction([Microsoft.SharePoint.SPAuditEventType]::Delete)
	$query.SetRangeStart($lastRun)
	$query.SetRangeEnd($newRun.AddDays(1))
	
	$result = $site.Audit.GetEntries($query)
	
	if($result.Count -gt 0)
	{
		foreach($entry in $result)
		{
			$eventUrl = $site.Url + "/" + $entry.DocLocation
			
			$item = $logList.Items.Add()
			$item[[Microsoft.SharePoint.SPBuiltInFieldId]::Title] = $entry.DocLocation
			$item["Event Url"] = $eventUrl
			$item["Item Type"] = $entry.ItemType
			$item["Event"] = $entry.Event
			$item["Occurred"] = $entry.Occurred.ToLocalTime()
			$item["User"] = $logWeb.SiteUsers.GetByID($entry.UserId).LoginName
			$item.Update()
			
		}
	}
	
	$site.Dispose()
}

$targetWebApp.Properties[$lastRunPropName] = $newRun
$targetWebApp.Update()

$logWeb.Dispose()
$logSite.Dispose()
