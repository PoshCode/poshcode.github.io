# Glenn Sizemore www . Get-Admin . Com
# Requires the NetApp OnTap SDK v3.5
#
# Will connect to the destination Filer and retrieve all cifs shares, 
# and there permissions.  While we can get cifs information directly
# from a filer we can't get ACL information easily.  The only options
# are either RPC(too hard for me) or a screen scrape.
#
# Usage:
# Connect to the filler
# $Filer = 'TOASTER'
# $NetApp = New-Object NetApp.Manage.NaServer($filer,1,0)
# $NetApp.SetAdminUser(UserName,Password)
#
# Call the function
# Get-NaShares -Server $NetApp
Function Get-NaShares {
    Param(
        [NetApp.Manage.NaServer]$Server
    )
    Begin {
        $obj=$null
    }
    Process {
        $NaElement = New-Object NetApp.Manage.NaElement("system-cli")
        $arg = New-Object NetApp.Manage.NaElement("args")
        $arg.AddNewChild('arg','cifs')
        $arg.AddNewChild('arg','shares')
        $NaElement.AddChildElement($arg)
        $CifsString = $Server.InvokeElem($naelement).GetChildContent("cli-output")

        $null, $null, $Lines = $CifsString.Split("`n")
        Foreach ($l in $Lines) {
            Switch -regex ($l) {
                "^(?<Volume>\S+)\s+(?<Mount>\S+)\s+(?<Description>.+)" 
                    {
                        IF ($obj) {
                            $obj.Access = $ACL
                            write-output $obj
                        }
                        $ACL = @()
                        $obj = ""|Select Share,Path,Description,Access
                        $obj.Share = $matches.Volume
                        $obj.Path = $matches.Mount
                        $obj.Description = $matches.Description
                        Break;
                    }
                "\s+(?<Domain>\S+)\\(?<User>\S+)\s+\/\s+(?<Perms>\S+(\s)?(\S+)?)$"
                    {   
                        $ACL += $Matches|Select @{
                                N='Domain'
                                E={$_.Domain}
                            }, @{
                                N='UserName'
                                E={$_.User}
                            }, @{
                                N='Permissions'
                                E={$_.Perms}
                            }
                         Break;
                    }
                "(?<User>\S+)\s+\/\s+(?<Perms>\S+(\s)?(\S+)?)$"
                    {   
                        $ACL += $Matches|Select @{
                                N='Domain'
                                E={''}
                            }, @{
                                N='UserName'
                                E={$_.User}
                            }, @{
                                N='Permissions'
                                E={$_.Perms}
                            }
                         Break;
                    }
            }
        }
        $obj.Access = $ACL
        write-output $obj
    }
}

