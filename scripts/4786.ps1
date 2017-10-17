$i = 1
[Math]::Pow(((++$i + ++$i) * ++$i), ++$i) #this returns 3200000
#what do you think is $i right now? it's "5"
#reseting $i
$i = 1
[Math]::Pow((($i++ + $i++) * $i++), $i++) #this returns 6561
#but what do you think is $i right now, ahh? aha, it's again 5
#reseting $i
$i = 1
++$i + ++$i #returns... 5!
#but...
$i = 1
$i++ + $i++ #neah, this's not 5, it's 3. why? try to guess:)
