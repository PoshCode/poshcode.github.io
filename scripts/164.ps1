Param($ou)
if($ou){$root = [ADSI]"LDAP://$ou"}else{$root=[adsi]""}
$filter = "(&(objectCategory=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))"
$ds = new-object directoryservices.directorysearcher($root,$filter)
$users = $ds.findall()
$users | format-table @{l="User";e={$_.properties.item('cn')}},
                      @{l="sAMAccountName";e={$_.properties.item('sAMAccountName')}},
                      @{l="Path";e={$_.path}}
