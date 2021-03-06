param($msBuildTarget, $configurationName, [bool]$deleteInstrumentedAssemblies) 

#-------------------------------------
# Script to compile coverage for a WCF
# solution running in IIS.
# See:
# http://geekswithblogs.net/EltonStoneman/archive/2011/10/14/end-to-end-wcf-code-coverage-with-powershell.aspx 
#-------------------------------------

#-------------------------------------
# Function to get the running app pool 
#-------------------------------------
function get-apppool{
    [regex]$pattern="-ap ""($appPoolName)"""
    gwmi win32_process -filter 'name="w3wp.exe"' | % {
        $name=$_.name
        $cmd = $pattern.Match($_.commandline).Groups[1].Value
        $procid = $_.ProcessId
        New-Object psobject | Add-Member -MemberType noteproperty -PassThru Name $name |
            Add-Member -MemberType noteproperty -PassThru AppPoolID $cmd |
            Add-Member -MemberType noteproperty -PassThru PID $procid 
    }
}

#---------------------------------------
# Function to get the id of the app pool 
#---------------------------------------
function get-apppoolpid{
	$appPoolPid = 0
	$appPools = get-apppool
	foreach ($appPool in $appPools){
		if ($appPool.AppPoolID -eq "$appPoolName"){
			$appPoolPid = $appPool.PID
		}
	}
	write-host "$solutionFriendlyName app pool PID: $appPoolPID"
	return $appPoolPid
}

#------------------------------------------------
# Starts the app pool by making a service request
#------------------------------------------------
function start-apppool{
	#ping the service to start a new app pool process:
	$uri = new-object System.Uri("$wakeUpServiceUrl")
	$client = new-object System.Net.WebClient
	$client.DownloadString($uri) | out-null
}

#-------------------
# Kills the app pool
#-------------------
function kill-apppool{
	$procId = get-apppoolpid
	if ($procId -ne 0){
		write-host "Killing app pool process"
		$proc = [System.Diagnostics.Process]::GetProcessById($procId)
		$proc.Kill()      
	}
}

#------------------------------------------------------------------------------
# Instruments an assembly for code coverage, excluding the specified namespaces
#------------------------------------------------------------------------------
function instrument2([string]$assemblyName, [string[]]$excludes){
	$assy = "$websiteBinDirectory\$assemblyName"
	$excludeLine = ""
	if ($excludes -ne $null){
        foreach ($x in $excludes){
		    write-host "Excluding: $x.*"	     
		    $excludeLine = "$excludeLine-exclude:$x.* "
	  }
	}
    $cmd = "C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe"
    write-host "Executing $cmd /coverage $excludeLine $assy" 
	& $cmd /coverage "$excludeLine" "$assy" 
}

#------------------------------------------------------------------------------
# Instruments an assembly for code coverage, excluding the specified namespaces
#------------------------------------------------------------------------------
function instrument([string]$assemblyName, [string[]]$excludes){
	$assy = "$websiteBinDirectory\$assemblyName"

	#ES - this doesn't work as the ":" in exlucde gets parsed out by PS:
	#$excludeParms = ""
	#$args
	#foreach($exclude in $args){
	#	$excludeParms = $excludeParms + '/exclude:' + $exclude + '.* '
	#}
	#$excludeParms
	#& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $excludeParms $assy 

	if ($excludes -eq $null){
		write-host "Excluding 0 funcspecs"
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $assy 
	}
	elseif ($excludes.Length -eq 0){
		write-host "Excluding 0 funcspecs"
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $assy 
	}
	elseif ($excludes.Length -eq 1){
		write-host "Excluding 1 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0] 
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $assy 
	}
	elseif ($excludes.Length -eq 2){
		write-host "Excluding 2 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0]
		$exclude2 = '-exclude:' + $excludes[1]
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $exclude2  $assy 
	}
	elseif ($excludes.Length -eq 3){
		write-host "Excluding 3 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0]
		$exclude2 = '-exclude:' + $excludes[1]
		$exclude3 = '-exclude:' + $excludes[2]
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $exclude2 $exclude3 $assy 
	}
	elseif ($excludes.Length -eq 4){
		write-host "Excluding 4 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0]
		$exclude2 = '-exclude:' + $excludes[1]
		$exclude3 = '-exclude:' + $excludes[2]
		$exclude4 = '-exclude:' + $excludes[3]
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $exclude2 $exclude3 $exclude4 $assy 
	}
	elseif ($excludes.Length -eq 5){
		write-host "Excluding 5 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0]
		$exclude2 = '-exclude:' + $excludes[1]
		$exclude3 = '-exclude:' + $excludes[2]
		$exclude4 = '-exclude:' + $excludes[3]
		$exclude5 = '-exclude:' + $excludes[4]		
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $exclude2 $exclude3 $exclude4 $exclude5 $assy 
	}	
	elseif ($excludes.Length -eq 6){
		write-host "Excluding 6 funcspecs"
		$exclude1 = '-exclude:' + $excludes[0]
		$exclude2 = '-exclude:' + $excludes[1]
		$exclude3 = '-exclude:' + $excludes[2]
		$exclude4 = '-exclude:' + $excludes[3]
		$exclude5 = '-exclude:' + $excludes[4]		
		$exclude6 = '-exclude:' + $excludes[5]		
		& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsinstr.exe' /coverage $exclude1 $exclude2 $exclude3 $exclude4 $exclude5 $exclude6 $assy 
	}
}

