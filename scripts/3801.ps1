<#
  Author:   Matt Schmitt
  Date:     11/28/12 
  Version:  1.0 
  From:     USA 
  Email:    ithink2020@gmail.com 
  Website:  http://about.me/schmittmatt
  Twitter:  @MatthewASchmitt
  
  Description
  A script for forwarding and unforwarding email for users in Office 365.  
#>

Write-Host ""
Write-Host ""
Write-Host "PowerShell Forward / Unforward Email Tool"
Write-Host ""
Write-Host ""
Write-Host "Connecting to the Office 365 Exchange PowerShell Session..."
Write-Host ""
Write-Host ""
Write-Host ""



# This block connects to the Office 365 Exchange PowerShell Session
$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic –AllowRedirection
Set-ExecutionPolicy remotesigned -Force
Import-PSSession $Session

# Clears Screen
cls

# Name and Description of Script
Write-Host ""
Write-Host "PowerShell Forward / Unforward Email Tool"
Write-Host ""
Write-Host "This is used for forwarding and unforwarding other user's email."
Write-Host ""
Write-Host ""


#Asks if you want to Forward or Unforward
Write-Host "Would you like to:"
Write-Host ""
Write-Host "    (1) Forward an Email"
Write-Host "    (2) Unforward an Email"
Write-Host "    (3) Exit"
Write-Host ""

#sets the selection to $todo
$todo = Read-Host "Please enter selection."

# Checkers for while loops
[int]$checker = 0
[int]$checker2 = 0

# This while loop checks to make sure user entered a valid entry
While ($checker -eq 0) {
    
    #Switch to run code based on user's entery
    Switch ($todo) {
        
        #Option 1 code
        "1" {
                
                # Clears Screen
                cls
                
                Write-Host ""
                Write-Host ""
                
                Write-Host "You have selected to Forward a user's email."
                
                Write-Host ""
                Write-Host ""
                
                #Ask for the username and sets it to $user
                $user = Read-Host "Enter username of the email account that needs to be forwarded" 
                Write-Host ""
                
                #Asks for the email address and sets it to $email
                $email = Read-Host "Enter the email address, where the user's email should be forwared to"
                Write-Host ""
                
                #Asks about if a copy should be left and sets it to $copy
                $copy = Read-Host "Would the user like a copy left in thier mailbox? (Y)es or (N)o?"
                
                # This while loop checks to make sure user entered a valid entry
                While ($checker2 -eq 0) {
                    
                    #Switch to run code based on user's entery
                    Switch ($copy) {
                        
                        # YES code
                        "Y" {
                                #sets $deliver as boolean and set variable to True
                                [bool]$deliver = $True
                                
                                #Adjusts Checker for While loop
                                $checker2 += 1
                            }
                        
                        #NO code
                        "N" {
                                #sets $deliver as boolean and set variable to False
                                [bool]$deliver = $False
                                
                                #Adjusts Checker for While loop
                                $checker2 += 1
                            }
                        
                        #Code to run if user enters invalid selection
                        default  {  
                                    #clears screen
                                    cls
                
                                    Write-Host "You have entered and incorrect Option."
                                    Write-Host ""
                                    
                                    #Asks about if a copy should be left and sets it to $cop
                                    $copy = Read-Host "Would the user like a copy left in thier mailbox? (Y)es or (N)o?"
                                 }
                }                   
                                                              
            }

                
                
                Write-Host "Now Forwarding $user's email to $email..."
                
                #This is the code that forwards the user's email
                Set-Mailbox $user –ForwardingSmtpAddress $email –DeliverToMailboxAndForward $deliver                            
                
                #Code to Disconnect from Office 365
                Remove-PSSession $Session
                
                Write-Host ""
                Write-Host "If no errors, email has been Forwarded.  If there is an error, review the error and try again."
                Write-Host ""
                Write-Host "Press any key to Exit."
                
                #Adjusts Checker for While loop
                $checker += 1
                
                #Code to wait for user to press a key.
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            }
        "2" {
                
                #Clears Screen
                cls
                
                Write-Host ""
                Write-Host ""
                
                Write-Host "You have selected to Unforward a user's email."
                Write-Host ""
                Write-Host ""
                
                #Ask for the username and sets it to $user
                $user = Read-Host "Enter username of the email account that needs to be forwarded" 
                Write-Host ""
                
                Write-Host "Now UnForwarding $user's email."
                
                #code for unforwarding email
                Set-Mailbox $user –ForwardingSmtpAddress $null                          
                
                #Code to Disconnect from Office 365
                Remove-PSSession $Session
                
                Write-Host ""
                Write-Host "If no errors, email has been UnForwarded.  If there is an error, review the error and try again."
                Write-Host ""
                Write-Host "Press any key to Exit."
                
                #Adjusts Checker for While loop
                $checker += 1
                
                #Code to wait for user to press a key.
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            }
        "3" {
                #Write-Host "You have selected Option 3" 
                
                #Code to Disconnect from Office 365
                Remove-PSSession $Session
                
                #Adjusts Checker for While loop
                $checker += 1
        
            }
            
        #Code to run if user enters invalid selection    
        default {
                
                #clears screen
                cls
                
                Write-Host "You have entered and incorrect selection.  Please enter number corresponding to your selection."
                Write-Host ""
                Write-Host "Would you like to:"
                Write-Host ""
                Write-Host "    (1) Forward an Email"
                Write-Host "    (2) Unforward an Email"
                Write-Host "    (3) Exit"
                Write-Host ""
                
                #Switch to run code based on user's entery
                $todo = Read-Host "Please enter selection."
        
            }
    }
}
