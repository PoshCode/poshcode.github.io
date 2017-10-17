param(
[Parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[alias("Name","ComputerName")][string[]] $Computers = @($env:computername),
#works automagically for domain members or local computer,
#must be set manual for workgroups or forests
[string] $NTDomain = ($env:UserDomain),
# multiple groups usually makes sense when reporting only
[string[]] $LocalGroups = @("Administrators"),
[string[]] $Add = @(), # can be user or group
[string[]] $Remove = @() # can be user or group
)
begin{
$script:objReport = @()

# list current members in defined group
Function ListMembers ($Group){
$members = $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
return $members
}
#
Function LocalNTGroup ($ComputerName,$Group){
$NTgroup = ([ADSI]("WinNT://" + $Computer + ",computer")).psbase.children.find($Group)
return $NTgroup
}
# provides central output code in case of future revisions
Function Output($ComputerName,$GroupName,$UserName,$Action,$Result){
$script:objReport += New-Object PSObject -Property @{
	Computername = $ComputerName
	GroupName = $GroupName
	UserName = $UserName
	Action = $Action
	Result = $Result
	}
write-host "on $ComputerName -- $GroupName for $UserName the result for $Action is: $Result"
}
}#begin

process{
#foreach loops will not iterate when empty thus no try-catch
foreach ($Computer in $Computers){
	if (Test-Connection -ComputerName $Computer -Count 1 -Quiet -EA "Stop"){
		write-verbose "getting local group members on $Computer"
		foreach ($Group in $LocalGroups){
			$LocalGroup = LocalNTGroup $Computer $Group
			foreach ($member in $(ListMembers $LocalGroup)){
				Output $Computer $Group $member "ENUM" "Existing"
				}
			foreach ($AddID in $Add){
				try{
					$LocalGroup.Add("WinNT://" + $NTDomain + "/" + $AddID)
					$Action = "Added"
					}
				catch{
					write-debug "$AddID is not added"
					$Action = $Error[0].Exception.InnerException.Message.ToString().Trim()
					}
				Output $Computer $Group $AddID "ADDING" $Action
				}
			foreach ($RemID in $Remove){
				try{
					$LocalGroup.Remove("WinNT://" + $NTDomain + "/" + $RemID)
					$Action = "Removed"
					}
				catch{
					write-debug "$RemID is not added"
					$Action = $Error[0].Exception.InnerException.Message.ToString().Trim()
					}
				Output $Computer $Group $RemID "REMOVING" $Action
				}
			}
		}
	}
}#process

end{
$script:objReport | select computername, groupname, username, action, result | sort username
}

