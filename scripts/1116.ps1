# function ConvertFrom-Hashtable {
PARAM([[HashTable]$hashtable,[switch]$combine)
BEGIN { $output = New-Object PSObject }
PROCESS {
if($_) { 
   $hashtable = $_;
   if(!$combine) {
      $output = New-Object PSObject
   }
}
   $hashtable.GetEnumerator() | 
      ForEach-Object { Add-Member -inputObject $object `
	  	-memberType NoteProperty -name $_.Name -value $_.Value }
   $object
}
#}
