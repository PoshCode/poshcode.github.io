# Follwoing code to install and deploye site

# Parameter Section Start
$languagePack="{1033}" # this line is used to notify the language pack used by the sharepoint server

$path= "D:\tmp\ps\template\kolam.wsp"  # path of the wsp to be read
$feature =  "kolamWebTemplate" #Feature Name of the wsp to be activated which should be site as scope kolamWebTemplate
$solution =  "kolam.wsp" # Solution name for the wsp which is going to be installed and deployed
$targetUrl = "http://spf/kolam36" # Target location of the site with its url going to be created
$targetWebAppUrl = "http://spf" # web application URl where the site will be deployed
$targetSiteColUrl = "http://spf" # site collection URl where the site will be deployed
$SiteTitle = " &#1055;&#1088;&#1086;&#1074;&#1077;&#1088;&#1082;&#1072; &#1088;&#1072;&#1073;&#1086;&#1090;&#1099; &#1089;&#1072;&#1081;&#1090;&#1072; " # Title of the site which will be fetched from web template
$SiteName ="kolam36" # Name of the site which will be created
$SiteDesc = " Test  Site kolam" # Description of the site which will be created
# Parameter Section End


# Function Section Start # Below code is used as a timer job for the installation and retracting process
function WaitForJobToFinish([string]$SolutionFileName)
{
    $JobName = "*solution-deployment*$SolutionFileName*"
    $job = Get-SPTimerJob | ?{ $_.Name -like $JobName }
    if ($job -eq $null)
    {
        Write-Host 'Timer job not found'
    }
    else
    {
        $JobFullName = $job.Name
        Write-Host -NoNewLine "Waiting to finish job $JobFullName"
      
        while ((Get-SPTimerJob $JobFullName) -ne $null)
        {
            Write-Host -NoNewLine .
            Start-Sleep -Seconds 2
        }
        Write-Host  "Finished waiting for job.."
    }
}
# Function Section End



# Main Section Start
$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
 if ($snapin -eq $null) 
 {
  Write-Host "Loading SharePoint Powershell Snap-in"
  Add-PSSnapin "Microsoft.SharePoint.Powershell"
 }


$user=[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

Write-Host  "current user = $user"
Write-Host  "Deploying Solution Started.."

$WSP = Get-SPSolution | Where { 
    ($solution -eq $_.Name) 
} 
if($WSP -eq $null) { 
}
else
{
    Write-Host  "De-Activating feature -"$feature
    Disable-SPFeature -identity $feature -Url $targetSiteColURL -Confirm:$false
    Write-Host  "Feature de-activated - "$feature
  
    Write-Host  "Found " $WSP " - Uninstalling."
    Uninstall-SPSolution -Identity $solution -Confirm:$false
    WaitForJobToFinish($solution)
    Write-Host  $WSP "Uninstalled."
  
    Write-Host  "removing Solution -" $solution
    Remove-SPSolution -Identity $solution -Confirm:$false
    WaitForJobToFinish($solution)
    Write-Host  "removed Solution -" $solution
  
    Write-Host  "Deleting target site -" $targetUrl
    Remove-SPWEB -identity $targetUrl -Confirm:$false
    Write-Host  "Deleted target site - " $targetUrl

  
}



Write-Host  "Adding Solution"
Add-SPSolution -LiteralPath $path -Confirm:$false
Write-Host  "Added Solution"

Write-Host  "Installing Solution"
Install-SPSolution -Identity $solution -GACDeployment -Confirm:$false
WaitForJobToFinish($solution)
Write-Host  "Installed Solution"

Write-Host  "Activating feature - "$feature
Enable-SPFeature -identity $feature -Url $targetWebAppURL -Confirm:$false
Write-Host  "Feature activated - " $feature

#Below code finds the TemplateID for the site
$site= new-Object Microsoft.SharePoint.SPSite($targetWebAppUrl)
#$loc= [System.Int32]::Parse(1033)
#$templates= $site.GetWebTemplates($loc)
$templates= $site.GetWebTemplates($loc)
$templateId=""
foreach ($child in $templates)
{   
    if($child.Title -eq $SiteTitle)
    {
        $templateId= $child.Name
    
    }

}
$site.Dispose()



Write-Host  "Creating New site with templateID -" $templateId
$web = New-SPWeb -Url $targetUrl -Name $SiteName -Description $SiteDesc -AddToTopNav -Confirm:$false
Write-Host "New Site Created"
Write-Host "Applying template please wait....."
$web.ApplyWebTemplate($templateId)
$web.Dispose()
Write-Host "Site template applied successfully! Template = $templateId "
Write-Host -Fore Green "Solution deployment completed"
Write-Host "To visit the created site Browse - "-Fore Blue $targetUrl
get-pssession | remove-pssession

# Main Section End
