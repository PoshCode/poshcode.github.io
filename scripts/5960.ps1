function ConvertFrom-DN {
    
    
    #Based on: http://practical-admin.com/blog/convert-dn-to-canoincal-and-back/
    #Author: Andrew
    #Corrected by Wojciech Sciesinski wojciech[at]sciesinski[dot]net
    
    param ([string]$DN = (Throw '$DN is required!'))
    
    foreach ($item in ($DN.replace('\,', '~').split(","))) {
        
        switch -regex ($item.TrimStart().Substring(0, 3)) {
            
            "CN=" { $CN +=, $item.replace("CN=", ""); $CN += '/'; continue }
            
            "OU=" { $OU +=, $item.replace("OU=", ""); $OU += '/'; continue }
            
            "DC=" { $DC += $item.replace("DC=", ""); $DC += '.'; continue }
            
        }
        
    }
    
    $canonical = $dc.Substring(0, $dc.length - 1)
    
    If ($ou.count -gt 0) {
        
	for ($i = $ou.count; $i -ge 0; $i--) { $canonical += $ou[$i] }
        
    }
    
    If ($CN.count -gt 0) {
        
        for ($i = $CN.count; $i -ge 0; $i--) { $canonical += $CN[$i] }
        
    }
    
    return $canonical
}
