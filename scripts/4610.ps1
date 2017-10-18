#requires -version 2.0
<#
.SYNOPSIS
    Report of AD objects
.DESCRIPTION
    Report of AD objects
.NOTES
    Author: voytas
.LINK
    voytas.net
.EXAMPLE
    n/a
#>



if(!(get-module activedirectory)) {
import-module activedirectory
} 

#variables
$inactivedays = 30
$inactivedayscomp = 30
$comptop = 20
$usertop = 2
$userdname = "dc=domain,dc=local"
$compdname = "ou=comp,dc=domain,dc=local"
$compdn1 = "ou=comp,dc=domain,dc=local"
$compdn2 = "ou=comp,dc=domain,dc=local"
$domain = (Get-ADDomain).dnsroot
$DCs = (Get-ADDomainController -Filter *).hostname
$userexep = @("*2*","*test*")
$compexep = @("*templat*","*pool*","*thinapp*")
$opt = "None"
$usertochceck = $null


function complist ([string[]]$sciezka)
{
    begin {
        write-host 
        write-host "Comp: Objects in $sciezka" -ForegroundColor Magenta
    }
    process {
        $a1 = Get-ADComputer -SearchBase "$sciezka" -LDAPFilter "(objectclass=computer)" -SearchScope 1 -Properties description,whencreated
        $a1 | select samaccountname, DNSHostName, enabled, DistinguishedName, description, whencreated, @{n="Owner";e={(Get-ADPermission -Identity $_.distinguishedname -Owner).owner}} | `
            sort whencreated | `
            ft -autosize

    }
    end {
        "Found: $(($a1).count)" 
        write-host "---------------------------------------------"
        write-host
    }
}


function DCslastlogon{
write-host 
write-host "User: Last logon from DCs" -ForegroundColor Magenta
$usertochceck = read-host "What is the User samaccountname?"
write-host 
foreach ($dc in $dcs) {
$userdc=get-aduser -identity $usertochceck -properties lastlogon -server $dc
"The last logon for $usertochceck on $dc occured the " + [DateTime]::FromFileTime($Userdc.LastLogon) + "" 
write-host
}
}

function userinactive {
#active and not logged in ...
write-host ;
write-host "Users: Active and last logon date more than $($inactivedays) day(s)" -ForegroundColor Magenta
$date=(get-date).AddDays(-$inactivedays)
$users=get-aduser `
    -Properties lastlogondate,whencreated `
    -Filter {enabled -eq $true -and lastlogondate -lt $date -and samaccountname -notlike "*2*" -and samaccountname -notlike "*test*"} `
    -SearchBase $userdname | `
    sort lastlogondate
$users | `
    select-object samaccountname,lastlogondate, distinguishedname, @{n="Owner";e={(Get-ADPermission -Identity $_.samaccountname -Owner).owner}},whencreated | `
    ft -AutoSize
write-host "Found: $(($users).count)" -ForegroundColor green
write-host "---------------------------------------------"
write-host ;
}

function userinactivetop{
#active and not logged in - top...
write-host ;
write-host "Users: Active and last logon date more than $($inactivedays) day(s) - TOP ($($usertop))" -ForegroundColor Magenta
$date=(get-date).AddDays(-$inactivedays)
$users=get-aduser `
    -Properties lastlogondate,whencreated `
    -Filter {enabled -eq $true -and lastlogondate -lt $date -and samaccountname -notlike "*2*" -and samaccountname -notlike "*test*"} `
    -SearchBase $userdname | `
    sort lastlogondate
$users | `
    select-object `
        samaccountname,`
        lastlogondate,`
        distinguishedname,`
        @{n="Owner";e={(Get-ADPermission -Identity $_.samaccountname -Owner).owner}},`
        whencreated `
        -first $usertop | `
    ft -AutoSize
write-host "Top $($usertop) from: $(($users).count)" -ForegroundColor green
write-host "---------------------------------------------"
write-host ;
}


