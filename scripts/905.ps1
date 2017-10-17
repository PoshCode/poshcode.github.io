# Author: Hal Rottenberg
# Purpose: Find matching members in a local group
# Used tip from RichS here: http://powershellcommunity.org/Forums/tabid/54/view/topic/postid/1528/Default.aspx

# Change these two to suit your needs
$ChildGroups = "Domain Admins", "group two"
$LocalGroup = "Administrators"
$error.clear()
$MemberNames = @()
# uncomment this line to grab list of computers from a file
 $Servers = Get-Content serverlist.txt
# $Servers = $env:computername # for testing on local computer
foreach ( $Server in $Servers ) {
	$MemberNames = @()
	$Group= [ADSI]"WinNT://$Server/$LocalGroup,group"
	$Members = @($Group.psbase.Invoke("Members"))
	$Members | ForEach-Object {
		$MemberNames += $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
	
	} 
         $errCount = $error.count
	$ChildGroups | ForEach-Object {
		$output = "" | Select-Object Server, Group, InLocalAdmin
		$output.Server = $Server
		$output.Group = $_
		If ($errCount -gt 0){$output.InLocalAdmin = "Connection Error!"}ELSE{$output.InLocalAdmin = $MemberNames -contains $_}
		Write-Output $output
	}
$error.clear()
}
