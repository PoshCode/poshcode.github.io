# remove outlook duplicate notes and put the removed note in a file

$outlook = new-object -comobject outlook.application

$session = $outlook.session
$session.logon()

$olFoldersEnum = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
$notes = $session.getdefaultfolder($olFoldersEnum::olFolderNotes).items

Write-Host "Number of notes:" $notes.count

$noteStringModifiedDateMap = @{}
$notesToDelete = @()

Foreach ($e in $notes)
    { 
        $noteText = $e.Body
        $noteModified = $e.LastModificationTime
        if ($noteStringModifiedDateMap.ContainsKey($noteText))
        {
            $mapElement = $noteStringModifiedDateMap.Get_Item($noteText)
            if ($mapElement.LastModificationTime -gt $noteModified) # delete the new one
                { $notesToDelete += $mapElement } 
            else
                { $notesToDelete += $e }
        }
        else
        { $noteStringModifiedDateMap.Add($noteText, $e) }
     }
     
$notesToDelete | Export-Csv "C:\toDelete.csv"

foreach ($e in $notesToDelete)
{ $e.Delete() }

Write-Host "done!"
