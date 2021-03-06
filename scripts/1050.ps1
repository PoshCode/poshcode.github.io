

[System.Reflection.Assembly]::Load('Microsoft.Build.Utilities.v3.5, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a') | out-null
[System.Reflection.Assembly]::Load('Microsoft.SharePoint, Version=12.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c') | out-null
$msbuild = [Microsoft.Build.Utilities.ToolLocationHelper]::GetPathToDotNetFrameworkFile("msbuild.exe", "VersionLatest")

$global:basepath = (resolve-path ..).path
$stsadm = Join-Path ([Microsoft.SharePoint.Utilities.SPUtility]::GetGenericSetupPath("BIN")) "stsadm.exe"


function Run-MSBuild($msBuildArgs)
{
	& $msbuild $msBuildArgs
}

function Get-FirstDirectoryUnderneathSrc
{
	dir (Get-FullPath "src") | where { $_.PSIsContainer -eq $true } | select -first 1
}

function Get-FullPath($subdirectory)
{
	return join-path -path $basepath -childPath $subdirectory
}

$wspbuilder = Get-FullPath("tools\WSPBuilder.exe")
function Run-WspBuilder($rootDirectory)
{
	pushd
	cd $rootDirectory
	& $WSPBuilder -BuildWSP true -OutputPath (Get-FullPath 'deployment')
	popd
}

function Clean-Path($dir)
{
	#I don't like the SilentlyContinue option, but we need to ignore the case
	#where there is no directory to delete (in this situation, an error is thrown)
	del $dir -recurse -force -erroraction SilentlyContinue
	mkdir $dir -erroraction SilentlyContinue | out-null
}

function Create-DeploymentBatchFile($filename, $featureName, $solutionName, $url)
{
	$contents = @"

ECHO OFF
SET STSADM="%PROGRAMFILES%\Common Files\Microsoft Shared\web server extensions\12\BIN\stsadm.exe"
%STSADM% -o deactivatefeature -name $featureName -url $url
%STSADM% -o retractsolution -allcontenturls -immediate -name $solutionName
%STSADM% -o execadmsvcjobs
%STSADM% -o deletesolution -name $solutionName -override
%STSADM% -o addsolution -filename $solutionName
%STSADM% -o deploysolution -allcontenturls -immediate -allowgacdeployment -name $solutionName
%STSADM% -o execadmsvcjobs
REM second call to execadmsvcjobs allows for a little more delay. Shouldn't be necessary, but is.
%STSADM% -o execadmsvcjobs
%STSADM% -o activatefeature -url $url -name $featureName
"@

	Out-File -inputObject $contents -filePath $filename -encoding ASCII
}

#Do-Deployment - regardless of current status, will install the Solution
function Do-Deployment($featureName, $solutionName, $rootDirectory)
{
	echo $featureName, $solutionName, $rootDirectory
	if (-not (Is-Installed $solutionName)) {
		Install-Solution -solutionName $solutionName -filename (join-path $rootDirectory $solutionName)	
	}
	
	Exec-AdmSvcJobs
	
	if (-not (Is-Deployed $solutionName)) {
		Deploy-Solution -solutionName $solutionName -featureName $featureName -filename (join-path $rootDirectory $solutionName)
	} else {
		Upgrade-Solution -solutionName $solutionName -featureName $featureName -filename (join-path $rootDirectory $solutionName)
	}
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

function Install-Solution($solutionName, $filename)
{
	#Assumes solution is NOT already installed. For "unsure installation", use Do-Deployment
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions.psbase.Add($filename) | out-null
}

function Deploy-Solution($featureName, $solutionName, $filename)
{
	#Assumes solution is already installed. For "unsure installation", use Do-Deployment
	$dateToGuaranteeInstantDeployment = [datetime]::Now.AddDays(-2)
	#method signature requires typed Collection, so we're unrolling 
	#the IEnumerable<SPWebApplication> into an array.
	$webApplications = [Microsoft.SharePoint.Administration.SPWebService]::ContentService.WebApplications | % { $_ }
	$webApplicationsCollection = new-object Microsoft.SharePoint.Administration.SPWebApplication[] -arg ($webApplications.Count)
	0..($webApplications.Count-1) | % { $webApplicationsCollection[$_] = $webApplications[$_] }
	
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Deploy($dateToGuaranteeInstantDeployment, $true, $webApplicationsCollection, $false)
}

function Upgrade-Solution($featureName, $solutionName, $filename)
{
	[Microsoft.SharePoint.Administration.SPFarm]::Local.Solutions[$solutionName].Upgrade($filename)
}

function Exec-AdmSvcJobs
{
	& $stsadm -o execadmsvcjobs
	#sleep for a few more seconds to account for concurrency bugs/timing issues
	sleep -seconds 2
}


