function New-Choice {
<#
	.SYNOPSIS
		The New-Choice function is used to provide extended control to a script author who writing code 
                  that will prompt a user for information.

	.PARAMETER  Choices
		An Array of Choices, ie Yes, No and Maybe

	.PARAMETER  Caption
		Caption to present to end user

	.EXAMPLE
		PS C:\> New-Choice -Choices 'Yes','No' -Caption "PowerShell makes choices easy"
		
	.NOTES
		Author: Andy Schneider
		Date: 5/6/2011
#>

[CmdletBinding()]
param(
		
	[Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)]
	$Choices,
		
	[Parameter(Position=1)]
	$Caption,
    
	[Parameter(Position=2)]
	$Message    
	
)
	
process {
        
        $resulthash += @{}
        for ($i = 0; $i -lt $choices.count; $i++) 
            {
        	   $ChoiceDescriptions += @(New-Object System.Management.Automation.Host.ChoiceDescription $choices[$i])
               $resulthash.$i = $choices[$i]
            }
        $AllChoices = [System.Management.Automation.Host.ChoiceDescription[]]($ChoiceDescriptions)
        $result = $Host.UI.PromptForChoice($Caption,$Message, $AllChoices, 1)
        $resulthash.$result
        }         
}
