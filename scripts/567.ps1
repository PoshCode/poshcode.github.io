# $Id: New-ComplexPassword.ps1 170 2008-09-05 19:49:48Z jon $
# $Revision: 170 $

Function New-ComplexPassword ([int]$Length=8, $digits=$null, $alphaUpper=$null, $alphaLower=$null, $special=$null)
{

	#  ASCII data taken from http://msdn2.microsoft.com/en-us/library/60ecse8t(VS.80).aspx

	# Make sure the password is long enough to meet complexity requirements
	if($digits+$alphaUpper+$alphaLower+$special -gt $Length) { throw "Password too short for specified complexity" }

	# Define character groups and the number of each required by passwords

	# In case this is used in a DCPromo answer files, theres a few chars to 
	# avoid: Ampersand, Less than, double quote and back slash
	# (34,38,60,92)
	
	$groups = @()
	$group = New-Object System.Object
	Add-Member -In $group -Type NoteProperty -Name "Group" -Value "0123456789" # 48..57

	Add-Member -In $group -Type NoteProperty -Name "Count" -Value $Digits
	$groups += $group

	$group = New-Object System.Object
	Add-Member -In $group -Type NoteProperty -Name "Group" -Value "ABCDEFGHIJKLMNOPQRSTUVWXYZ" # 65..90
	Add-Member -In $group -Type NoteProperty -Name "Count" -Value $alphaUpper
	$groups += $group

	$group = New-Object System.Object
	Add-Member -In $group -Type NoteProperty -Name "Group" -Value "abcdefghijklmnopqrstuvwxyk" # 97..122
	Add-Member -In $group -Type NoteProperty -Name "Count" -Value $alphaLower
	$groups += $group

	$group = New-Object System.Object
	Add-Member -In $group -Type NoteProperty -Name "Group" -Value '~`!@#$%^&*()-_={}[]\|;:"<>?,./'' ' #  32..47, 58..64, 91..96, 123..126
	Add-Member -In $group -Type NoteProperty -Name "Count" -Value $special
	$groups += $group 

	# initilize random number generator
	$ran = New-Object Random

	# make sure password meets complexity requirements
	foreach ($req in $groups)
	{
		if ($req.count)
		{
			$charsAllowed += $req.group

			for ($i=0; $i -lt $req.count; $i++)
			{
				$r = $ran.Next(0,$req.group.length)
				$password += $req.group[$r]	
			}
		} elseif ($req.count -eq 0) {
			$charsAllowed += $req.group
		}
	}

	# make sure password meets length requirement
	if(!$charsAllowed)
	{
		$groups |% { $charsAllowed += $_.group }
	}

	for($i=$password.length; $i -lt $length; $i++)
	{
		$r = $ran.Next(0,$charsAllowed.length)
		$password += $charsAllowed[$r]
	}

	# randomize the password
	return [string]::join('',($password.ToCharArray()|sort {$ran.next()}))
}
