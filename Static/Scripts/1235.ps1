function decrypt-psi ($jid, $pw) {
   $OFS = ""; $u = 0;
   for($p=0;$p -lt $pw.Length;$p+=4) {
      [char]([int]"0x$($pw[$p..$($p+3)])" -bxor [int]$jid[$u++])
   }
}

$accounts = ([xml](cat ~\psidata\profiles\default\accounts.xml))["accounts"]["accounts"]

foreach($account in ($accounts | gm a[0-9]*)) {
   $a = $accounts.$($account.Name) 
   "$($a.jid.'#text'):$( decrypt-psi $a.jid.'#text' $a.password.'#text' )"
}
