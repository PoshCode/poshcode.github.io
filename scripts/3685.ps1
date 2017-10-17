function RemoveSpace([string]$text) {  
    $private:array = $text.Split(" ", `
    [StringSplitOptions]::RemoveEmptyEntries)
    [string]::Join(" ", $array) }

$quser = quser
foreach ($sessionString in $quser) {
    $sessionString = RemoveSpace($sessionString)
    $session = $sessionString.split()
    
    if ($session[0].Equals(">nistuke")) {
    continue }
    if ($session[0].Equals("USERNAME")) {
    continue }
    # Use [1] because if the user is disconnected there will be no session ID. 
    $result = logoff $session[1] }
