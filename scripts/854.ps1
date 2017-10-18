# These functions are meant to help generate a table that shows differences between
# cmdlets among different versions of a module.
# You will need a MoinMoin wiki to render the output.
# If you don't have a MoinMoin wiki you might be able to use the sandbox at http://moinmo.in/WikiSandBox

# Extracts some data from a module's help for use with Diff-HelpXml
function Get-HelpXml {
	param ($module)

	get-command -module $module | % {
		$allParams = $_.parametersets | % { $_.parameters | select -unique Name }
		$obj = new-object psobject
		$obj | add-member -type noteproperty -name name -value $_.Name
		$obj | add-member -type noteproperty -name parameters -value $allParams

		# Pull some things out of help.
		$h = $_ | get-help
		$obj | add-member -type noteproperty -name description -value $h.Description
		$obj | add-member -type noteproperty -name paramDescriptions -value $h.parameters

		$obj
	}
}

# Diff a help XML and output the results in Moinmoin wiki format.
# You can then copy to a MoinMoin wiki to do HTML rendering.
function Diff-HelpXml {
	param ($beforeFile, $afterFile)

	# The XML files should be generated with makexml.ps1
	$before = import-clixml $beforeFile
	$after = import-clixml $afterFile

	$titleColor = "<bgcolor=`"#72AEC0`">"
	$color1 = "<bgcolor=`"#C2DEF0`">"
	$color2 = "<bgcolor=`"#ffffff`">"

	echo "= New cmdlets in this release ="
	echo " ||$titleColor Name ||$titleColor Description ||"
	foreach ($a in $after) {
		$match = $before | where { $_.Name -eq $a.Name }
		if ($match -eq $null) {
			$name = $a.Name
			$desc = $a.Description[0].Text
			echo " || $name || $desc ||"
		}
	}

	echo ""
	echo "= New cmdlet parameters in this release ="
	$color = $color1
	echo " ||$titleColor Cmdlet Name ||$titleColor Parameter Name ||$titleColor Description ||"
	foreach ($a in $after) {
		$match = $before | where { $_.Name -eq $a.Name }
		if ($match) {
			$noMatches = $true
			foreach ($p in $a.parameters) {
				$matchPar = $match.parameters | where { $_.Name -eq $p.Name }
				if ($matchPar -eq $null) {
					$cmdletName = ""
					$pName = $p.Name
					if ($noMatches) {
						$cmdletName = $a.Name
						$noMatches = $false
						if ($color -eq $color1) {
							$color = $color2
						} else {
							$color = $color1
						}
					}
					# Find the help for this switch.
					$matchDesc = $a.paramDescriptions.parameter | where { $_.Name -eq $pName }
					$pDesc = $matchDesc.description[0].text
					$pDesc = $pDesc -replace "[^A-Za-z1-9\.`"``, ]", " "

					echo " ||$color $cmdletName ||$color $pName ||$color $pDesc ||"
				}
			}
		}
	}
}

# Sample usage:
## Install VI Toolkit 1.0
# Get-HelpXml -module vmware.vimautomation.core | export-clixml before.xml
## Install VI Toolkit 1.5
# Get-HelpXml -module vmware.vimautomation.core | export-clixml after.xml
# Diff-HelpXml -before before.xml -after after.xml | set-content diffsInMoinMoin.txt
