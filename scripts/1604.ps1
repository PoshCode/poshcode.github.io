################################################################################
## Script Name:     LoadModuleConfig
## Created On:      01/21/2010
## Author:          Thell Fowler
## File:            LoadModuleConfig.ps1
## Usage:           Called from the NestedModules value from a module manifest.
## Version:         1.0.1.0
## Purpose:         Provides automated loading of local configuration data.
##
## Requirements:    PowerShell Version 2
## Last Updated:    01/23/2010
## History:
##					1.0.1.0 01/21/2010 - TBF - Made Add-Member calls forceful.
##					1.0.0.0 01/21/2010 - TBF - Initial implementation.
##
##
################################################################################

<#
	To make use of this script use new-modulemanifest to create a manifest named
	the with the same name as the manifest you are loading data for but with an
	extension of 'config.psd1'
	
	Enter LoadModuleConfig.ps1 in the NestedModules field.
	
	After creating the manifest open it in your editor and edit the PrivateData
	field to include hashes for LocalUser and Settings.  After the Settings key
	add values as you see fit.
	
	Here is an example, as used in the FuncGuard module.
	
	# Private data to pass to the module specified in ModuleToProcess
	PrivateData = @{
		"LocalUser" = @{
			"Settings"=@{
				"ActiveConfiguration" = "PSUnit"
				"Configurations"=@{
					"PSUnit" =@{
						"Name"="PSUnit";
						"Path"=$(join-path -Path $Env:Temp -ChildPath "FuncGuard.PSUnit");
						"Prefix"="PSUNIT"
					}
				}
			}
		}
	}
	
	After loading the module a global variable will be available with a name
	convention of $($ModuleName)Settings and the values can be accessed using
	normal hash retrieval.
	
	$config = $FuncGuardSettings["Configurations"].$($FuncGuardSettings["ActiveConfiguration"])
	$Path = $config.Path

#>

#requires -version 2.0
Set-StrictMode -Version 2

$Module = $ExecutionContext.SessionState.Module
if (! $Module) {
	throw ( New-Object System.Management.Automation.SessionStateException `
		"An active module was not found!  LoadModuleConfig must be run from a module manifest's NestedModules field.")
}
$ModuleName = $Module.Name.Replace(".config",$null)

$AppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
$ModuleConfigPath = join-path -Path $AppData `
	-ChildPath "WindowsPowerShell\Modules\$ModuleName\$ModuleName.config.xml"

$configurations = $null
if ( Test-Path $ModuleConfigPath -PathType Leaf ) {
	$configurations = Import-Clixml -Path $ModuleConfigPath
} else {
	# Generate new default config file.
	$configurations = $Module.PrivateData.LocalUser.Settings
	$configurations.add("InitializeConfigurations", $true)
	Export-Clixml -InputObject $configurations -Path $ModuleConfigPath
}

if ($configurations) {
	Add-Member -InputObject $configurations -Name ModuleName -MemberType NoteProperty -force `
		-Value $ModuleName

	Add-Member -InputObject $configurations -Name Export -MemberType ScriptMethod -force `
		-Value {
			$AppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
			$ModuleConfigPath = join-path -Path $AppData `
				-ChildPath "WindowsPowerShell\Modules\$ModuleName\$($this.ModuleName).config.xml"
			Export-Clixml -InputObject $this -Path $ModuleConfigPath
		}

	Set-Variable -Name "$($ModuleName)Settings" -Value $($configurations) -Scope Global `
	-Description "$($ModuleName) module configuration settings."
}
