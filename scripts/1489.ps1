@@#BASEPATH variable should be explicitly set in every 
@@#build script. It represents the "root"
@@#of the project folder, underneath which all tools, source, config settings,
@@#and deployment folder lie.
@@$global:basepath = (resolve-path ..).path
@@function Set-BasePath([string]$path)
@@{
@@	$global:basepath = $path
@@}

function Get-FullPath($localPath)
{
	return join-path -path $global:basepath -childPath $localPath
}

function Clean-DeploymentFolder
{
	Clean-Path -dir (Get-FullPath 'deployment')
}

function Compile-Project
{
	Run-MSBuild -msBuildArgs @(
		((Get-FirstSolutionFileUnderneathSrc).Fullname), 
		"/target:Clean", 
		"/target:Build", 
		"/p:Configuration=Release")
}

function Create-DeploymentBatchFilesWithFeatureActivation($siteUrls)
{
	#Convention: project name == project folder name == Feature name == Solution name
	$projectName = (Get-FirstDirectoryUnderneathSrc).name
	$siteUrls.Keys | foreach {
		Create-DeploymentBatchFile -url $siteUrls[$_] -filename (Get-FullPath "deployment\deploy-$($_).bat") -featureName $projectName -solutionName "$($projectName).wsp"
		Create-UpgradeBatchFile -url $siteUrls[$_] -filename (Get-FullPath "deployment\upgrade-$($_).bat") -featureName $projectName -solutionName "$($projectName).wsp"
		Create-RetractionBatchFile -url $siteUrls[$_] -filename (Get-FullPath "deployment\z-retract-$($_).bat") -featureName $projectName -solutionName "$($projectName).wsp"
	}
}

function Get-FirstDirectoryUnderneathSrc
{
	dir (Get-FullPath "src") | where { $_.PSIsContainer -eq $true } | select -first 1
}

function Get-FirstSolutionFileUnderneathSrc
{
	dir (Get-FullPath "src\*") -include "*.sln" -recurse | select -first 1
}
function Run-DosCommand($program, [string[]]$programArgs)
{
	write-host "Running command: $program";
	write-host " Args:"
	0..($programArgs.Count-1) | foreach { Write-Host " $($_+1): $($programArgs[$_])" }
	& $program $programArgs
}

$wspbuilder = Get-FullPath "tools\WSPBuilder.exe"
function Run-WspBuilder()
{
	$rootDirectory = (Get-FirstDirectoryUnderneathSrc).fullname
	pushd
	cd $rootDirectory
	Run-DosCommand -program $WSPBuilder -programArgs @("-BuildWSP", 
		"true", 
		"-OutputPath", 
		(Get-FullPath "deployment"), 
		"-ExcludePaths",
		([string]::Join(";", @( 
			(Join-Path -path $rootDirectory -childPath "bin\Debug"),
			(Join-Path -path $rootDirectory -childPath "bin\deploy") 
			))))
	popd
}

$msbuild = "C:\Windows\Microsoft.NET\Framework\v3.5\msbuild.exe"
function Run-MSBuild([string[]]$msBuildArgs)
{
	Run-DosCommand $msbuild $msBuildArgs
}

function Clean-Path($dir)
{
	#I don't like the SilentlyContinue option, but we need to ignore the case
	#where there is no directory to delete (in this situation, an error is thrown)
	del $dir -recurse -force -erroraction SilentlyContinue
	mkdir $dir -erroraction SilentlyContinue | out-null
}

function Create-DeploymentBatchFile($filename, $featureName, $solutionName, $url, [switch]$allcontenturls)
{
	$contents = @"
%STSADM% -o deactivatefeature -name $featureName -url $url
%STSADM% -o retractsolution $(if ($allcontenturls) { "-allcontenturls" }) -immediate -name $solutionName
%STSADM% -o execadmsvcjobs
%STSADM% -o deletesolution -name $solutionName -override
%STSADM% -o addsolution -filename $solutionName
%STSADM% -o deploysolution $(if ($allcontenturls) { "-allcontenturls" }) -immediate -allowgacdeployment -name $solutionName
%STSADM% -o execadmsvcjobs
REM second call to execadmsvcjobs allows for a little more delay. Shouldn't be necessary, but is.
%STSADM% -o execadmsvcjobs
%STSADM% -o activatefeature -url $url -name $featureName
"@

	Create-StsadmBatchFile -filename $filename -contents $contents
}

