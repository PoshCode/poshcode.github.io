#Requires -Version 2.0

function Open-ISEFile {
<#
    .NOTES
        Name: Open-ISEFile
        Author: Tome Tanasovski
        Created: 6/20/2010
        Version: 1.0
        
    .SYNOPSIS
        Open a new file in ISE

    .DESCRIPTION
        This cmdlet allows you to open a file in a new file tab within your current Powershell tab.  You can pass a collection of files to open more than one file.

    .PARAMETER  Path
        Specifies a path to one or more files.  Wildcards are permitted.  The default location is the current directory (.).

    .EXAMPLE
        Open-ISEFile -Path $profile
        
        Opens your profile in ISE.
    
    .EXAMPLE
        dir *.ps1 |Open-ISEFile
        
        Opens up all ps1 files in the current directory as new file tabs in ISE.
        
    .EXAMPLE
        Open-ISEFile *.ps1
        
        Opens up all ps1 files in the current directory as new file tabs in ISE.    
        
    .EXAMPLE
        $file = Open-ISEFile "c:\file1.ps1" -PassThru
        
        Opens up file1.ps1 in ISE.  The command uses the passthru parameter to generate an object that represents a file in ISE.

    .INPUTS
        System.String

    .OUTPUTS
        None or Microsoft.PowerShell.Host.ISE.ISEFile
        
        When you use the PassThru parameter, Open-ISEFile returns a Microsoft.PowerShell.Host.ISE.ISEFile for each file opened.  Otherwise, this cmdlet does not generate any output.

    .LINK
        http://powertoe.wordpress.com
#>
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
        [string[]] $Path,
        [Parameter(Mandatory = $false)]
        [switch] $PassThru
    )
    BEGIN {
        if (!$psise) {            
            "You are not in a Powershell ISE window"
        }
    }
    PROCESS {
        if ($psise) {
            foreach ($file in $Path) {
                if (Test-Path $file) {
                    Get-ChildItem $file | foreach {
                        $file = $psise.CurrentPowerShellTab.Files.Add($_.fullname)
                        if ($PassThru) {
                            $file
                        }
                    }
                }
            }
        }
    }
}
