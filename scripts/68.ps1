################################################################################ 
## Invoke-Inline.ps1 (originally from Lee Holmes)
## Library support for inline C# 
## 
## Modified by Joel Bennett to accept include statements, and return collections
##
## Usage 
##  1) Define just the body of a C# method, and store it in a string.  "Here 
##     strings" work great for this.  The code can be simple: 
## 
##     $codeToRun = "Console.WriteLine(Math.Sqrt(337));" 
## 
##     or more complex, using result.Add(): 
## 
##     $codeToRun = @" 
##         string firstArg = (string) ((System.Collections.ArrayList) arg)[0]; 
##         int secondArg = (int) ((System.Collections.ArrayList) arg)[1]; 
## 
##         Console.WriteLine("Hello {0} {1}", firstArg, secondArg ); 
##      
##         result.Add(secondArg * 3); 
##     "@ 
## 
##  2) If you must pass arguments, you should make them strongly-typed, 
##	   so that PowerShell doesn't wrap it as a PsObject. 
## 
##  3) Invoke the inline code, optionally retrieving the return value.  You can 
##     set the return values in your inline code by assigning it to the 
##     "return" collection as shown above. 
## 
##     $result = Invoke-Inline $usingStatements, $codeToRun $arguments 
##     $result = Invoke-Inline  $codeToRun $arguments 
## 
## 
##     If your code is simple enough, you can even do this entirely inline: 
## 
##     Invoke-Inline "Console.WriteLine(Math.Pow(337,2));" 
##   
################################################################################ 
param(
    [string[]] $code, 
    [object[]] $arguments,
    [string[]] $reference = @()
    )

## Stores a cache of generated inline objects.  If this library is dot-sourced 
## from a script, these objects go away when the script exits. 
if(-not (Test-Path Variable:\inlineCode.Cache))
{
    ${GLOBAL:inlineCode.Cache} = @{}
}

$using = $null;
$source = $null;
if($code.length -eq 1) {
	$source = $code[0]
} elseif($code.Length -eq 2){
	$using = $code[0]
	$source = $code[1]
} else {
	Write-Error "You have to pass some code, or this won't do anything ..."
}

## un-nesting magic (why do I need this?)
$params = @()
foreach($arg in $arguments) { $params += $arg }
$arguments = $params

## The main function to execute inline C#.   
## Pass the argument to the function as a strongly-typed variable.  They will  
## be available from C# code as the Object variable, "arg". 
## Any values assigned to the "returnValue" object by the C# code will be  
## returned to MSH as a return value. 

function main
{
    ## See if the code has already been compiled and cached 
    $cachedObject = ${inlineCode.Cache}[$source] 
	Write-Verbose "Type: $($arguments[0].GetType())"

    ## The code has not been compiled or cached 
    if($cachedObject -eq $null)
    {
        $codeToCompile = 
@"
    using System;
	using System.Collections.Generic;
	$using

    public class InlineRunner 
    { 
        public List<object> Invoke(Object[] args) 
        { 
            List<object> result = new List<object>(); 

            $source 

            if( result.Count > 0 ) {
				return result;
			} else {
				return null;
			}
        } 
    } 
"@
		Write-Verbose $codeToCompile

        ## Obtains an ICodeCompiler from a CodeDomProvider class. 
        $provider = New-Object Microsoft.CSharp.CSharpCodeProvider 

        ## Get the location for System.Management.Automation DLL 
        $dllName = [PsObject].Assembly.Location

        ## Configure the compiler parameters 
        $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters 

        $assemblies = @("System.dll", $dllName) 
        $compilerParameters.ReferencedAssemblies.AddRange($assemblies) 
        $compilerParameters.ReferencedAssemblies.AddRange($reference)
        $compilerParameters.IncludeDebugInformation = $true 
        $compilerParameters.GenerateInMemory = $true 

        ## Invokes compilation.  
        $compilerResults =
            $provider.CompileAssemblyFromSource($compilerParameters, $codeToCompile) 

        ## Write any errors if generated.         
        if($compilerResults.Errors.Count -gt 0) 
        { 
            $errorLines = "" 
            foreach($error in $compilerResults.Errors) 
            { 
                $errorLines += "`n`t" + $error.Line + ":`t" + $error.ErrorText 
            } 
            Write-Error $errorLines 
        } 
        ## There were no errors.  Store the resulting object in the object 
        ## cache. 
        else 
        { 
            ${inlineCode.Cache}[$source] = 
                $compilerResults.CompiledAssembly.CreateInstance("InlineRunner") 
        } 

        $cachedObject = ${inlineCode.Cache}[$source] 
   } 

   Write-Verbose "Argument $arguments`n`n$cachedObject"
   ## Finally invoke the C# code 
   if($cachedObject -ne $null)
   { 
       return $cachedObject.Invoke($arguments)
   } 
}
. Main