function Create-UpgradeBatchFile($filename, $featureName, $solutionName, $url)
{
	$contents = @"
%STSADM% -o deactivatefeature -name $featureName -url $url
%STSADM% -o upgradesolution -immediate -allowgacdeployment -name $solutionName -filename $solutionName
%STSADM% -o execadmsvcjobs
REM second call to execadmsvcjobs allows for a little more delay. Shouldn't be necessary, but is.
%STSADM% -o execadmsvcjobs
%STSADM% -o activatefeature -url $url -name $featureName
"@

	Create-StsadmBatchFile -filename $filename -contents $contents
}

function Create-RetractionBatchFile($filename, $featureName, $solutionName, $url, [switch]$allcontenturls)
{
	$contents = @"
echo RETRACTING solution--press any key to continue, or CTRL+C to cancel
pause
%STSADM% -o deactivatefeature -name $featureName -url $url
%STSADM% -o retractsolution $(if ($allcontenturls) { "-allcontenturls" }) -immediate -name $solutionName
%STSADM% -o execadmsvcjobs
%STSADM% -o deletesolution -name $solutionName -override
%STSADM% -o execadmsvcjobs
"@

	Create-StsadmBatchFile -filename $filename -contents $contents
}


function Create-StsadmBatchFile($filename, $contents)
{
	$header= @"
SET STSADM="%PROGRAMFILES%\Common Files\Microsoft Shared\web server extensions\12\BIN\stsadm.exe"
"@

	$footer = @"
echo off
ECHO -------------------------------------------------------------
%STSADM% -o displaysolution -name $solutionName
pause
"@

	$wholeFileContents = $header + "`n" + $contents + "`n" + $footer
	Out-File -inputObject $wholeFileContents -filePath $filename -encoding ASCII
}

######################
#
# Deployment functions - not used at this time, can be REALLY useful
#    if we ever switch to PowerShell-based deployments.
#
######################

[reflection.assembly]::LoadWithPartialName("Microsoft.SharePoint") | out-null
[reflection.assembly]::LoadWithPartialName("Microsoft.Office.Server") | out-null

#Do-Deployment - regardless of current status, will install the Solution
function Do-Deployment($featureName, $solutionName, $rootDirectory)
{
	echo $featureName, $solutionName, $rootDirectory
	if (-not (Is-Installed $solutionName)) {
		Install-Solution -solutionName $solutionName -filename (join-path $rootDirectory $solutionName)	
	}

	if (-not (Is-Deployed $solutionName)) {
		Deploy-Solution -solutionName $solutionName
	} else {
		Upgrade-Solution -solutionName $solutionName -featureName $featureName -filename (join-path $rootDirectory $solutionName)
	}
	
	#post-step: somehow 
	#a) ON EACH SERVER run execadmsvcjobs - sub-note:
	#   - verify all timer services are healthy (?)
	#   - verify all IIS instances are healthy (?)
	#b) wait until we are 100% sure that step a) is finished
	#c) look at deployment status, and post-deployment, 
	#   - ON EACH SERVER, run Fix-LocalDeployments
	#
	#Until that day, manually run Fix-LocalDeployments
}

function Fix-LocalDeployments
{
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions | `
		where { (Identify-FailedDeployments $_) -contains $env:computername } | `
		foreach { write-host "$($_.Name)"; DeployLocal-Solution -solutionName $_.Name -force  }
}

$stsadm = [microsoft.sharepoint.utilities.sputility]::GetGenericSetupPath("bin\stsadm.exe")
function Exec-AdmSvcJobs
{
	& $stsadm -o execadmsvcjobs
	#sleep for a few more seconds to account for concurrency bugs/timing issues
	sleep -seconds 2
}

function Install-Solution($solutionName, $filename)
{
	#Assumes solution is NOT already installed. For "unsure installation", use Do-Deployment
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions.psbase.Add($filename) | out-null
}

#Assumes solution is already installed. For "unsure installation", use Do-Deployment
function Deploy-Solution($solutionName, [switch]$force)
{
	$dateToGuaranteeInstantAction = [datetime]::Now.AddDays(-2)
	
	$solution = [Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName]
	if ($solution.ContainsWebApplicationResource) {
		$webApplicationsCollection = Get-WebApplicationCollection
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Deploy($dateToGuaranteeInstantAction, $true, $webApplicationsCollection, $force)
	} else {
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Deploy($dateToGuaranteeInstantAction, $true, $force)
	}
}


