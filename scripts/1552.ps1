#Params is file or folder
param([string] $PSUnitTestFile, [string] $Category ="All", [switch] $ShowReportInBrowser)

Write-Debug "PSUnit.Run.ps1: Parameter `$PSUnitTestFile=`"$PSUnitTestFile`""
Write-Debug "PSUnit.Run.ps1: Parameter `$Category=`"$Category`""

#Don't run the script with an empty path to test file
if ([String]::IsNullOrEmpty($PSUnitTestFile))
{
    Throw "The `$PSUnitTestFile parameter is required!"
}

#Make sure the test file exists
if( ! (Test-Path -Path $PSUnitTestFile) )
{
    Throw "`$PSUnitTestFile: $PSUnitTestFile is not a valid file!"
}

#This is there to prevent this script from running itself as a test
$PSUnitTestFileInfo = Get-Item -Path $PSUnitTestFile
if ($PSUnitTestFileInfo.Name -eq "PSUnit.Run.ps1")
{
    Throw "This script can't run itself as a test!"
}



#Data Model for the test result report
$TestEnvironment = @{}
$TestStatistics = @{}
$TestResults = New-Object -TypeName "System.Collections.ArrayList"
$Statistics = @{}
$TestStartTime = [DateTime]::Now
$TestEndTime = [DateTime]::Now

#Deleting test functions from global scope
$TestFunctions = Get-Item function:Test.*
If ($TestFunctions)
{
  Write-Debug "PSUnit.Run.ps1: Deleting test functions from global scope!"
  $TestFunctions | Remove-Item
}

#Loading test functions into global scope
$ScriptLines = Get-Content -Path $PSUnitTestFile -Encoding "UTF8"
$ScriptText = [String]::Join("`n`r", $ScriptLines)
Invoke-Expression $ScriptText 

