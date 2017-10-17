function checkADSI()
{ $ADSIStat = "Servers in Computer OU"
  $error.clear()
  $errcnt = 0
    
  $objDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://CN=Computers,DC=domain,DC=com")
  $objSearcher = New-Object System.DirectoryServices.DirectorySearcher($objDomain)
  $objSearcher.Filter = ("(operatingSystem=*Server*)")
  $objSearcher.SearchScope = "OneLevel"
  
  $colProplist = "dnshostname"
  foreach ($i in $colPropList)
  {$idx = $objSearcher.PropertiesToLoad.Add($i)}

  $colResults = $objSearcher.FindAll()
  for($i = 0; $i -lt ($colResults.count -1); $i++ ) 
  { $objResult = $colResults[$i]
    $objComputer = $objResult.Properties
    $cName = ($objComputer.dnshostname -replace ".domain.com","")
    
    $ADSIStat += "`n`t! " + $cname
    $errcnt += 1
    
  }
  if($error[0])
  { $ADSIStat += "`n`t Errors Occured: "
    foreach($err in $error)
    { $ADSIStat += "`n`t`!" + $err }
  } 
  elseif($errCnt -eq 0)
  {$ADSIStat += " None" }
  
  return $ADSIStat
}#function checkADSI()
