   #                                           
  # #   #####  #    # # #    # #   ##   #    # 
 #   #  #    # ##  ## # ##   # #  #  #  ##   # 
#     # #    # # ## # # # #  # # #    # # #  # 
####### #    # #    # # #  # # # ###### #  # # 
#     # #    # #    # # #   ## # #    # #   ## 
#     # #####  #    # # #    # # #    # #    # 

## It's a quick little script to search instapaper csv


Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.ShowHelp = $true
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
}

## Get the CSV File
$fileName = Get-FileName -initialDirectory "~"

$csv = Import-Csv $fileName

## I use this for a broad search or topic search
$search = Read-Host "Search Topic: "
$csv | Where-Object {$_.Title -like "*" + $search + "*"} | ft title

## This is the refined search that will open IE
$search = Read-Host "Open Title: "
$result = $csv | Where-Object {$_.Title -like "*" + $search + "*"}
$ie = New-Object -comobject "InternetExplorer.Application"
$ie.visible = $true
$ie.navigate($result.url)
