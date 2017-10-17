#Script Author Information
$script:ProgramName = "AD Site Info"
$script:ProgramDate = "10 Feb 2014"
$script:ProgramAuthor = "Geoffrey Guynn"
$script:ProgramAuthorEmail = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String("Z2VvZmZyZXlAZ3V5bm4ub3Jn"))

#Script Information
$script:WorkingFileName = $MyInvocation.MyCommand.Definition
$script:WorkingDirectory = Split-Path $script:WorkingFileName -Parent

$script:saveto = $script:WorkingDirectory
$script:saveSiteInfo = Join-Path -Path $script:SaveTo -ChildPath "siteinfo_$(Get-Date -f "yyyy-MM-dd-hhmmsstt").txt"
$script:saveDomainInfo = Join-Path -Path $script:SaveTo -ChildPath "domaininfo_$(Get-Date -f "yyyy-MM-dd-hhmmsstt").txt"

$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$AD_Domains = $Forest.Domains | Sort Name
$AD_Sites = $Forest.Sites | Sort Name
$SchemaRole = $Forest.SchemaRoleOwner
$NamingRole = $Forest.NamingRoleOwner

$AD_Sites | % {
    "`r`nName: $($_.Name)" >> $script:saveSiteInfo
    "Domains: $(@($_.Domains | sort) -join "`r`n`t")" >> $script:saveSiteInfo
    "Servers: $(@($_.Servers | sort) -join "`r`n`t")" >> $script:saveSiteInfo
    "Site Links: $(@($_.SiteLinks | sort) -join "`r`n`t")" >> $script:saveSiteInfo
    "Subnets: $(@($_.Subnets | Sort) -join "`r`n`t")" >> $script:saveSiteInfo
}

$AD_Domains | % {
    "`r`n`r`nName: $($_.Name)" >> $script:saveDomainInfo
    "Domain Functional Level: $($_.DomainMode)" >> $script:saveDomainInfo
    "PDC: $($_.PdcRoleOwner)" >> $script:saveDomainInfo
    "RID: $($_.RidRoleOwner)" >> $script:saveDomainInfo
    "Schema: $SchemaRole" >> $script:saveDomainInfo
    "Naming: $NamingRole" >> $script:saveDomainInfo
    "DomainControllers:" >> $script:saveDomainInfo
    $DCObjects = $_.DomainControllers | Select Name, CurrentTime, IPAddress | Sort Name
    $DCObjects | % {
        "`r`nDC Name: $($_.Name)" >> $script:saveDomainInfo
        "DC CurrentTime: $($_.CurrentTime.ToString())" >> $script:saveDomainInfo
        "DC IP Address: $($_.IPAddress)" >> $script:saveDomainInfo
    }
}
