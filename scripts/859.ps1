#requires -version 2.0

# Example
#
# ps> . .\watch-folder.ps1
# ps> watch-folder c:\temp
# ps> "foo" > c:\temp\test.txt
# ps> $table
# ps> (shows changes)

function watch-folder {
    param([string]$folder)
    
    $fsw = new-object System.IO.FileSystemWatcher
    $fsw.Path = $folder
    
    # stores changes to $folder
    $global:table = new-object system.data.datatable
    [void] $table.Columns.Add("FullPath", [string])
    [void] $table.Columns.Add("ChangeType", [string])
    
    $action = {
        [console]::beep(440,10)
        [void] $table.Rows.Add($eventArgs.FullPath, $eventArgs.ChangeType)
    }
        
    [void] Register-ObjectEvent -InputObject $fsw -EventName Created -Action $action
    [void] Register-ObjectEvent -InputObject $fsw -EventName Changed -Action $action
    [void] Register-ObjectEvent -InputObject $fsw -EventName Deleted -Action $action
}
