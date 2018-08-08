# .SYNOPSIS
# Import environment variables from cmd to PowerShell
# .DESCRIPTION
# Invoke the specified command (with parameters) in cmd.exe, and import any environment variable changes back to PowerShell
# .EXAMPLE
# Import-CmdEnvironment Import-CmdEnvironment ${Env:VS90COMNTOOLS}\vsvars32.bat x86
#
# Imports the x86 Visual Studio 2008 Command Tools environment
# .EXAMPLE
# Import-CmdEnvironment Import-CmdEnvironment ${Env:VS100COMNTOOLS}\vsvars32.bat x86_amd64
# 
# Imports the x64 Cross Tools Visual Studio 2010 Command environment

#function Import-CmdEnvironment {
[CmdletBinding()]
param(
   [Parameter(Position=0,Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias("PSPath")]
   [string]$Command = "echo"
,
   [Parameter(Position=0,Mandatory=$False,ValueFromRemainingArguments=$true,ValueFromPipelineByPropertyName=$true)]
   [string[]]$Parameters
)
   ## If it's an actual file, then we should quote it:
	if(Test-Path $Command) { $Command = "`"$(Resolve-Path $Command)`"" }
   $setRE = new-Object System.Text.RegularExpressions.Regex '^(?<var>.*?)=(?<val>.*)$', "Compiled,ExplicitCapture,MultiLine"
   $OFS = " "
   [string]$Parameters = $Parameters
   $OFS = "`n"
	## Execute the command, with parameters.
   Write-Verbose "EXECUTING: cmd.exe /c `"$Command $Parameters > nul && set`""
	## For each line of output that matches, set the local environment variable
	foreach($match in  $setRE.Matches((cmd.exe /c "$Command $Parameters > nul && set")) | Select Groups) {
      Set-Content Env:\$($match.Groups["var"]) $match.Groups["val"] -Verbose
	}
#}
