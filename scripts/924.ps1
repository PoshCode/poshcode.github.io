# Glenn Sizemore www . Get-Admin . Com
# Requires the NetApp OnTap SDK v3.5
#
# Will connect to the destination Filer and retrieve detailed information on every
# Cifs share.  This function will not retrieve permissions.
#
# Usage:
# Connect to the filler
# $Filer = 'TOASTER'
# $NetApp = New-Object NetApp.Manage.NaServer($filer,1,0)
# $NetApp.SetAdminUser(UserName,Password)
#
# Call the function
# Get-NaCifs -Server $NetApp
Function Get-NaCifs {
    Param(
        [NetApp.Manage.NaServer]$Server
    )
    Process {
        # Establish a connection and prepair to iterate through all shares.
        $NaElement = New-Object NetApp.Manage.NaElement("cifs-share-list-iter-start")
        $results = $Server.InvokeElem($naelement)
        $Tag = $results.GetChildContent("tag")  
        $RecordReturned = $results.GetChildContent("records")
        
        $processing=$true
        $increment = 50 #How many records should we process at a time
        # Loop until we get all shares
        While ($processing) {
            $NaElement = New-Object NetApp.Manage.NaElement("cifs-share-list-iter-next")
            $NaElement.AddNewChild("maximum",$increment)
            $NaElement.AddNewChild("tag",$Tag)
            $results = $Server.InvokeElem($naelement)
            $RecordReturned = $results.GetChildContent("records")
            IF ($RecordReturned -eq 0) {
                break
            } else {
                Foreach ($share in $results.GetChildByName("cifs-shares").GetChildren()) {
                    $S = "" | Select @{
                        N='Name'
                        E={$share.GetChildContent("share-name")}
                    }, @{
                        N='Path'
                        E={$share.GetChildContent("mount-point")}
                    }
                    # From here on out we'll use add-member because default shares
                    # Won't contain any of these properties.
                    switch($share) {
                        {$_.GetChildByName("caching")}
                            {
                                $S|Add-Member 'NoteProperty' 'Caching' $_.GetChildContent("caching")
                            }
                        {$_.GetChildByName("description")}
                            {
                                $S|Add-Member 'NoteProperty' 'Description' $_.GetChildContent("description")
                            }
                        {$_.GetChildByName("dir-umask")}
                            {
                                $S|Add-Member 'NoteProperty' 'DirUmask' $_.GetChildContent("dir-umask")
                            }
                        {$_.GetChildByName("file-umask")}
                            {
                                $S|Add-Member 'NoteProperty' 'FileUmask' $_.GetChildContent("file-umask")
                            }
                        {$_.GetChildByName("forcegroup")}
                            {
                                $S|Add-Member 'NoteProperty' 'Forcegroup' $_.GetChildContent("forcegroup")
                            }
                        {$_.GetChildByName("is-access-based-enum")}
                            {
                                $S|Add-Member 'NoteProperty' 'ABE' $true
                            }
                        {$_.GetChildByName("is-symlink-strict-security")}
                            {
                                if ($_.GetChildContent("is-symlink-strict-security") -eq "false") {
                                    $S|Add-Member 'NoteProperty' 'SymlinkStrictSecurity' $False
                                }
                            }
                        {$_.GetChildByName("is-vol-offline")}
                            {
                                IF ($_.GetChildContent("is-vol-offline") -eq "true") {
                                    $S|Add-Member 'NoteProperty' 'VolOffline' $true
                                }
                            }
                        {$_.GetChildByName("is-vscan")}
                            {
                                IF ($_.GetChildContent("is-vscan") -eq "true") {
                                    $S|Add-Member 'NoteProperty' 'VirusScanOnOpen' $True 
                                }
                            }
                        {$_.GetChildByName("is-vscanread")}
                            {
                                IF ($_.GetChildContent("is-vscanread") -eq "true") {
                                    $S|Add-Member 'NoteProperty' 'VirusScanOnRead' $True 
                                }
                               
                            }
                        {$_.GetChildByName("is-widelink")}
                            {
                                IF ($_.GetChildContent("is-widelink") -eq "true") {
                                    $S|Add-Member 'NoteProperty' 'WideLink' $True 
                                }
                            }
                        {$_.GetChildByName("maxusers")}
                            {
                                $S|Add-Member 'NoteProperty' 'MaxUsers' $_.GetChildContent("maxusers")
                            }
                        {$_.GetChildByName("umask")}
                            {
                                $S|Add-Member 'NoteProperty' 'Umask' $_.GetChildContent("umask")
                            }
                    }
                    Write-Output $S
                }
            }
        }
        $NaElement = New-Object NetApp.Manage.NaElement("cifs-share-list-iter-end")
        $NaElement.AddNewChild("tag",$Tag)
        [VOID]$Server.InvokeElem($naelement)
    }
}
