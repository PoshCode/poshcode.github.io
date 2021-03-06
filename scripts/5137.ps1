import-module activedirectory

"Active Directory Module Initiated"

[string]$url = "http://myservername/Lists/SP_List_AD_Names/"
$totalCount = 0

#create the new Sharepoint Object we are working with
$site = New-Object Microsoft.SharePoint.SPSite($url) 

#open it
$web = $site.OpenWeb()

#defines the list we are looking for
$list = $web.Lists["SP_List_AD_Names"]

#for each item found in SP_LIST_AD_NAMES, go hard and find the AD information
foreach ($listItem in $list.Items)
{
    $SubGroups = @()

    #Create an empty array
    $AllMembers = @()
    
    #Populate it with all recursive members of the group
    $strGroupOwner = Get-ADGroup -identity $listItem.name -Properties ManagedBy | select managedby
    $strOwnerName = get-aduser -identity $strGroupOwner.managedby -properties samaccountname |select -ExpandProperty samaccountname
    $strGroupName = $listItem.Name
    "Group is named: " + $strGroupName
    "Group is owned by: " + $strOwnerName
    
    
    ForEach($Person in (Get-ADGroupMember $listItem.name -Recursive)){
        $totalCount ++
        $User = Get-ADUser $Person -Property description
    
        $AllMembers += New-Object PSObject -Property @{
    
            Name = $Person.Name
            Description = $User.Description
            NetworkID = $Person.SamAccountName
            Nested = $Null
            Group = $strGroupName
            Owner = $strOwnerName
    
                                                       }

        
                                                                    }
        
    $CurrentGroup = Get-ADGroupMember $ListItem.Name
    

@@ #this is where I want to push $AllMembers to my $list   

}


    "Current Group: " + $CurrentGroup
        
    Write-Host "Total Items = " $totalCount 

