#=================================================================================
#	MoveArchives.ps1
#
#	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
#	KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#	IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#	PARTICULAR PURPOSE.
#	
#	Description:  
#
#	#	This Script Written By: David Pekmez (http://unifiedit.wordpress.com/)
#
#	Version: 1
#	Last Updated: 29/07/2010
#=================================================================================

#=======================================
# Parameter definition
#=======================================
Param(
                [string] $User,
                [string] $ArchiveDatabase
                )
                If([String]::IsNullOrEmpty($User)) {
                $User = ‘*’
}


#==========================================================================
# Function that returns true if the incoming argument is a help request
#==========================================================================
function IsHelpRequest
{
	param($argument)
	return ($argument -eq "-?" -or $argument -eq "-help");
}
		
#===================================================================
# Function that displays the help related to this script following
# the same format provided by get-help or <cmdletcall> -?
#===================================================================
function Usage
{

@"
NAME: MoveArchives.ps1

SYNOPSIS:
Move User's Archive to another Database
Exchange 2010 SP1 Requiered

SYNTAX:
MoveArchives.ps1
`t[-User <UserName>]
`t[-ArchiveDatabase <ArchiveDatabaseName>]


PARAMETERS:
-User (optional)
The Username you want the archive to be moved.
If not used, all users archives will be moved to the target Database.

-ArchiveDatabase (required)
The Target Database Name where the archive will be moved

-------------------------- EXAMPLE 1 --------------------------

.\MoveArchives.ps1 -User dpekmez -ArchiveDatabase ArchiveDB1

-------------------------- EXAMPLE 2 --------------------------

.\MoveArchives.ps1 -ArchiveDatabase ArchiveDB1

"@
}	

#=======================================
# Check for Usage Statement Request
#=======================================
$args | foreach { if (IsHelpRequest $_) { Usage; exit; } }


#==============================================
# Function that validates the script parameters
#==============================================
function ValidateParams
{
	$validInputs = $true
	$errorString =  ""

	if ($ArchiveDatabase -eq "")
	{
		$validInputs = $false
		$errorString += "`nMissing Parameter: The -ArchiveDatabase parameter is required. Please pass in the desired Target Database Name."
	}

	if (!$validInputs)
	{
		Write-error "$errorString"
	}

	return $validInputs
}


#==============================================
# Move Request
#==============================================

Get-Mailbox -identity $User | where { $_.ArchiveDatabase -ne $null } | New-MoveRequest -ArchiveTargetDatabase $ArchiveDatabase –ArchiveOnly


