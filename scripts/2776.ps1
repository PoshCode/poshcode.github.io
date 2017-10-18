Function Get-SiSReport
{
    <#
        .SYNOPSIS
            Get the overall SIS usage information.
        .DESCRIPTION
            This function uses the sisadmin command to get the usage
            information for a SIS enabled drive.
        .PARAMETER SisDisk
            The drive letter of a disk that has SiS enabled
        .EXAMPLE
            Get-SiSReport -SisDisk o

            LinkFiles             : 20004
            Used                  : 442378481664
            Disk                  : o
            InaccessibleLinkFiles : 0
            CommonStoreFiles      : 6678
            SpaceSaved            : 7708860 KB
            Free                  : 0
            
            Description
            -----------
            This example shows the basic usage of the command

        .NOTES
            This function will return nothing if the drive being analyzed does not have SiS enabled
            This function will return a message if the sisadmin command returns any error
        .LINK
    #>
    
    Param
    (
    $SisDisk = "c"
    )

    Begin
    {
        $SisAdmin = "& sisadmin /v $($SisDisk):"
        Try
        {
            $SisResult = Invoke-Expression $SisAdmin
            }
        Catch
        {
            Return "Single Instance Storage is not available on this computer"
            }
        }

    Process
    {
        If ($SisResult.Count)
        {
            $ThisDisk = Get-PSDrive $SisDisk
            $SisReport = New-Object -TypeName PSObject -Property @{
                "Disk" = $SisDisk
                "Used (GB)" = [math]::round(($ThisDisk.Used /1024 /1024 /1024),2)
                "Free (GB)" = [math]::round(($ThisDisk.Used /1024 /1024 /1024),2)
                "Common Store Files" = ($SisResult[($SisResult.Count)-4]).TrimStart("Common store files:")
                "Link Files" = ($SisResult[($SisResult.Count)-3]).TrimStart("Link files:")
                "Inaccessible Link Files" = ($SisResult[($SisResult.Count)-2]).TrimStart("Inaccessible link files:")
                "Space Saved (GB)" = [math]::round(((($SisResult[($SisResult.Count)-1]).TrimStart("Space saved:")).TrimEnd(" KB")/1024 /1024),2)
                }
            }
        }

    End
    {
        Return $SisReport
        }
}
