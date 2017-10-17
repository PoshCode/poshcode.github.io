function Expand-ZipFile {
    param {
       $zipPath,
       $destination,
       [switch] $quiet
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipPath)
    $destinationFolder = $shellApplication.NameSpace($destination) 

    # CopyHere vOptions Flag # 4 - Do not display a progress dialog box. 
    # 16 - Respond with "Yes to All" for any dialog box that is displayed. 
    #$destinationFolder.CopyHere($zipPackage.Items(),20) 
    $total = $zipPackage.Items().Count
    $progress = 1;
    foreach ($zipFile in $zipPackage.Items()) {
        if(!$quiet) {
            Write-Progress "Extracting $zipPath" "Extracting $($zipFile.Name)" -id 0 -percentComplete (($progress/$total)*100)        
        }

        $destinationFolder.CopyHere($zipFile,20) 
        $progress++
    }
    if(!$quiet) {
        Write-Progress "Extracted $zipPath" "Extracted $total items" -id 0
    }
}
