#You'll need admin perms on all the servers to run this...
Write-Host "ComputerName in White, then Local Groups in Green, Local Groups' Members in White"


#This feeds the script a list of server names (ServerList.txt, placed in the same directory)
#for which I want the Local Groups and all those groups' Members.


$x = Get-Content ServerList.txt

# this feeds each servername, one by one, into the process...

foreach ($j in $x) {


#The server name becomes variable $strComputer

$strComputer = "$j"


#The Server name then becomes the variable $strComputer, and its name
#is printed out in all CAPS

$computer = [ADSI]("WinNT://" + $strComputer + ",computer")
$g = $computer.name.ToString()
$g.ToUpper(); " "


#The local security groups on the Server is then found, 
#and fed to the array $a

$group = $computer.psbase.children | where{$_.psbase.schemaclassname -eq "group"}
$a = @()
foreach ($member in $group.psbase.syncroot)
{$a += $member.name } 



#Each Local Group Member is then printed (in white,and with a space) underneath its Group's name
#(Group name printed in green)

foreach ($i in $a) {

$group =[ADSI]"WinNT://$j/$i" 
Write-Host "$i" -fore green
$members = @($group.psbase.Invoke("Members")) 
$members | foreach { Write-Host " ",$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
}

Write-host " "
Write-host " "
Write-host " "
}
