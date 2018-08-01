$chars = "b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z" 

foreach($char1 in $chars){ 
foreach($char2 in $chars){ 
foreach($char3 in $chars){ 
foreach($char4 in $chars){ 
$pw = $char1+$char2+$char3+$char4 
write-host $pw 
} 
} 
}	
}
