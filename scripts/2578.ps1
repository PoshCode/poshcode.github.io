param([Microsoft.Exchange.WebServices.Data.FileAttachment]$attachment)
"Downloading Attachment"
$attachment.Load()
"Done"
$path = "C:\temp\"+$attachment.Name
"Writing to $path"
set-content -value $mm[1].Attachments[0].Content -enc byte -path $path
"Done"
ii $path
