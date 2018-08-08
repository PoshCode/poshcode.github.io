function Require-Function
{
  <# 
.SYNOPSIS 
    Load function when not already loaded    
.DESCRIPTION 
    When a function is not loaded and there is a file <functionname>.ps1 in one of the directories listed
    in $env:Path it is dot sourced.
    To get the function in your environment you must dot source the Require-Function too.
.NOTES 
    File Name  : Require-Function.ps1 
    Author     : Bernd Kriszio - http://pauerschell.blogspot.com/ 
.PARAMETER FunctionName
    The name of the function you want to import
.EXAMPLE 
    . Require-Function <any_function_script_in_your_path>
.EXAMPLE 
    . Require-Function New-ISEFile -verbose
.EXAMPLE 
    . Require-Function New-ISEFile
.EXAMPLE 
   . Require-Function unbekanntn -verbose
#> 
   [cmdletbinding()]
   param (
    [string] $FunctionName
    )
    
    if (! (Test-Path function:$FunctionName))
    {
        try{
            Write-Verbose "Function $FunctionName not loaded"
            $cmd = "$($FunctionName).ps1"
            #"$cmd" 
            .  $cmd
        }
        catch
        {
            "$cmd could not be loaded"
            break;
        }
        Write-Verbose "Function $FunctionName is loaded"
    }
    else
    {
        Write-Verbose "Function $FunctionName was loaded"
    }
}

