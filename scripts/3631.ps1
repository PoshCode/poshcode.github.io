<#  view all template wsp on custom site url

    based on
    http://www.danielbrown.id.au/Lists/Posts/Post.aspx?ID=74
#>


$site = Get-SPSite "http://spf"
     $web = $site.OpenWeb();
     foreach($lang in $web.RegionalSettings.InstalledLanguages)
     {
         Write-Host "Displaying Sites for Langauge: " $lang.DisplayName;
         $site.GetWebTemplates($lang.LCID) | Format-Table -Property Title, Name
     }
     $web.Dispose();
     $site.Dispose();
     
     
    <# second view not all template     #>
    
   
<#
function Get-SPWebTemplateWithId
{
    $templates = Get-SPWebTemplate | Sort-Object "Name"
    $templates | ForEach-Object {
        $templateValues = @{
            "Title" = $_.Title
            "Name" = $_.Name
            "ID" = $_.ID
            "Custom" = $_.Custom
            "LocaleId" = $_.LocaleId
        }
        New-Object PSObject -Property $templateValues | Select @("Name","Title","LocaleId","Custom","ID")
    }
}
Get-SPWebTemplateWithId | Format-Table

#>


<#
   $site = Get-SPSite "http://spf"
   foreach ($web in $site.AllWebs) { 
   $web | Select-Object -Property Title,Url,WebTemplate 
   }
   $site.Dispose()
   
   #>
