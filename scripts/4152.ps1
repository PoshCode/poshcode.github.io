mkdir SelfHostDemo | cd
nuget install Microsoft.AspNet.WebApi.SelfHost

# You probably don't have the PowerShell module to Import-NuGetPackage *; so do it by hand:
$xlr8r = [psobject].assembly.gettype("System.Management.Automation.TypeAccelerators")
ls *\lib\net40\*.dll | sort CreationTime | %{ Add-Type -Path $_ -Pass } | % { $xlr8r::Add( $_.Name, $_) }

$conf = [HttpSelfHostConfiguration]"http://localhost:8080"
$null = [HttpRouteCollectionExtensions]::MapHttpRoute( $conf.Routes, "DefaultApi", "api/{controller}/{id}", [PSCustomObject]@{id= [RouteParameter]::Optional } )
$server = [HttpSelfHostServer]$conf
$server.OpenAsync().Wait()
Read-Host "Listening..."

