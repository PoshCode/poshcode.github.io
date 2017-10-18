function Update-Scopes($siteUrl)
{
	[void][reflection.assembly]::Loadwithpartialname("Microsoft.SharePoint") | out-null
	[void][reflection.assembly]::Loadwithpartialname("Microsoft.office.server.search") | out-null
	
	$s = [microsoft.sharepoint.spsite]$siteUrl
	$sc = [microsoft.office.server.servercontext]::GetContext($s)
	$search = [Microsoft.Office.Server.Search.Administration.SearchContext]::GetContext($sc)
	$scopes = [microsoft.office.server.search.administration.scopes]$search
	$scopes.StartCompilation()
	while ($scopes.CompilationPercentComplete -lt 100) { sleep -seconds 3; write-host "$($scopes.CompilationPercentComplete)% complete" }
}

@@#usage: paste this text into your PowerShell window, then call the "Update-Scopes" function as noted below
@@Update-Scopes -siteUrl "http://dev/sites/MySPSite/"

