function Shuffle
{
 param([Array] $a)
 
 $rnd=(new-object System.Random)
 
 for($i=0;$i -lt $a.Length;$i+=1){
  $newpos=$i + $rnd.Next($a.Length - $i); 
  $tmp=$a[$i]; 
  $a[$i]=$a[$newpos]; 
  $a[$newpos]=$tmp 
 } 
 return $a
}

