## New-Type (like Add-Type, but for PowerShell 1.0)
## Takes C# source code, and compiles it (in memory) for use in scripts ...
####################################################################################################
## USAGE EXAMPLE:
##    New-Type @"
##    using System;
##    public struct User {
##       public string Name;
##       public int Age;
##       public User(string name, int age) {
##          Name = name; Age = age;
##       }
##    }
##    "@
##    
##    $user = New-Object User "Bobby",28
##    $user.Name
####################################################################################################
## NOTE: Save as New-Type.ps1 in your path, or uncomment the function line below (and the last line)
####################################################################################################
#function New-Type {
   param([string]$TypeDefinition,[string[]]$ReferencedAssemblies)
   
   ## Obtains an ICodeCompiler from a CodeDomProvider class.
   $provider = New-Object Microsoft.CSharp.CSharpCodeProvider
   ## Get the location for System.Management.Automation DLL
   $dllName = [PsObject].Assembly.Location
   ## Configure the compiler parameters
   $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters

   $assemblies = @("System.dll", $dllName)
   $compilerParameters.ReferencedAssemblies.AddRange($assemblies)
   if($ReferencedAssemblies) { 
      $compilerParameters.ReferencedAssemblies.AddRange($ReferencedAssemblies) 
   }

   $compilerParameters.IncludeDebugInformation = $true
   $compilerParameters.GenerateInMemory = $true

   $compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $TypeDefinition)
   if($compilerResults.Errors.Count -gt 0) {
     $compilerResults.Errors | % { Write-Error ("{0}:`t{1}" -f $_.Line,$_.ErrorText) }
   }
#}