#-----------------------------------
# Starts instrumenting W3WP app pool
#------------------------------------
function start-instrumentation{
	#set instrumentation on:
	&  'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfclrenv' /globaltraceon 

	#restart the app pool and store the ID:
	kill-apppool
	start-apppool
	$procId = get-apppoolpid

	#start instrumenting:
	& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfcmd' /START:COVERAGE /OUTPUT:$coverageOutputPath /CS /USER:$appPoolIdentity
	& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfcmd' /ATTACH:$procId
	& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfcmd' /status
}

#--------------------
# Stops instrumenting
#--------------------
function stop-instrumentation{
	#stop instrumenting & reset app pool:
	& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfcmd' /DETACH
	kill-apppool
	& 'C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools\vsperfcmd' /SHUTDOWN 
}

#------------------------
# Exports coverage to XML
#------------------------
function export-coverage{
	#export the coverage file to XML:
	[System.Reflection.Assembly]::LoadFile("C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\PrivateAssemblies\Microsoft.VisualStudio.Coverage.Analysis.dll")
	$coverage = [Microsoft.VisualStudio.Coverage.Analysis.CoverageInfo]::CreateFromFile("$coverageOutputPath")
	$dataSet = $coverage.BuildDataSet()
	$dataSet.WriteXml("$coverageOutputPath" + 'xml')
}

#----------------------------------------------------------------------------------
# Deletes instrumented assemblies, and reinstates original un-instrumented versions
#----------------------------------------------------------------------------------
function delete-intstrumentedassemblies{
	$dir = new-object IO.DirectoryInfo($websiteBinDirectory)
	$originalAssemblies = $dir.GetFiles("*.dll.orig")
	foreach ($originalAssembly in $originalAssemblies){
		$targetName = $originalAssembly.FullName.TrimEnd(".orig".ToCharArray())
		#overwrite the instrumented DLL with the original:
		[IO.File]::Copy($originalAssembly.FullName, $targetName, $true)
		[IO.File]::Delete($originalAssembly.FullName)
		#delete the instrumented PDB:
		$instrumentedPdbName = $originalAssembly.FullName.TrimEnd(".dll.orig".ToCharArray()) + ".instr.pdb"
		[IO.File]::Delete($instrumentedPdbName)
	}
}

#--------------
# Script begins
#--------------

#set variables:
$solutionFriendlyName = 'XYZ'
$wakeUpServiceUrl = 'http://localhost/x.y.z/Service.svc'
$appPoolName = 'ap_XYZ'
$appPoolIdentity = 'domain\svc_user'
$websiteBinDirectory = 'c:\websites\xyz\x.y.z.Services\bin'
$coverageOutputPath = "Test.coverage"

#instrument assemblies:
# - instrument assembly so ALL namespaces are included in coverage
instrument   "x.y.z.Services.dll"  
# - instrument assembly so anything from the Ignore1 and Ignore2 namespaces are excluded from coverage
instrument   "x.y.z.Core.dll"   'x.y.z.Core.Ignore1.*' , 'x.y.z.Core.Ignore2.*'  

write-host "Before starting instrumentation, last exit code: $LASTEXITCODE"

#instrument W3WP, run tests & export results:
start-instrumentation

write-host "Before running tests, last exit code: $LASTEXITCODE"
& 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe' Build.proj /t:$msBuildTarget /p:ConfigurationName=$configurationName

$realExitCode = $LASTEXITCODE

write-host "Before stopping instrumentation, last exit code: $LASTEXITCODE, real exit code: $realExitCode"
stop-instrumentation
export-coverage
export-coverage

if ($deleteInstrumentedAssemblies -eq $true){
	delete-intstrumentedassemblies
}

write-host "Before existing, last exit code: $LASTEXITCODE, real exit code: $realExitCode"
exit $realExitCode

#------------
# Script ends
#------------

