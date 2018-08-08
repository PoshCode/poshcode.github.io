Param($Domain,$objectDN,$property)
$context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$domain)
$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::findOne($context) 
$meta = $dc.GetReplicationMetadata($objectDN)
if($property){$meta | %{$_.$Property}}else{$meta}
