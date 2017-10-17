#< #
#.Synopsis
@@#   Create a class instance and/or invoke a method on C# source code.
@@#   For details, see:
@@#   http://vincenth.net/blog/archive/2009/10/27/call-inline-c-from-powershell-with-invokecsharp.aspx 
#.Description
#   This function compiles the provided C# source code (only if necessary, compiled
#   assemblies are cached). The code can be supplied either inline in a string or
#   in a source file. Relative source filename paths are interpreted
#   relative to the parent folder of the calling script.
#   This enables simple organization and reference of related .ps1 and .cs files.
#
#   If a method name is specified, that method is invoked with any supplied
#   parameters and the function then returns the result of the method.
#   Both static and nonstatic methods are supported, including overloaded
#   methods.
#
#   If no method name is specified, an instance of the specified class is
#   created, passing any supplied parameters to the class constructor, and the
#   function then returns the class instance. You can then program against the
#   class instance in standard PowerShell fashion.
#
#   If necessary for compilation, you can specify names of any referenced
#   assemblies.
#.Parameter code
#   The complete C# source code - effectively this is an inline C# source file.
#   Note that it is possible but not necessary to declare classes within a
#   namespace.
#   Either the code parameter or the file parameter must be specified.
#.Parameter file
#   Absolute or relative path to a C# source file. Relative paths (beginning
#   with '.\' or '..\') are interpreted relative to the folder that contains
#   the calling script (i.e. the script that calls this function).
#   Either the code parameter or the file parameter must be specified.
#.Parameter class
#   The name of the class to be instantiated / that contains the method to
#   be invoked. Include the namespace in which the class is declared, if any.
#   If you specify the -file parameter and the class name is identical to the
#   file name, you can omit the -class parameter.
#.Parameter method
#   Either the name of the method to be invoked, '()' to invoke a 
#   constructor to create and resturn a class instance, or '' to return
#   the cached assembly. The last option allows you to precompile assemblies
#   without calling a method or creating a class instance.
#    
#   If the specified method is not static, an instance of the class will
#   be created on the fly.
#.Parameter parameters
#   To pass parameters to the constructor or method, specify them as an
#   array of objects (e.g. with the comma operator or @() ).
#.Parameter reference
#   If necessary, specify an array of assembly filenames to be added as
#   assembly references when the source code is compiled.
#.Parameter forceCompile
#   Specify this switch to force recompilation. This is useful if you specify
#   the file parameter and the file contents has changed (when specifying a
#   source file name, the cache key is the file name only - changes to the file
#   do not automatically cause cache invalidation).
#.Returns
#   Either the cached assembly, a class instance or a method result (depending 
#   on the value specified for the method parameter).
#.Example
#   # Create a class instance from a .cs file, passing a parameter to the class constructor:
#   # Note that the class name can be omitted here, since it is implied from the .cs file name
#   $myClassInstance = InvokeCSharp -file '.\MyClass.cs' -parameters 'A text'
#    
#   # Call some simple inline code. Note that you could also wrap the code in a namespace, 
#   # add using statements and reference other assemblies.
#   $code = @"
#       public class MyClass2
#       {
#           public static int MyStaticMethod(int a, int b)
#           {
#               return a * b;
#           }
#       }
#   "@
#   $result = InvokeCSharp -code $code -class 'MyClass2' -method 'MyStaticMethod' -parameters 3, 7 # Will return 21
##>
function global:InvokeCSharp
{
    param(
        [string] $code = '',
        [string] $file = '',
        [string] $class = '',
        [string] $method = '()',
        [Object[]] $parameters = $null,
        [string[]] $reference = @(),
        [switch] $forceCompile
    )
 
    # Stores a cache of generated assemblies. If this library is dot-sourced 
    # from a script, these objects go away when the script exits. 
    if(-not (Test-Path Variable:\macaw.solutionsfactory.assemblycache))
    {
        ${GLOBAL:macaw.solutionsfactory.assemblycache} = @{}
    }
 
    if (($code -eq '') -and ($file -eq '')) { throw 'Neither code nor file are specified. Specify either one or the other.' }
 
    # If a source file was specified, see if it was already loaded, compiled and cached:
    if ($file -ne '')
    {
        if ($code -ne '') { throw 'Both code and file are specified. Specify either one or the other.' }
 
        # We interpret the current directory as the directory containing the calling script, instead of the currect directory of the current process.
        if ($file.StartsWith('.'))
        {
            $callingScriptFolder = Split-Path -path ((Get-Variable MyInvocation -Scope 1).Value).MyCommand.Path -Parent
            $file = Join-Path -Path $callingScriptFolder -ChildPath $file
        }
 
        # If no class name is  specified, we assume by convention that the file name is equal to the class name.
        if ($class -eq '') { $class = [System.IO.Path]::GetFileNameWithoutExtension($file) }
 
        # Use the real full path as the cache key:
        $file = [System.IO.Path]::GetFullPath((Convert-Path -path $file))
        $cacheKey = $file
    }
    else
    {
        # See if the code has already been compiled and cached 
        $cacheKey = $code
    }
    if ($class -eq '') { throw 'Required parameter missing: class' }
 
    # See if the code must be (re)compiled:
    $cachedAssembly = ${macaw.solutionsfactory.assemblycache}[$cacheKey]
    if(($cachedAssembly -eq $null) -or $forceCompile)
    {
        if ($code -eq '') { $code = [System.IO.File]::ReadAllText($file) }
        Write-Verbose "Compiling C# code:`r`n$code`r`n"
 
        # Obtains an ICodeCompiler from a CodeDomProvider class. 
        $provider = New-Object Microsoft.CSharp.CSharpCodeProvider 
 
        # Get the location for System.Management.Automation DLL 
        $dllName = [PsObject].Assembly.Location
 
        # Configure the compiler parameters 
        $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters 
 
        $assemblies = @("System.dll", $dllName) 
        $compilerParameters.ReferencedAssemblies.AddRange($assemblies) 
        $compilerParameters.ReferencedAssemblies.AddRange($reference)
        $compilerParameters.IncludeDebugInformation = $true 
        $compilerParameters.GenerateInMemory = $true 
 
        # Invokes compilation.  
        $compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $code)
 
        # Write any errors if generated.         
        if($compilerResults.Errors.Count -gt 0) 
        { 
            $errorLines = "" 
            foreach($error in $compilerResults.Errors) 
            { 
                $errorLines += "`n`t" + $error.Line + ":`t" + $error.ErrorText 
            } 
            Write-Error $errorLines 
        } 
        # There were no errors.  Store the resulting assembly in the cache. 
        else 
        {
            ${macaw.solutionsfactory.assemblycache}[$cacheKey] = $compilerResults.CompiledAssembly 
        }
 
        $cachedAssembly = ${macaw.solutionsfactory.assemblycache}[$cacheKey]
    }
 
    # Prevent type mismatch issues caused by PowerShell wrapping of managed objects in PSObject.
    # We need to explicitly unwrap those objects because otherwise the .NET reflection classes will
    # not find the constructor or method whose signature matches the specified parameters.
    # This unwrapping eliminates the need to always wrap all your parameters in @() and to explicitly
    # cast each parameter to the correct type in each call to InvokeCSharp.
    if ($parameters -ne $null)
    {
        for($i = 0; $i -lt $parameters.Length; $i++) 
        {
            $parameters[$i] = [System.Management.Automation.LanguagePrimitives]::ConvertTo( `
                $parameters[$i], `
                [System.Type]::GetType($parameters[$i].GetType().FullName) `
            )
        }
    }
 
    if ($method -eq '') # We return the assembly
    {
        $result = $cachedAssembly
    }
    elseif ($method -eq '()') # We create and return a class instance
    {
        $result = $cachedAssembly.CreateInstance($class, $false, [System.Reflection.BindingFlags]::CreateInstance, $null, $parameters, $null, @())
    }
    else # We invoke the method and return the method result
    {
        $classType = $cachedAssembly.GetType($class)
 
        $parameterTypes = @()
        if ($parameters -ne $null) { foreach($p in $parameters) { $parameterTypes += $p.GetType() } }
 
        $methodInfo = $classType.GetMethod($method, [System.Type[]]$parameterTypes)
        if ($methodInfo.IsStatic)
        { 
            $instance = $null
        }
        else
        {
            $instance = $cachedAssembly.CreateInstance($class, $false, [System.Reflection.BindingFlags]::CreateInstance, $null, $null, $null, @())
        }
        $result = $methodInfo.Invoke($instance, $parameters);
    }
 
   return $result
}
