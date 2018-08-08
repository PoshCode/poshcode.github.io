Get-SPWebApplication | Get-SPSite -Limit ALL | 
ForEach-Object {
    $content = "";
    $rootSite = New-Object Microsoft.SharePoint.SPSite($_.Url)
    $subSites = $rootSite.AllWebs;
    
    if($subSites.Count -le 0)
    {
	@@ This occurs when a Site Collection does not contains any subsite (not even the root site)
        Write-Host "The Site Collection"  $siteUrl  "does not contains any site."
    }
    else
    {
        foreach($subsite in $subSites) 
        {
            $siteOwnersGroup = $subsite.AssociatedOwnerGroup
            if($siteOwnersGroup)
            {
                foreach ($owner in $siteOwnersGroup.Users) 
                {
                    if($subsite.ParentWeb)
                    {
                        $content += "$($subsite.ParentWeb.Url),$($owner.Name),Site Owner`n"
                    }
                    else
                    {
                        $content += "$($subsite.Url),$($owner.Name),Site Owner`n"
                    }
                }
            }
            else
            {
                $content += "Could not find an AssociatedOwnerGroup in the site with the Url: $($subsite.Url) `n"
            }  
            
            $subsite.Dispose()
            $rootSite.Dispose()
        }
        @@ Set the path to the CSV files
        $FilePath = "C:\Owners\" + $_.Url.Replace("http://","").Replace("/","-").Replace(":","-") + ".csv";
	out-file -filepath $FilePath -inputobject $content
    }
}
