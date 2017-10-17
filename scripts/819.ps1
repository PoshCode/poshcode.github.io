# Name  : Find-Abbreviation.ps1
# Author: David "Makovec" Moravec
# Web   : http://www.powershell.cz
# Email : powershell.cz@googlemail.com
#
# Description: Finds meaning of given abbreviation
#            : Uses HttpRest http://poshcode.org/787
#
# Version: 0.1
# History:
#  v0.1 - (add) basic functionality
# 
# Usage: Find-Abbreviation itmu
#
#################################################################

function Find-Abbreviation {
	$url = "http://acronyms.thefreedictionary.com/$args"
	Invoke-Http get $url | Receive-Http Text "//tr[@cat]//td[2]"
}
