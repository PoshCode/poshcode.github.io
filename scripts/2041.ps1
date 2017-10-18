function Get-Films {
param($Name)
   $proxy = New-ODataServiceProxy http://odata.netflix.com/Catalog/
   if($Name -match "\*") {
      $sName = $Name -replace "\*" 
      $Global:Films = $proxy.Titles.AddQueryOption('$filter',"substringof('$sName',Name)") | Where { $_.Name -like $Name }
   } else {
      $Global:Films = $proxy.Titles.AddQueryOption('$filter',"'$Name' eq Name")
   }
   $Films | Format-List Name, ReleaseYear, AverageRating, Url, Synopsis
   Write-Host "NOTE: This data is cached in `$Films" -Fore Yellow
}

Get-Films Salt
Get-Films "The Matrix*"
Get-Films "Ernest*"
