$rng = 10000
(Measure-Command {
    $hash = @{}
    foreach ($a in 1..$rng){
        $hash[$a] = $a
    }
}).totalmilliseconds

(Measure-Command {
    $hash = @{}
    foreach ($a in 1..$rng){
        $hash.$a = $a
    }
}).TotalMilliseconds

(Measure-Command {
    $hash = @{}
    foreach ($a in 1..$rng){
        $hash.add($a, $a)
    }
}).TotalMilliseconds
