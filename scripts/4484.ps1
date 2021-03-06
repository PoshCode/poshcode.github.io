#############################################################################################
#
# NAME: Show-WindowsUpdatesLocal.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:22/09/2013
#
# COMMENTS: Load function to show all windows updates locally
#
# USAGE:  Show-WindowsUpdatesLocal
#         Show-WindowsUpdatesLocal| Select Date, HotfixID, Result|Format-Table -AutoSize
#         Show-WindowsUpdatesLocal|Where-Object {$_.Result -eq 'Failed'} |Select Date, HotfixID, Result,Title|Format-Table -AutoSize
#         Show-WindowsUpdatesLocal|Format-Table -AutoSize|Out-File c:\temp\updates.txt
#         Show-WindowsUpdatesLocal|Export-Csv c:\temp\updates.csv
#        

Function Show-WindowsUpdatesLocal
{
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher
    $History = $Searcher.GetTotalHistoryCount()
    $Updates =  $Searcher.QueryHistory(1,$History)

    # Define a new array to gather output
    $OutputCollection=  @()
    
    Foreach ($update in $Updates)
        {
        $Result = $null
        Switch ($update.ResultCode)
            {
            0 { $Result = 'NotStarted'}
            1 { $Result = 'InProgress' }
            2 { $Result = 'Succeeded' }
            3 { $Result = 'SucceededWithErrors' }
            4 { $Result = 'Failed' }
            5 { $Result = 'Aborted' }
            default { $Result = $_ }
            }
    $string = $update.title
    $Regex = “KB\d*”
    $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }
    $output = New-Object -TypeName PSobject
    $output | add-member NoteProperty “Date” -value $Update.Date
    $output | add-member NoteProperty “HotFixID” -value $KB.‘ $_.Matches ‘.Value
    $output | Add-Member NoteProperty "Result" -Value $Result
    $output | add-member NoteProperty “Title” -value $string
    $output | add-member NoteProperty “Description” -value $update.Description

     $OutputCollection += $output
 
    }

    $OutputCollection
    }