function userinactivenotloged {
#active users and not logged ever
write-host ;
write-host "Users: Active and not logged ever" -ForegroundColor Magenta
$users=get-aduser `
    -Properties lastlogondate, whencreated `
    -Filter {enabled -eq $true -and samaccountname -notlike "*2*" -and samaccountname -notlike "*test*"} `
    -SearchBase $userdname | `
    ? {($_.lastlogondate -eq $null)}
$users | `
    select-object samaccountname, distinguishedname, @{n="Owner";e={(Get-ADPermission -Identity $_.distinguishedname -Owner).owner}},whencreated |`
    sort samaccountname | `
    ft -AutoSize
write-host "Found: $(($users).count)" -ForegroundColor green
write-host "---------------------------------------------"
write-host ;
}


function compinactive {
#active and not logged in ...
write-host ;
write-host "Comp: active and last logon date more than $($inactivedays) day(s)" -ForegroundColor Magenta
$date=(get-date).AddDays(-$inactivedayscomp)
$comps=get-adcomputer `
    -Properties lastlogondate,whencreated `
    -Filter {enabled -eq $true -and lastlogondate -lt $date -and samaccountname -notlike "*template*" -and samaccountname -notlike "*pool*" -and samaccountname -notlike "*thinapp*"} `
    -SearchBase $compdname
$comps | `
    select-object samaccountname, distinguishedname, @{n="Owner";e={(Get-ADPermission -Identity $_.distinguishedname -Owner).owner}},whencreated,lastlogondate |`
    sort lastlogondate | `
    ft -AutoSize
write-host "Found: $(($comps).count)" -ForegroundColor green
write-host "---------------------------------------------"
write-host ;
}

function compinactivetop {
# komputery top
write-host ;
write-host "Comp: active and last logon date more than $($inactivedays) day(s) - TOP ($($comptop))" -ForegroundColor Magenta
$date=(get-date).AddDays(-$inactivedayscomp)
$comps=get-adcomputer `
    -Properties lastlogondate,whencreated `
    -Filter {enabled -eq $true -and lastlogondate -lt $date -and samaccountname -notlike "*template*" -and samaccountname -notlike "*pool*" -and samaccountname -notlike "*thinapp*"} `
    -SearchBase $compdname |`
    sort lastlogondate

$comps | `
    select-object samaccountname, distinguishedname, @{n="Owner";e={(Get-ADPermission -Identity $_.distinguishedname -Owner).owner}},whencreated,lastlogondate -first $comptop|`
    ft -AutoSize
write-host "Top $($comptop) from: $(($comps).count)" -ForegroundColor green
write-host "---------------------------------------------"
write-host ;
}


clear
do {
    #clear
    if ($opt -ne "None") { write-host "Last command: "$opt -ForegroundColor yellow}
    write-host
    write-host "AD Object reports:" 
    write-host
    write-host "1) User: Active and last logon date more than $($inactivedays) day(s)"
    write-host "2) User: Active and last logon date more than $($inactivedays) day(s) - TOP ($($usertop))"
    write-host "3) User: Active and not logged ever (lastlogondate empty)"
    write-host "4) User: Lastlogon on all DCs"
    write-host "5) Comp: Active and last logon date more than $($inactivedays) day(s)"
    write-host "6) Comp: Active and last logon date more than $($inactivedays) day(s) - TOP ($($comptop))"
    write-host "7) Comp: Objects in $($compdn1)"
    write-host "8) Comp: Objects in $($compdn2)"
    write-host
    write-host "x) End"
    write-host
    $opt = Read-Host "Select an option.. [1-8,x]"
    write-host

    switch ($opt) {
    1 {cls;userinactive}
    2 {cls;userinactivetop}
    3 {cls;userinactivenotloged}
    4 {cls;DCslastlogon}
    5 {cls;compinactive}
    6 {cls;compinactivetop}
    7 {cls;complist($compdn1)}
    8 {cls;complist($compdn2)}
    x {exit}
    default {}
    }
} while ($opt -ne "x")



