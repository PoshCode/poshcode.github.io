function New-Module {
   #.Synopsis
   #  Generate a new module from some script files
   #.Description
   #  New-Module serves two ways of creating modules, but in either case, it can generate the psd1 and psm1 necessary for a module based on script files.
   #
   #  In one use case, it's just a simplified wrapper for New-ModuleManifest which answers some of the parameters based on the files already in the module folder.
   #
   #  In the second use case, it allows you to collect one or more scripts and put them into a new module folder.
   #.Example
   #  Get-ChildItem *.ps1 | New-Module MyUtility
   #
   #  This example shows how to collect all the script files in the folder and generate a new module "MyUtility" with the default values for everything.
   #.Example
   #  New-Module ~\Documents\WindowsPowerShell\Modules\MyUtility -Force
   #
   #  This example shows how to (re)generate the MyUtility module from all the files that have already been moved to that folder. If you use the first example to generate a module, and then you add some files to it, this is the simplest way to re-generate it.
   #  Note that this method does NOT keep the module GUID 
   [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium", DefaultParameterSetName="NewModuleManifest")]
   param(
      # If set, overwrites existing modules without prompting
      [Switch]$Force,

      # If set, appends to (increments) existing modules without prompting.
      # THe Updgrade switch will leave any customizations to your module in place:
      # * It doesn't alter the psm1 (but will create one if it's missing)
      # * It only changes the manifest module version, and any explicitly set parameters
      [Switch]$Upgrade,

      # The name of the module to create
      [Parameter(Position=0, Mandatory=$true)]
      [ValidateScript({if($_ -match "[$([regex]::Escape(([io.path]::GetInvalidFileNameChars() -join '')))]") { throw "The ModuleName must be a valid folder name. The character '$($matches[0])' is not valid in a Module name."} else { $true } })]
      $ModuleName,

      # The script files to put in the module. Should be .ps1 files (but could be .psm1 too)
      [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="OverwriteModule")]
      [Alias("PSPath")]
      $Path,

      # Supports recursively searching for File
      [Switch]$Recurse,

      # If set, enforces the allowed verb names on function exports
      [Switch]$StrictVerbs,

      # The name of the author to use for the psd1 and copyright statement
      [PSDefaultValue(Help = {"Env:UserName: (${Env:UserName})"})]
      [String]$Author = $Env:UserName,

      # A short description of the contents of the module.
      [Parameter(Position=1)]
      [PSDefaultValue(Help = {"'A collection of script files by ${Env:UserName}' (uses the value from the Author parmeter)"})]
      [string]${Description} = "A collection of script files by $Author",

      # The vresion of the module 
      # (This is a passthru for New-ModuleManifest)
      [Parameter()]
      [PSDefaultValue(Help = "1.0 (when -Upgrade is set, increments the existing value to the nearest major version number)")]
      [Alias("Version","MV")]
      [Version]${ModuleVersion} = "1.0",

      # (This is a passthru for New-ModuleManifest)
      [AllowEmptyString()]
      [String]$CompanyName = "None (Personal Module)",

      # Specifies the minimum version of the Common Language Runtime (CLR) of the Microsoft .NET Framework that the module requires (Should be 2.0 or 4.0). Defaults to the (rounded) currently available ClrVersion.
      # (This is a passthru for New-ModuleManifest)
      [version]
      [PSDefaultValue(Help = {"Your current CLRVersion number (rounded): ($($PSVersionTable.CLRVersion.ToString(2)))"})]
      ${ClrVersion} = $($PSVersionTable.CLRVersion.ToString(2)),

      # Specifies the minimum version of Windows PowerShell that will work with this module. Defaults to 1 less than your current version.
      # (This is a passthru for New-ModuleManifest)
      [version]
      [PSDefaultValue(Help = {"Your current PSVersion number (rounded): ($($PSVersionTable.PSVersion.ToString(2))"})]
      [Alias("PSV")]
      ${PowerShellVersion} = $("{0:F1}" -f (([Double]$PSVersionTable.PSVersion.ToString(2)) - 1.0)),
      
      # Specifies modules that this module requires. (This is a passthru for New-ModuleManifest)
      [System.Object[]]
      [Alias("Modules","RM")]
      ${RequiredModules} = $null,
      
      # Specifies the assembly (.dll) files that the module requires. (This is a passthru for New-ModuleManifest)
      [AllowEmptyCollection()]
      [string[]]
      [Alias("Assemblies","RA")]
      ${RequiredAssemblies} = $null
   )

   begin {
      # Make sure ModuleName isn't really a path ;)
      if(Test-Path $ModuleName -Type Container) {
         [String]$ModulePath = Resolve-Path $ModuleName
      } else {
         if(!$ModuleName.Contains([io.path]::DirectorySeparatorChar) -and !$ModuleName.Contains([io.path]::AltDirectorySeparatorChar)) {
            [String]$ModulePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules\$ModuleName"
         } else {
            [String]$ModulePath = $ModuleName
         }
      }
      [String]$ModuleName = Split-Path $ModuleName -Leaf

      # If they passed in the File(s) as a parameter
      if($Path) {
         $Path = switch($Path) {
            {$_ -is [String]} { 
               if(Test-Path $_) {
                  Get-ChildItem $_ -Recurse:$Recurse | % { $_.FullName }
               } else { throw "Can't find the file '$_' doesn't exist." }
            }
            {$_ -is [IO.FileSystemInfo]} { $_.FullName }
            default { Write-Warning $_.GetType().FullName + " type not supported for `$Path" }
         }
      }

      $ScriptFiles = @()
   }

   process {
      $ScriptFiles += switch($Path){
         {$_ -is [String]} { 
            if(Test-Path $_) {
               Resolve-Path $_ | % { $_.ProviderPath }
            } else { throw "Can't find the file '$_' doesn't exist." }
         }
         {$_ -is [IO.FileSystemInfo]} { $_.FullName }
         {$_ -eq $null}{ } # Older PowerShell version had issues with empty paths
         default { Write-Warning $_.GetType().FullName + " type not supported for `$Path" }
      }
   }

   end {
      # If there are errors in here, we need to stop before we really mess something up.
      $ErrorActionPreference = "Stop"

      # We support either generating a module from an existing module folder, 
      # or generating a module from loose files (but not both)
      if($ScriptFiles) {
         # We have script files, so let's make sure the folder is empty and then put our files in it
         if(!$Upgrade -and (Test-Path $ModulePath)) {
            if($Force -Or $PSCmdlet.ShouldContinue("The specified Module already exists: '$ModulePath'. Do you want to delete it and start over?", "Deleting '$ModulePath'")) {
               Remove-Item $ModulePath -recurse
            } else {
               throw "The specified ModuleName '$ModuleName' already exists in '$ModulePath'. Please choose a new name, or specify -Force to overwrite that folder."
            }
         }

         if(!$Upgrade -or !(Test-Path $ModulePath)) {
            try {
               $null = New-Item -Type Directory $ModulePath
            } catch [Exception]{
               Write-Error "Cannot create Module Directory: '$ModulePath' $_"
            }
         }

         # Copy the files into the ModulePath, recreate directory paths where necessary
         foreach($file in Get-Item $ScriptFiles | Where { !$_.PSIsContainer }) {
            $Destination = Join-Path $ModulePath (Resolve-Path $file -Relative )
            if(!(Test-Path (Split-Path $Destination))) {
               $null = New-Item -Type Directory (Split-Path $Destination)
            }
            Copy-Item $file $Destination
         }
      }

      # We need to run the rest of this (especially the New-ModuleManifest stuff) from the ModulePath
      Push-Location $ModulePath

      try {
         # Create the RootModule if it doesn't exist yet
         if(!$Upgrade -Or !(Test-Path "${ModuleName}.psm1")) {
            if($Force -Or !(Test-Path "${ModuleName}.psm1") -or $PSCmdlet.ShouldContinue("The specified '${ModuleName}.psm1' already exists in '$ModulePath'. Do you want to overwrite it?", "Creating new '${ModuleName}.psm1'")) {
               Set-Content "${ModuleName}.psm1" @'
Push-Location $PSScriptRoot
Import-LocalizedData -BindingVariable ModuleManifest
$ModuleManifest.FileList -like "*.ps1" | % {
    $Script = Resolve-Path $_ -Relative
    Write-Verbose "Loading $Script"
    . $Script
}
Pop-Location
'@
            } else {
               throw "The specified Module '${ModuleName}.psm1' already exists in '$ModulePath'. Please create a new Module, or specify -Force to overwrite the existing one."
            }
         }


         if($Force -Or $Upgrade -or !(Test-Path "${ModuleName}.psd1") -or $PSCmdlet.ShouldContinue("The specified '${ModuleName}.psd1' already exists in '$ModulePath'. Do you want to update it?", "Creating new '${ModuleName}.psd1'")) {
            if($Upgrade -and (Test-Path "${ModuleName}.psd1")) {
               Import-LocalizedData -BindingVariable ModuleInfo -File "${ModuleName}.psd1" -BaseDirectory $ModulePath
            } else {
               # If there's no upgrade, then we want to use all the parameter (default) values, not just the PSBoundParameters:
               $ModuleInfo = @{
                  # ModuleVersion is special, because it will get incremented
                  ModuleVersion = 0.0
                  Author = $Author
                  Description = $Description
                  CompanyName = $CompanyName
                  ClrVersion = $ClrVersion
                  PowerShellVersion = $PowerShellVersion
                  RequiredModules = $RequiredModules
                  RequiredAssemblies = $RequiredAssemblies
               }
            }

            # We'll list all the files in the module
            $FileList = Get-ChildItem -Recurse | Where { !$_.PSIsContainer } | Resolve-Path -Relative

            $verbs = if($Strict){ Get-Verb | % { $_.Verb +"-*" } } else { "*-*" }

            # Overwrite existing values with the new truth ;)
            $ModuleInfo.Path = Resolve-Path "${ModuleName}.psd1"
            # RootModule in v3, but this should keep it compatible with v2
            $ModuleInfo.ModuleToProcess = "${ModuleName}.psm1"
            $ModuleInfo.ModuleVersion = [Math]::Floor(1.0 + $ModuleInfo.ModuleVersion).ToString("F1")
            $ModuleInfo.FileList = $FileList
            $ModuleInfo.TypesToProcess = $FileList -match ".*Types?\.ps1xml"
            $ModuleInfo.FormatsToProcess = $FileList -match ".*Formats?\.ps1xml"
            $ModuleInfo.NestedModules = $FileList -like "*.psm1" -notlike "*${ModuleName}.psm1"
            $ModuleInfo.FunctionsToExport = $Verbs
            $ModuleInfo.AliasesToExport = "*"
            $ModuleInfo.VariablesToExport = "${ModuleName}*"
            $ModuleInfo.CmdletsToExport = $Null

            # Overwrite defaults and upgrade values with specified values (if any)
            $null = $PSBoundParameters.Remove("Path")
            $null = $PSBoundParameters.Remove("Force")
            $null = $PSBoundParameters.Remove("Upgrade")
            $null = $PSBoundParameters.Remove("Recurse")
            $null = $PSBoundParameters.Remove("ModuleName")
            foreach($key in $PSBoundParameters.Keys) {
               $ModuleInfo.$key = $PSBoundParameters.$key
            }

            New-ModuleManifest @ModuleInfo
            Get-Item $ModulePath
         }  else {
            throw "The specified Module Manifest '${ModuleName}.psd1' already exists in '$ModulePath'. Please create a new Module, or specify -Force to overwrite the existing one."
         }
      } catch {
         throw
      } finally {
         Pop-Location
      }
   }
}
