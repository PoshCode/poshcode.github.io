#Author:        Glenn Sizemore glnsize@get-admin.com
#ReAuthored	JayneticMuffin jayneticmuffin@gmail.com
#
#Purpose:       Convert a DN to a Canonical name, and back again.
#
#Example:       PS > ConvertFrom-DN 'CN=Sizemore\, Glenn E,OU=test1,OU=test,DC=getadmin,DC=local'
#                    get-admin.local/test/test1/Sizemore, Glenn E

function ConvertFrom-DN {
	param([string]$DN)
	foreach ($item in ($DN.replace('\,','~').split(","))) {
		switch -regex ($item.TrimStart().Substring(0,3)) {
			"CN=" {$CN = '/' + $item.replace("CN=","");continue}
			"OU=" {$ou += ,$item.replace("OU=","");$ou += '/';continue}
			"DC=" {$DC += $item.replace("DC=","");$DC += '.';continue}
		}
	} 
	$canonical = $dc.Substring(0,$dc.length - 1)
	for ($i = $ou.count;$i -ge 0;$i -- ){$canonical += $ou[$i]}
	if ($cn -ne $null) {$canonical += $cn.ToString().replace('~',',')}
	return $canonical
}