#Assumes solution is already installed. For "unsure installation", use Do-Deployment
function DeployLocal-Solution($solutionName, [switch]$force)
{
	$solution = [Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName]
	if ($solution.ContainsWebApplicationResource) {
		$webApplicationsCollection = Get-WebApplicationCollection
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].DeployLocal($true, $webApplicationsCollection, $force)
	} else {
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].DeployLocal($true, $force)
	}
}

function Upgrade-Solution($featureName, $solutionName, $filename)
{
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Upgrade($filename)
}

function Retract-Solution($solutionName)
{
	#Assumes solution is already installed. For "unsure installation", use Do-Deployment
	$dateToGuaranteeInstantAction = [datetime]::Now.AddDays(-2)

	$solution = [Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName]
	if ($solution.ContainsWebApplicationResource) {
		#method signature requires typed Collection<SPWebApplication>, so we're unrolling into it
		$webApplicationsCollection = Get-WebApplicationCollection
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Retract($dateToGuaranteeInstantAction, $webApplicationsCollection)
	} else {
		[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Retract($dateToGuaranteeInstantAction)
	}

}

#method signature requires typed Collection<SPWebApplication>, so we're unrolling into it
function Get-WebApplicationCollection
{
	$coll = new-GenericObject -type "System.Collections.ObjectModel.Collection" -typeParameters ([Microsoft.SharePoint.Administration.SPWebApplication])
	[Microsoft.SharePoint.Administration.SPWebService]::ContentService.WebApplications | foreach { $coll.psbase.Add($_) }

	#explanation of oddball return syntax lies here:
	#http://stackoverflow.com/questions/695474
	return @(,$coll)
}

function Is-Installed($solutionName)
{
	#is Solution in the Solution store at all?
	return [Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName] -ne $null
}

function Is-Deployed($solutionName)
{
	#Is Solution successfully deployed everywhere? Partial/failed deployments don't count as deployed
	$solution = [Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName]
	if ($solution -eq $null) { return false; }
	
	return $solution.Deployed
}

function Identify-FailedDeployments([Microsoft.SharePoint.Administration.SPSolution]$solution)
{
	#NOTE TO SELF: rewrite without regex, the : in the URLs are terrible and are breaking the regexes
	if ($solution.ContainsWebApplicationResource) {
		#SERVERNAME : http://VIRTUAL-SERVER-URL:PORT/ : The solution was successfully deployed.
		$operationDetailsIndex = 2
	} else {
		#SERVERNAME : The solution was successfully deployed.
		$operationDetailsIndex = 1
	}
	
	$solution.LastOperationDetails.Split("`n") | `
		select `
			@{N="Server"; E={([regex]::Split($_, " : "))[0]}}, `
			@{N="Details"; E={ ([regex]::Split($_, " : "))[$operationDetailsIndex] }} | `
		where { -not ($_.details -like "*successfully deployed*") } | `
		foreach { $_.Server }
}


#acquired the following two functions from: http://solutionizing.net/2009/01/01/powershell-get-type-simplified-generics/
function New-GenericObject(
    $type = $(throw "Please specify a type"),
    [object[]] $typeParameters = $null,
    [object[]] $constructorParameters = @()
    )
{
    $closedType = (Get-Type $type $typeParameters)
    ,[Activator]::CreateInstance($closedType, $constructorParameters)
}

function Get-Type (
    $type = $(throw "Please specify a type")
    )
{
  trap [System.Management.Automation.RuntimeException] { throw ($_.Exception.Message) }

  if($args -and $args.Count -gt 0)
  {
    $types = $args[0] -as [type[]]
    if(-not $types) { $types = [type[]] $args }

    if($genericType = [type] ($type + '`' + $types.Count))
    {
      $genericType.MakeGenericType($types)
    }
  }
  else
  {
    [type] $type
  }
}




@@#
@@#USAGE
@@#. ./helper-functions.ps1
@@#
@@#       Set-BasePath -path ((resolve-path ..).path)
@@#       Clean-DeploymentFolder
@@#       Compile-Project
@@#       Run-WspBuilder
@@#       Create-DeploymentBatchFilesWithSolutionOnly
@@#
@@#
@@#
@@#
@@#
