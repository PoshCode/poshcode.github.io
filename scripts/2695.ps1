#connect to outlook
$GetOutlook = New-Object -com "Outlook.Application"; 
$olName = $GetOutlook.GetNamespace("MAPI")
$olxEmailFolder = $olName.GetDefaultFolder(‘olFolderInbox’)
$olxEmailFolder.Name
$olxEmailItem = $olxemailFolder.items
#show unread emails in inbox
$olxEmailItem | ?{$_.Unread -eq $True} | select SentOn, SenderName, Subject, Body | Format-Table -auto
#go through each subfolder and get name
$SubFolders = $olxEmailFolder.Folders
ForEach($Folder in $SubFolders)
{
	$Folder.Name
	$SubfolderItem = $Folder.Items
	$EmailCount = 1
#create status bar for each subfolder
	ForEach($Email in $SubfolderItem)
	{
		Do
		{
			Write-Progress -Activity "Checking folder" -status $Folder.Name -

PercentComplete ($EmailCount/$Folder.Items.Count*100)
			$EmailCount++
		}
#show unread emails from subfolders
		While($EmailCount -le $Folders.Item.Count)
	$Email | ?{$_.Unread -eq $True} | select SentOn, SenderName, Subject, Body | Format-Table -

Auto
	}
}
#connect to tasks
$olxTasksFolder = $olName.GetDefaultFolder(‘olFolderTasks’)
$olxTaskItems = $olxTasksFolder.items
$TaskCount = 1
#create task array
$TaskList = @()
ForEach($TaskItem in $olxTaskItems)
{
#create status bar for tasks
	Do
	{
		Write-Progress -Activity "Checking" -status "Tasks" -PercentComplete ($Taskcount/

$olxTasksFolder.Items.count*100)
		$TaskCount++
	}
#add each incomplete tash to array
	While($TaskCount -le $olxTaskFolder.Items.Count)
	If($TaskItem.Complete -eq $False)
	{
	$TaskList+=New-Object -TypeName PSObject -Property @{
	Subject=$TaskItem.Subject
	DateCreated=$TaskItem.CreationTime
	Percent=$TaskItem.PercentComplete
	Due=$TaskItem.DueDate
	}}
}
#show task array to screen
$TaskList | Sort DueDate -descending | Format-Table -Auto
