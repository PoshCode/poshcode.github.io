# Measure-ScriptCode.ps1
# Return metrics about the script and module files
# PowerShell 3 is required as Abstract Syntax Trees are used.
# Jan 2014
# If this works, Victor Vogelpoel <victor.vogelpoel@macaw.nl> wrote this.
# If it doesn't, I don't know who wrote this.
# Blogpost at http://blog.victorvogelpoel.nl/2014/01/12/powershell-measure-scriptcode-calculating-script-code-metrics/

#requires -version 3
Set-PSDebug -Strict
Set-StrictMode -Version Latest

function Measure-ScriptCode
{
	[CmdletBinding()]
	param
	(
	  [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="One or more PS1 or PSM1 files to calculate code metrics for")]
	  [Alias('PSPath', 'Path')]
	  [string[]]$ScriptFile
	)
	
	begin
	{
		$files 			= 0
		$modules 		= 0
		$manifests 		= 0
	
		$lines 			= 0
		$words 			= 0
		$characters		= 0
		$codeLines 		= 0
		$comments 		= 0
		$functions		= 0
		$workflows 		= 0
		$filters 		= 0
		$parseErrors	= 0
	}

	process
	{
		foreach ($file in $ScriptFile)
		{
			if ($file -like "*.ps1") { $files++ }
			if ($file -like "*.psm1") { $modules++ }
			if ($file -like "*.psd1") { $manifests++ }
			
			$fileContentsArray	= Get-Content -Path $file
			
			if ($fileContentsArray)
			{
				# First, measure basic metrics
				$measurement 		= $fileContentsArray | Measure-Object -Character -IgnoreWhiteSpace -Word -Line
				$lines 			+= $measurement.Lines
				$words 			+= $measurement.Words
				$characters 		+= $measurement.Characters				
		
				$tokenAst			= $null
				$parseErrorsAst		= $null
				# Use the PowerShell 3 file parser to create the scriptblock AST, tokens and error collections
				$scriptBlockAst		= [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokenAst, [ref]$parseErrorsAst)

				# Get the number of comment lines and comments on the end of a code line
				$comments		+= @($tokenAst | where { $_.Kind -eq "Comment" } ).Length 
				
				# Calculate the 'lines of code': any line not containing comment or commentblock and not an empty or whitespace line.
				# Remove comment tokens from the tokenAst, remove all double newlines and count all the newlines (minus 1)
				$prevTokenIsNewline	= $false
				$codeLines 		+= @($tokenAst | select -ExpandProperty Kind |  where { $_ -ne "comment" } | where {
											if ($_ -ne "NewLine" -or (!$prevTokenIsNewline))
											{
												$_
											}
											$prevTokenIsNewline = ($_ -eq "NewLine")
										} | where { $_ -eq "NewLine" }).Length-1
				
				$parseErrors 		+= @($parseErrorsAst).Length

				if ($scriptBlockAst -ne $null)
				{
					# Find all functions, filters and workflows in the AST, including nested functions
					$functionAst 	= $scriptBlockAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

					# Count the specific implementation: 'function', 'filter' or 'workflow'
					$functions 	+= @($functionAst | where { (!$_.IsFilter) -and (!$_.IsWorkflow) }).Length
					$filters	+= @($functionAst | where { $_.IsFilter }).Length
					$workflows	+= @($functionAst | where { $_.IsWorkflow }).Length
				}
			}
		}
	}

	end
	{
		return [PSCustomObject]@{
			Files 		= $files
			Modules 	= $modules
			Manifests	= $manifests

			CodeLines	= $codeLines
			Comments 	= $comments
			Functions 	= $functions
			Workflows	= $workflows
			Filters		= $filters

			ParseErrors	= $parseErrors
			Characters 	= $characters
			Lines 		= $lines
			Words		= $words
		}
	}
}

