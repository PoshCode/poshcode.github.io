#.Example
# 	Get-SPListItem "Scrum Team Assignments" 
# 	Gets all the items in the list with the default columns on them
#.Example
# 	Get-SPListItem -Name "Scrum Team Assignments" -Property "Scrum Team","Team Role","Last","First"
# 	Gets all the items in the list with just the specified columns as properties
#.Example
#   Get-SPListItem -ListUrl "https://sharepoint.domain.org/subsite/Lists/ListName/AllItems.aspx"
#   Deduces list and sharepoint service URL from the list url
function Get-SPListItem {
[CmdletBinding(DefaultParameterSetName="FromListName")]
param(
	# Url of the sharepoint (sub)site where the list is. This is NOT the url to the list, but to the site root
	# E.g: for https://sharepoint.domain.org/organization/site/Lists/listName/AllItems.aspx
	# You should put:  https://sharepoint.domain.org/organization/site/
	[Parameter(Mandatory=$True, Position=0, ParameterSetName="FromListName")]
	[string]$SharepointUrl,
	# The name of a sharepoint list to retrieve
	[Parameter(Mandatory=$True, Position=1, ParameterSetName="FromListName")]
	[String]$Name,
	# The full url to a sharepoint list (this only works if the URL has "/Lists/listname/" in it)...
	[Parameter(Mandatory=$True,ParameterSetName="FromListUrl")]
	[string]$ListUrl,
	# Columns that you want to retrieve from the list, as they appear in the list (or extra column names like "Created Date" or "Modified Date")
	[String[]]$Property,
	# Maximum number of items to retrieve (Defaults to 1000)
	[Int]$MaxCount = 1000
)
	if($PSCmdlet.ParameterSetName -eq "FromListUrl") {
		if(!$ListUrl.Contains("/Lists/")) {
			throw "Can't deduce list name from ListUrl"
		}
		$i = $ListUrl.IndexOf("/Lists/")
		$SharepointUrl = $ListUrl.SubString(0,$i)
		$ListName = $ListUrl.SubString($i+7, $ListUrl.IndexOf("/",$i+7) - $i - 7)
		if($ListName -match "%") {
			Add-Type -Assembly System.Web
			$ListName = [System.Web.HttpUtility]::UrlDecode($ListName)
		}
	}

	$ServiceUrl = $SharepointUrl.Trim("/") + "/_vti_bin/Lists.asmx"
	Write-Verbose "Sharepoint Service Url: $ServiceUrl"
	Write-Verbose "Sharepoint List Name: $ListName"
	
	# Must manually set the Service.Url even after you fetch the service (otherwise it points at the root site)
	$Service = New-WebServiceProxy $ServiceUrl -UseDefaultCred
	$Service.Url = $ServiceUrl

	# Help people out (a little) by printing the ErrorString from soap exceptions
	trap [System.Web.Services.Protocols.SoapException] {
		Write-Error $_.Exception.Detail.errorstring."#text"
		throw $_
	}
	
	# Get the list metadata from sharepoint and figure out what columns it has:
	$list = $Service.GetList($ListName) 	
	Write-Verbose "Default List View URL: $(([Uri]$SharepointUrl).GetLeftPart('authority'))$($List.DefaultViewUrl)"
	$Fields = $list.Fields.Field
	
	# A trick for debugging obstinate lists
	if($DebugPreference -gt "SilentlyContinue") {
		$Global:SPListFields = $Fields
		Write-Debug "Global variable SPListFields set to list fields for debugging purposes"
	}

	# Filter the list of columns if we were given a list
	if($Property.Count -gt 0) { 
		$Fields = $Fields | Where-Object { $Property -contains $_.DisplayName }
	} else {
		$Fields = $Fields | Where-Object { $_.FromBaseType -ne "TRUE" -and $_.Hidden -ne "TRUE" }
	}

	# Turn that list of columns into selectors for GetListItems and Select-Object
	$ViewFields = @()
	$ObjectProperties = @()
	foreach($f in $Fields.GetEnumerator()) {
		$ViewFields += $f.StaticName 
		$ObjectProperties += @{ Name = $f.DisplayName; Expression = [ScriptBlock]::Create("`$_.`"ows_$($f.StaticName)`"") }
	}

	# Generate some xml 
	[xml]$vf = "<ViewFields>$($ViewFields | ForEach-Object { "<FieldRef Name='$_'/>" })</ViewFields>"
	Write-Verbose $vf.OuterXml
	
	$ListItems = $service.GetListItems($listName, "", [Xml]"<Query/>", $vf, $MaxCount, [Xml]"<QueryOptions/>", "").Data.Row

	# A trick for debugging obstinate lists
	if($DebugPreference -gt "SilentlyContinue") {
		$Global:SPObjectProperties = $ObjectProperties
		Write-Debug "Global variable SPObjectProperties set to ObjectProperties for debugging purposes"
	}
	
	# A trick for debugging obstinate lists
	if($DebugPreference -gt "SilentlyContinue") {
		$Global:SPListItems = $ListItems
		Write-Debug "Global variable SPListItems set to list items for debugging purposes"
	}
	$ListItems | Select-Object $ObjectProperties
}



