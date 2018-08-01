# Add the Active Directory bits and not complain if they're already there
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# set default password
# change pass@word1 to whatever you want the account passwords to be
$defpassword = (ConvertTo-SecureString "pass@word1" -AsPlainText -force)

# Get domain DNS suffix
$dnsroot = '@' + (Get-ADDomain).dnsroot

# Import the file with the users. You can change the filename to reflect your file
$users = Import-Csv .\users.csv

foreach ($user in $users) {
        if ($user.manager -eq "") # In case it's a service account or a boss
            {
                try {
                    New-ADUser -SamAccountName $user.SamAccountName -Name ($user.FirstName + " " + $user.LastName) `
                    -DisplayName ($user.FirstName + " " + $user.LastName) -GivenName $user.FirstName -Surname $user.LastName `
                    -EmailAddress ($user.SamAccountName + $dnsroot) -UserPrincipalName ($user.SamAccountName + $dnsroot) `
                    -Title $user.title -Enabled $true -ChangePasswordAtLogon $false -PasswordNeverExpires  $true `
                    -AccountPassword $defpassword -PassThru `
                    }
                catch [System.Object]
                    {
                        Write-Output "Could not create user $($user.SamAccountName), $_"
                    }
            }
            else
             {
                try {
                    New-ADUser -SamAccountName $user.SamAccountName -Name ($user.FirstName + " " + $user.LastName) `
                    -DisplayName ($user.FirstName + " " + $user.LastName) -GivenName $user.FirstName -Surname $user.LastName `
                    -EmailAddress ($user.SamAccountName + $dnsroot) -UserPrincipalName ($user.SamAccountName + $dnsroot) `
                    -Title $user.title -manager $user.manager `
                    -Enabled $true -ChangePasswordAtLogon $false -PasswordNeverExpires  $true `
                    -AccountPassword $defpassword -PassThru `
                    }
                catch [System.Object]
                    {
                        Write-Output "Could not create user $($user.SamAccountName), $_"
                    }
             }
        # Put picture part here.
        $filename = "$($user.SamAccountName).jpg"
        Write-Output $filename

        if (test-path -path $filename)
            {
                Write-Output "Found picture for $($user.SamAccountName)"

                $photo = [byte[]](Get-Content $filename -Encoding byte)
                Set-ADUser $($user.SamAccountName) -Replace @{thumbnailPhoto=$photo} 
            }
   }

