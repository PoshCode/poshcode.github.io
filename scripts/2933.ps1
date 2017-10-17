########################################################################################
## Search Active Directory Forest
## Search-ADForest
########################################################################################
## NOTE: You have to have sufficient privileges on the target domain for this to work.
## NOTE: This script requires modification/customization prior to use.
########################################################################################
## USAGE:
##   Search-ADForest DomainA
##     * Executes the inserted Active Directory-based script on DomainA only
##   Search-ADForest
##     * Executes the inserted Active Directory-based script on all domains in the forest
########################################################################################
## EXAMPLES:
##
##  * Script run with no command line parameters. This prompts a search of all domains in
##	the current Active Directory Forest.
##
##         PoSH C:\> .\Search-ADForest.ps1
##         Checking DomainA
##         --- script runs and provides normal output for DomainA ---
##
##         Checking DomainB
##         --- script runs and provides normal output for DomainB ---
##
##         Checking DomainC
##         --- script runs and provides normal output for DomainC ---
##
##         Checking DomainD
##         --- script runs and provides normal output for DomainD ---
##
##
##  * Script run with a domain name as a command line parameter. This prompts a search of
##	all domains in the current Active Directory Forest that are 'like' the input.
##
##         PoSH C:\> .\Search-ADForest.ps1 DomainB
##         Checking DomainB
##         --- script runs and provides normal output for DomainB ---
##
##
##  * Script run with an FQDN as a command line parameter. This prompts a search of
##	all domains in the current Active Directory Forest that are 'like' the input.
##
##         PoSH C:\> .\Search-ADForest.ps1 DomainC.foo.bar.fabrikam.com
##         Checking DomainC.foo.bar.fabrikam.com
##         --- script runs and provides normal output for DomainC.foo.bar.fabrikam.com ---
########################################################################################

# Get Domain List
[string]$arg = $Args[0]
$objForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$DomainList = @($objForest.Domains | Select-Object Name | Where-Object {$_ -like "*$arg*"})
$Domains = $DomainLIst | foreach {$_.Name}

# Act on all applicable domains
foreach ($Domain in ($Domains))
{
    Write-Host "Checking $Domain" -foregroundcolor Red
    Write-Host ""

    #############################
    ##  YOUR SCRIPT GOES HERE  ##
    #############################

}

