<#
	.SYNOPSIS
		Tests for a valid IP mask.
	
	.DESCRIPTION
		The Test-IPMask script validates the input string against all CIDR subnet masks and returns a boolean value.
	
	.PARAMETER IPMask
		The IP mask to be evaluated.
	
	.EXAMPLE
		Test-IPMask 255.255.255.0
		Description
		-----------
		Tests if the IP mask "255.255.255.0" is a valid CIDR subnet mask.
	
	.INPUTS
		System.String
		
	.OUTPUTS
		System.String
		System.Boolean
	
	.NOTES
		Name: Test-IPMask.ps1
		Author: Rich Kusak (rkusak@cbcag.edu)
		Created: 2011-01-03
		LastEdit: 2011-01-05 00:37
		Version 1.0.0
		
		#Requires -Version 2.0

	.LINK
		http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

	.LINK
		about_regular_expressions
	
#>

	[CmdletBinding()]
	param (
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[string]$IPMask
	)

	begin {

		# Common subnet mask values
		$common = '0|128|192|224|240|248|252|254|255'
		
		# Build a regular expression to represent all possible mask strings
		$masks = @(
			"(^($common)\.0\.0\.0$)"
			"(^255\.($common)\.0\.0$)"
			"(^255\.255\.($common)\.0$)"
			"(^255\.255\.255\.($common)$)"
		)
		
		# Join all possible strings with the regex "or" operator
		$regex = [string]::Join('|', $masks)
	}

	process {

		# Evaluate the IPMask input
		$result = [regex]::Match($IPMask, $regex).Success
		
		# Create an output object containing the results of the evaluation
		New-Object PSObject -Property @{
			'IPMask' = $IPMask
			'Valid' = $(
				if ($result) {
				    $true
				} else {
				    $false
				}
			)
		}
	}