#Make sure that the $PSTestScript has tests defined
if (! (Test-Path -Path function:Test.*))
{
    Throw "Script `"$PSUnitTestFile`" doesn't have any test functions defined!"
}

#Get all Test. functions. This will get every function in global scope, even the ones that we didn't explicitly load
$TestFunctions = Get-Item function:Test.*

function Execute-Test([System.Management.Automation.FunctionInfo] $Test)
{
  Try
  {
    Write-Debug "Execute-Test: Executing: $($Test.Name)"
    & $Test
  }
  Catch
  {
    Write-Debug "Execute-Test: Caught exception: $($_.Exception.GetType().FullName)"
    Throw $_ 
  }
}

function Report-TestResult([System.Management.Automation.FunctionInfo] $Test, [string] $Result, [System.Management.Automation.ErrorRecord] $Reason)
{
    #Creating test results object collection
    $TestResult = New-Object -TypeName "System.Management.Automation.PSObject"
    $TestResult = Add-Member -passthru -InputObject $TestResult -MemberType NoteProperty -Name "Test" -Value $Test
    $TestResult = Add-Member -passthru -InputObject $TestResult -MemberType NoteProperty -Name "Result" -Value $Result
    $TestResult = Add-Member -passthru -InputObject $TestResult -MemberType NoteProperty -Name "Reason" -Value $Reason
    $null = $TestResults.Add($TestResult);
  
    #Writing Console output
    if($Test.Name.Length -ge 99)
    {
        $TestNameString = $Test.Name.Substring(0, 95) + "..."
    }
    else
    {
        $TestNameString = $Test.Name
    }
    
    switch ($Result)
    {
        "PASS" 
        {
            Write-Host "$($TestNameString.PadRight(100, ' '))" -foregroundcolor "blue" -backgroundcolor "white" -nonewline
            Write-Host "PASS" -foregroundcolor "black" -backgroundcolor "green" -nonewline
            Write-Host $("  N/A".PadRight(100, ' ')) -foregroundcolor "blue" -backgroundcolor "white"
        }
        "FAIL"
        {
            if($Reason.ToString().Length -ge 99)
            {
                $ReasonString = $Reason.ToString().Substring(0, 95) + "..."
            }
            else
            {
                $ReasonString = $Reason.ToString()
            }
            Write-Host "$($TestNameString.PadRight(100, ' '))" -foregroundcolor "blue" -backgroundcolor "white" -nonewline
            Write-Host "FAIL" -foregroundcolor "white" -backgroundcolor "red" -nonewline
            Write-Host $("  $ReasonString".PadRight(100, ' ')) -foregroundcolor "red" -backgroundcolor "white"
        }
        "SKIP"
        {
            Write-Host "$($TestNameString.PadRight(100, ' '))" -foregroundcolor "blue" -backgroundcolor "white" -nonewline
            Write-Host "SKIP" -foregroundcolor "black" -backgroundcolor "yellow" -nonewline
            Write-Host $("  N/A".PadRight(100, ' ')) -foregroundcolor "blue" -backgroundcolor "white"
        }
    }
}

function Get-ExpectedExceptionTypeName([System.Management.Automation.FunctionInfo] $Test)
{    
    $ExpectedExceptionTypeName = "ExpectedException Parameter is not defined in function $($Test.Name)"
    $ExpectedExceptionParameter = $Test.Parameters["ExpectedException"]
    if( $ExpectedExceptionParameter -ne $Null)
    {
      $ExpectedExceptionTypeName = $ExpectedExceptionParameter.ParameterType.FullName
    }
    else
    {
      Write-Debug "Get-ExpectedExceptionTypeName: $($Test.Name) doesn't use ExpectedException parameter"
    }
    return $ExpectedExceptionTypeName
}

function Get-TestFunctionCategory([System.Management.Automation.FunctionInfo] $Test)
{    
    $TestFunctionCategory = "All"
    $Test.Parameters.GetEnumerator() | ForEach-Object `
    { 
        if($_.Key -match '^Category_(?<CATEGORY>.*)$') 
        {   
            $TestFunctionCategory = $Matches["CATEGORY"]
        }
    }
    Write-Debug "Get-TestFunctionCategory: Found Category=`"$TestFunctionCategory`""
    return $TestFunctionCategory
}

function Get-TestFunctionSkip([System.Management.Automation.FunctionInfo] $Test)
{    
    $IsSkipSet = $false
    $SkipParameter = $Test.Parameters["Skip"]
    if( $SkipParameter -ne $Null)
    {
      $IsSkipSet = $true
      Write-Debug "Get-TestFunctionSkip: $($Test.Name) uses Skip parameter"

    }
    else
    {
      Write-Debug "Get-TestFunctionSkip: $($Test.Name) doesn't use Skip parameter"
    }
    return $IsSkipSet
}

if ($TestFunctions -eq $Null)
{
    Write-Error "No function that starts with test.* was found in function: drive. Make sure that $PSUnitTestFile is in the correct path."
}
else
{
  $TestStartTime = [DateTime]::Now
  
  #Execute each function
  $TestFunctions | ForEach-Object `
  { 
    $CurrentFunction = $_
    $ExpectedExceptionTypeName = Get-ExpectedExceptionTypeName -Test $CurrentFunction
    $TestFunctionCategory = Get-TestFunctionCategory -Test $CurrentFunction
    $TestFunctionSkip = Get-TestFunctionSkip -Test $CurrentFunction
    
    if ($TestFunctionSkip)
    {
        Report-TestResult -Test $CurrentFunction -Result "SKIP"
        return
    }
    
    if (($TestFunctionCategory -ne $Category) -and ($Category -ne "All"))
    {
        Write-Debug "PSUnit.Run.ps1: Not running `"$($CurrentFunction.Name)`". Its category is `"$TestFunctionCategory`", but the required category is `"$Category`""
        return
    }

    Try
    {
      $FunctionOutput = Execute-Test $_
      Report-TestResult -Test $CurrentFunction -Result "PASS"
    }
    Catch
    {            
      $ActualExceptionTypeName = $_.Exception.GetType().FullName
      Write-Debug "PSUnit.Run.ps1: Execution of `"$CurrentFunction`" caused following Exception `"$($_.Exception.GetType().FullName)`""
      Write-Debug "PSUnit.Run.ps1: ExpectedException = `"$ExpectedExceptionTypeName`""
      
      if ($ActualExceptionTypeName -eq $ExpectedExceptionTypeName)
      {
        Report-TestResult -Test $CurrentFunction -Result "PASS"
      }
      else
      {
        Report-TestResult -Test $CurrentFunction -Result "FAIL" -Reason $_
      }
    }
  }
  $TestEndTime = [DateTime]::Now
}


function Get-TestResultStatistics([System.Collections.ArrayList] $Results)
{
    $Stats = @{}
    $Stats["Total"] =0
    $Stats["Passed"] = 0
    $Stats["Failed"] = 0
    $Stats["Skipped"] = 0
    
    if(!$Results -or $Results.Count -eq 0)
    {
        return $Stats
    }
    
    $Stats["Total"] = $Results.Count
    
    $Results | Foreach-Object `
    {
        switch ( $_.Result )
        {
            "PASS" {$Stats["Passed"]++} 
            "FAIL" {$Stats["Failed"]++}
            "SKIP" {$Stats["Skipped"]++}
        }
    }
    return $Stats
}

function Get-TestReportFileName([System.Collections.HashTable] $EnvironmentData, [System.Collections.HashTable] $Stats )
{
    $StatsTotal = 0
    $StatsPassed = 0
    $StatsFailed = 0
    $StatsSkipped = 0
    If($Stats.Total) {$StatsTotal = $Stats.Total}
    If($Stats.Passed) {$StatsPassed = $Stats.Passed}
    If($Stats.Failed) {$StatsFailed = $Stats.Failed}
    If($Stats.Skipped) {$StatsSkipped = $Stats.Skipped}

    $StatsFileNamePart = "T{0}P{1}F{2}S{3}" -f $StatsTotal, $StatsPassed, $StatsFailed, $StatsSkipped
    
    $StartDateString = $EnvironmentData.StartTime.ToString("yyyy-MM-dd-HH-mm-ss")
    $TestFile = dir $($EnvironmentData.TestFilename)
    $FileName = $TestFile.Name
    $TestReportFileName = "PSUnitTestReport_{0}_{1}_{2}.html" -f $FileName, $StartDateString, $StatsFileNamePart
    Write-Debug "Get-TestReportFileName: `$TestReportFileName = $TestReportFileName"

    return $TestReportFileName
}

function Get-TestReportTitleAsHtml([System.Collections.HashTable] $EnvironmentData)
{
    $TestReportTitle = "PSUnit Test Report - {0} - {1}" -f $EnvironmentData.TestFilename, $EnvironmentData.StartTime
    $TestReportTitle = Encode-Html -StringToEncode $TestReportTitle
    return $TestReportTitle
}

function Compile-TestResultReport()
{
    $TestFile = dir $PSUnitTestFile
    $TestEnvironment["TestFileName"] = $TestFile.FullName
    $TestEnvironment["SourceCodeRevision"] = "Not yet implemeted!"
    $TestEnvironment["Category"] = $Category
    $TestEnvironment["StartTime"] = $TestEndTime
    $TestEnvironment["EndTime"] = $TestEndTime
    $TestEnvironment["Duration"] = ($TestEnvironment.EndTime - $TestEnvironment.StartTime).TotalSeconds
    $TestEnvironment["UserName"] = $env:username
    $TestEnvironment["MachineName"] = $env:computername
    $TestEnvironment["PowerShellVersion"] = $host.version.ToString()
    $OSProperties = get-wmiobject -class "Win32_OperatingSystem" -namespace "root\CIMV2" -computername $env:computername
    $OperatingSystem = "{0} {1} Build {2}" -f $OSProperties.Caption, $OSProperties.CSDVersion, $OSProperties.BuildNumber
    $TestEnvironment["OperatingSystem"] = $OperatingSystem 
    
    
    
    $Statistics = Get-TestResultStatistics -Results $TestResults
    
    $TestReportFileName = Get-TestReportFileName -EnvironmentData $TestEnvironment -Stats $Statistics
    $TestEnvironment["TestReportFileName"] = $TestReportFileName
    
    $TestReportTitle = Get-TestReportTitleAsHtml -EnvironmentData $TestEnvironment
    $TestEnvironment["TestReportTitle"] = $TestReportTitle
    
    $ReportHtml = Render-TestResultReport -Results $TestResults -HeaderData $TestEnvironment -Statistics $Statistics
            
    #Get PSUNIT_HOME folder
    $PSUnitHome = dir env:PSUNIT_HOME
    Write-Debug "PSUNIT_HOME: $PSUnitHome"
    
    $TestReportFile = Join-Path -Path $($PSUnitHome.Value) -ChildPath $TestReportFileName
    
    #Save report as file in PSUnit Home folder
    $ReportHtml > $TestReportFile
    
    if ($ShowReportInBrowser)
    {#Open Report File
        & ($TestReportFile)
    }
}

Compile-TestResultReport

