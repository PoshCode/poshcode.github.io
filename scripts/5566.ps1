$in_file = "C:\*LOCATION_TO_YOUR_FILE*\users.csv"
$out_file = "C:\*LOCATION_TO_YOUR_FILE*\users_out.csv"

$out_data = @()

ForEach ($row in (Import-Csv $in_file)) {
    If ($row.'user') {
        $out_data += Get-ADUser $row.'user' -Properties displayname
    }
} 

$out_data | 
Select SamAccountName,Mail,Name,Surname,DisplayName | 
Export-Csv -Path $out_file -NoTypeInformation
