## This script will search a PST file and a Mailbox for all items that have either the text 'How to' in the subject,
## a zip file attachment, or with the word 'download' present in the body more than 3 times.
## for any items found, it will save them to the file system as xml and then will delete them.

## get a mapi session to work with.
$profile = "Outlook"
$sess = new-MapiSession $profile

## we'll work first against the mailbox in the profile
$store = get-MapiStore -GetPrimaryStore

## we'll only be concerned with the Inbox
## get-MapiFolder can get to the standard folders regardless of name, great for non-English languages.
## or, the same could be done by using a path value:  //inbox
$inbox = get-MapiFolder $store Inbox

## here we'll execute the search for the items and store the results
## the search string uses the -has operator for the subject which means the text 'how to' can appear anywhere in the subject
## the -ew operator means 'Ends With'
## and the -match operator means to use a .NET regular expression pattern
$found = search-MapiItems $inbox "PR_SUBJECT -has how to -or attach(PR_ATTACH_FILENAME -ew .zip) -or PR_BODY -match download{4,}"

## now, for each item found, export it out as an xml file.
foreach ($item in $found) {
	$mItem = get-MapiItem $inbox $item
	export-MapiXML $mItem "c:\exported\folder\$($item.Subject).xml"
	
	## now that it's been exported, delete the item
	remove-MapiItem $inbox $item
}

## it's always good to clean up handles and resource when done...
$inbox.MapiObject.Dispose()
$store.MapiObject.Dispose()

## now lets open a PST file and do the same thing
## we'll reuse the same session and add a PST file to our session
$pstStore = open-MapiPST $sess "c:\path\to\file.pst"

## similar option as before, but this time we'll get a specific folder
$folder = get-MapiFolder $pstStore //stuff/2016

## search the folder
$items = search-MapiItems $folder "PR_SUBJECT -has how to -or attach(PR_ATTACH_FILENAME -ew .zip) -or PR_BODY -match download{4,}"

## now, for each item found, export it out as an xml file.
foreach ($item in $found) {
	$mItem = get-MapiItem $inbox $item
	export-MapiXML $mItem "c:\exported\folder\$($item.Subject).xml"
	
	## now that it's been exported, delete the item
	remove-MapiItem $inbox $item
}

## clean up
$folder.MapiObject.Dispose()
$pstStore.MapiObject.Dispose()

## close and logoff the session
remove-MapiSession $sess



