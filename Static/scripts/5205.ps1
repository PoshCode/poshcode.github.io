#REQUIRES -version 4
set-strictmode -version 2

#Enable Verbosity
#$VerbosePreference = Continue



### VARIABLES AND OPTIONS
$plexHost = "localhost"
$plexPort = "32400"
$plexSection = $args[1]


#Log File
start-transcript "$($env:APPDATA)\PlexMediaAutoRetire.log" -append

#Choose an action to take on flagged files:
# "Archive" - Moves files to $optArchiveDir for later deletion if chosen
# "Delete" - Deletes the files
# "Test" - Only shows what files will be deleted. Default if nothing else specified
$optFlaggedVideoAction = $args[0]

#Show Usage if incorrect
if (!$Plexsection) {write-host "Usage: powershell.exe PlexMediaAutoRetire.ps1 [delete|archive|test] <PlexSectionToProcess>";exit 1}
#Show Usage if incorrect
if (!$optFlaggedVideoAction) {write-host "Usage: powershell.exe PlexMediaAutoRetire.ps1 [delete|archive|test] <PlexSectionToProcess>";exit 1}


#When Deleting/Archiving, move the entire folder instead of just individual files for cleanup. This assumes you are using Plex standard structure. BE CAREFUL. ONLY USE FOR MOVIES.
$optMoveFlaggedVideoDir = $false

#Failsafe
#Set this to true when finished testing to actually execute the changes. All actions do -whatif until this is set
#BE CAREFUL
$optDoAction = $true

#Set this to true to show verbose logging of all file actions
$optActionVerbose = $true

#Set to where you want files to be moved with the "Archive" Action. Places them in %TEMP% if not specified.
$optArchiveDir = "D:\Archive\"

#Set to $true to exclude files that are "On Deck"
$optExcludeOnDeck = $true

###STEP 0: Script Setup

#Prepare the additional arguments for actions
$FILEACTIONARGS = @{}
$FILEACTIONARGS += @{Whatif=(!$optDoAction)}
$FILEACTIONARGS += @{Verbose=$optActionVerbose}


###
###STEP 1:Get List of Candidate Videos for Deletion
###

#Build Request URL to REST API to retrieve videos
$uriLibrary = "http://"+$plexHost+":"+$plexPort+"/library/"
$uriSection = $uriLibrary + "sections/$plexSection/"
$uriRecentlyViewed = $uriSection + "recentlyViewed"
$uriOnDeck = $urilibrary + "onDeck"


#Get the list of watched videos and onDeck videos
try {
    $watchedVideos = (invoke-restmethod $uriRecentlyViewed).mediacontainer.video
    $ondeckVideos = (invoke-restmethod $uriOnDeck -erroraction silentlycontinue).mediacontainer.video

}
catch [Exception] {write-output "No New Watched Videos or connectivity error, quitting.";exit 1}
    

###
###STEP 2:Analyze videos and determine which videos will be deleted
###

$flaggedVideos = @()
foreach ($watchedVideo in $watchedVideos) {
    #TODO: Analyze the file

    #Skip if the video is On Deck (partly watched)
    if ( ($ondeckVideos).key -contains $watchedvideo.key ) {write-verbose "$($watchedvideo.title) still on deck. Skipping...";continue}

    #Get the parts of all related media files (including streaming optimizations). This works recursively
    $watchedVideoFiles = $watchedVideo.media.part.file
    
    $flaggedVideos += $watchedVideoFiles

}

###
###STEP 3:Take action on the video files
###
switch ($optFlaggedVideoAction) {
    "Delete" {
        $flaggedVideos | foreach {
            if (test-path $_) {
                remove-item -path "$_" @FILEACTIONARGS
            }
        }
    }

    "Archive" {
        #Get the root of the library, used to determine relative paths for archiving. This is convoluted and probably could be done better.
        $libraryPath = ((invoke-restmethod ($uriLibrary+"sections")).mediacontainer.directory | where {$_.key -eq $plexSection}).location.path
        
        #Set the path location to the library. Required for Relative Resolve-Path to work
        set-location $librarypath
        
        foreach ($flaggedVideo in $flaggedVideos) {
            if (test-path $flaggedVideo) {
                #Get the path relative to the document library to preserve structure
                $videoRelativePath = resolve-path $flaggedVideo -relative

                #Construct the new destination path
                $archivePath = "$optArchiveDir\$(split-path $libraryPath -leaf)\$videoRelativePath"

                #Create the directory if it doesn't exist
                $archivePathParent = split-path $archivePath -parent
                $archiveDestination = mkdir $archivePathParent -force @FILEACTIONARGS

                
                if ($optMoveFlaggedVideoDir) {
                    $flaggedVideo = split-path $flaggedVideo -parent
                    $archivePath = $archivepathparent
                }
                
                #Move either the file or the whole directory
                move-item -path "$flaggedVideo" -destination "$archivePath" -force @FILEACTIONARGS
                
                
            }
        }
    }

    default {
        foreach ($flaggedvideo in $flaggedVideos) {
            if (test-path $flaggedvideo) {write-host "Would Delete $flaggedvideo"}
        }
    }
}

#Refresh the media library after deleting files to remove them from the interface
$LibraryRefreshResult = invoke-restmethod $uriSection+"Refresh"

#Stop Logging

stop-transcript
