function New-ODataServiceProxy {
#.Synopsis
#  Creates a proxy class for an odata web service and assigns it to the specified variable.
#  DOES NOT output the proxy on the pipleline, and you should not do so either!
#.Description 
#  Uses the data service client utility (DataSvcUtil.exe) to generate a proxy class (and types for all objects) for an OData web service.
#  WARNING: Outputting this object to the PowerShell host will result in queriying all the object collections on the service.
#  NOPTE: kb982307 is required to use this with .Net 3.5, see links/notes
#.Parameter URI
#  The URI for the web service
#.Parameter Name
#  The name of the global variable to store the OData WebService proxy object in (defaults to "ODataServiceProxy")
#.Parameter Passthru
#  Causes the method to output all of the types defined by the service metadata
#.Example
#  New-ODataServiceProxy http://odata.netflix.com/Catalog/
#  $AdventuresInOdyssey = $ODataServiceProxy.Titles.AddQueryOption('$filter',"substringof('Adventures in Odyssey',Name)")
#  $AdventuresInOdyssey | Format-List Name, ReleaseYear, Url, Synopsis
#.Example
# function Get-Films {
# param($Name)
#    New-ODataServiceProxy http://odata.netflix.com/Catalog/ -Name NetFlix
#    if($Name -match "\*") {
#       $sName = $Name -replace "\*" 
#       # Note the substring PLUS a Where -like filter to pull off wildcard matching which isn't supported by NetFlix
#       $Global:Films = $proxy.Titles.AddQueryOption('$filter',"substringof('$sName',Name)") | Where { $_.Name -like $Name }
#    } else {
#       $Global:Films = $proxy.Titles.AddQueryOption('$filter',"'$Name' eq Name")
#    }
#    $Films | Format-List Name, ReleaseYear, AverageRating, Url, Synopsis
#    Write-Host "NOTE: This data is cached in `$Films" -Fore Yellow
# }
# 
# C:\PS>Get-Films Salt
#
#.Example
#  New-ODataServiceProxy http://packages.nuget.org/v1/FeedService.svc/ NuGet
#  $NuGet.Packages.AddQueryOption('$filter',"startswith(Title,'O') eq true") | Format-Table Id, Version, Authors, Description -Wrap -Auto
#
#.Link 
#  Data Services Update for .Net 3.5 SP1: http://support.microsoft.com/kb/982307
#  ADO.NET Data Service Client Utility: http://msdn.microsoft.com/en-us/library/ee383989.aspx
#  AddQueryOption: http://msdn.microsoft.com/en-us/library/cc646860.aspx
#  NetFlix Catalog Documentation: http://developer.netflix.com/docs/oData_Catalog
#.Notes
#  I can't stress enough that you should not output the proxy object, or any property that returns a System.Data.Services.Client.DataServiceQuery[T] without a filter unless you're sure that's what you want.
#  A kb patch is required for .Net 3.5 SP1 to get the Data Services to 2.0 so you can use most of the OData services you will see on the web: http://support.microsoft.com/kb/982307
#
#  VERSION HISTORY:
#  v1.0    - 2010 Aug 02 - First Version http://poshcode.org/2039
#  v1.1    - 2010 Aug 03 - Simple Caching http://poshcode.org/2040
#          - Added a type cache to make it easier to find proxies you've already compiled (because we can't recompile them)
#  v1.2    - 2010 Aug 03 - Examples
#          - Added additional examples 
#  v1.3    - 2010 Aug 03 - Language fix
#          - Removed the Language parameter from Add-Type when on .Net4 (setting it explicitly results in downgrading to 3, and having multiple assembly references!?)
#  v1.4    - 2011 Jan 17 - Stop output
#          - Changed output to just be the variable that gets set, so it's properties don't all get called resulting in huge web service calls.
#  v1.5    - 2011 Jan 17 - Clean up examples
#          - Add Example for calling NuGet service
#          - Clean up Links, Re-document that you need the DataServices update for .Net 3.5 
param(
[Parameter(Mandatory=$true)]
[Alias("Uri","WSU")]
[String]$WebServiceUri = "http://odata.netflix.com/Catalog/", 
[Alias("Name","VN")]
[String]$VariableName = "ODataServiceProxy",
[switch]$Passthru
)

if(!(Test-Path Variable::Global:ODataServices)){
   ## You can only use this on .Net 4 or .Net 3.5 SP1 
   ## For .Net 3.5 SP1 you need to download http://support.microsoft.com/kb/982307
   ## If you don't have it, this won't succeed
   [Reflection.Assembly]::Load("System.Data.Services.Client, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") | Out-Null
   $global:ODataServices = @{}
}

$normalized = ([uri]$WebServiceUri).AbsoluteUri.TrimEnd("/") 

if($global:ODataServices.ContainsKey($normalized)) {
   New-Object $global:ODataServices.$normalized.ContextType $WebServiceUri
   if($Passthru) {
      $global:ODataServices.$normalized.OtherTypes
   }
   return
}

## Find the right DataSvcUtil for this version of .Net
switch($PSVersionTable.ClrVersion.Major) {
   4 { # PoshConsole and modded .Net4 PowerShell_ISE etc.
      Set-Alias Get-ODataServiceDefinition (Get-ChildItem ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory())  DataSvcUtil.exe)
      break
   }
   2 { # PowerShell.exe and everyone else
      $FrameworkPath = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() | Split-Path
      Set-Alias Get-ODataServiceDefinition (Get-ChildItem $FrameworkPath\v3.5\DataSvcUtil.exe)
      break
   }
   default { throw "This script is out of date, please fix it and upload a new one to PoshCode!" }   
}
## Get the service definition into a string via a temp file
$temp = [IO.Path]::GetTempFileName()
Get-ODataServiceDefinition -out:$temp -uri:$WebServiceUri -nologo | tee -var output | out-null
if(!$?) {
   Write-Error ($output -join "`n")
   return
}
$code = @(Get-Content $temp) -join "`n" # -Delim ([char]0)
Remove-Item $temp

switch($PSVersionTable.ClrVersion.Major) {
   4 { 
         $Types = Add-Type $code -Reference "System.Data.Services.Client, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089", "System.Core" -Passthru
   }
   2 {
         $Types = Add-Type $code -Reference "System.Data.Services.Client, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" -Passthru -Language CSharpVersion3 
   }
   default { throw "This script is out of date, please fix it and upload a new one to PoshCode!" }   
}

if(!$Types) { return }

$ContextType = $Types | Where-Object { $_.BaseType -eq [System.Data.Services.Client.DataServiceContext] }
$global:ODataServices.$normalized = New-Object PSObject -Property @{ContextType=$ContextType; OtherTypes=$([Type[]]($Types|Where-Object{$_.BaseType -ne [System.Data.Services.Client.DataServiceContext]}))}
$ctx = new-object $ContextType $WebServiceUri

$VariableName = $VariableName.Split(":")[-1]
if(Test-Path Variable:$VariableName) { Remove-Variable $VariableName -Force }
Set-Variable -Name "Global:$VariableName" -Value $ctx -Description "An OData WebService Proxy to $WebServiceUri" -Option ReadOnly, AllScope -Passthru
if($Passthru) { Write-Output $types }
}

