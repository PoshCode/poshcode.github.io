##################################################
# ENV Setup
##################################################
#-------------------------------------------------
# Initialize-ENV
#-------------------------------------------------
# Usage:	Used to build the execution ENV.
# **Function is not for interactive execution.**
#-------------------------------------------------
function Initialize-ENV {
	Import-Module .\WPK
	
	# Modify these variables to meet your needs.  The MinPasswordAge
	# and MaxPasswordAge variables can be pulled from AD.  But, for this 
	# version they are hardcoded. The ApplicationPath is the application
	# that you want to start after the PassMan screen.
	$Global:MinPasswordAge = 30 #Number of days to start warning.
	$Global:MaxPasswordAge = 40 #Number of days to force password change.
	$Global:ApplicationPath = "C:\Program Files\Windows NT\Accessories\wordpad.exe"
	}

##################################################
# Functions
##################################################
# Note: These functions are used to complete the various 
# 		automation tasks for this script.
#-------------------------------------------------
# Get-CurrentIdentity
#-------------------------------------------------
# Usage:	Used to get the identiy for the currently
#			logged on user.
#-------------------------------------------------
function Get-CurrentIdentity {
	$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent() 
	New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
	}
	
function Get-ADUser {
	param ([string]$UserName)
	$ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
	$Root = [ADSI] "LDAP://$($ADDomain.Name)"
	$Searcher = New-Object System.DirectoryServices.DirectorySearcher $Root
	$Searcher.Filter = "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$UserName))"
	$Searcher.FindOne()
	}

##################################################
# Main
##################################################
try {
	Initialize-ENV

	$Global:UserIdentity = Get-CurrentIdentity
	$Global:UsersAMAccountName = (($UserIdentity.Identity.Name).Split("\"))[1]
	$Global:UserObject = Get-ADUser $UsersAMAccountName
	$Global:PwdLastSet = [datetime]::FromFileTime($UserObject.properties.pwdlastset[0])
	$Global:PwdLastSetDays = (([System.DateTime]::Now) - $PwdLastSet).TotalDays
	$Global:PwdExpire = "{0:N0}" -f ($MaxPasswordAge - $PwdLastSetDays)
	$Global:ExistingPassword
	$Global:NewPassword1
	$Global:NewPassword2

	if ($PwdLastSetDays -ge $MinPasswordAge){
		New-Window -Title "Password change for $($UsersAMAccountName)" `
			-WindowStartupLocation CenterScreen `
			-Width 320 -Height 255 -Show `
			-ResizeMode NoResize {
			$BColor = New-SolidColorBrush -Color "#E0E0E0"
			New-Grid -Rows 'Auto', 'Auto', 'Auto', 'Auto', 'Auto', 'Auto' `
				-Columns 'Auto', '150' -Background $BColor {
				New-Label -Name rtbHeader `
					-VerticalContentAlignment Top `
					-HorizontalContentAlignment Left `
					-Row 0 -Column 0 -ColumnSpan 2 `
					-Margin "10 10 0 0" -Width 320 -Height 30 `
					-Foreground Red -FontWeight Bold
				New-TextBlock -Name rtbMessage `
					-HorizontalAlignment Left `
					-VerticalContentAlignment Top `
					-HorizontalContentAlignment Left `
					-Row 1 -Column 0 -ColumnSpan 2 `
					-Margin "10 0 0 0" -Width 275 -Height 80 `
					-Foreground Red -FontWeight Bold -TextWrapping "0"
				New-Label -Content "Existing password:" `
					-Row 2 -Column 0 -Margin "10 0 0 0"
				New-PasswordBox -Name pbExistingPassword `
					-Row 2 -Column 1 -Width 130 `
					-VerticalContentAlignment Center `
					-HorizontalAlignment Left -PasswordChar "*" `
					-On_PasswordChanged {$pbNewPassword1.IsEnabled = $True; $pbNewPassword2.IsEnabled = $True; $btnChange.IsEnabled =$True; $ExistingPassword = $this.password}
				New-Label -Content "New password:" `
					-Row 3 -Column 0 -Margin "10 0 0 0"
				New-PasswordBox -Name pbNewPassword1 `
					-Row 3 -Column 1 -Width 130 `
					-VerticalContentAlignment Center `
					-HorizontalAlignment Left -PasswordChar "*" `
					-On_PasswordChanged {$NewPassword1 = $this.password}
				New-Label -Content "Retype New password:" `
					-Row 4 -Column 0 -Margin "10 0 0 0"
				New-PasswordBox -Name pbNewPassword2 `
					-Row 4 -Column 1 -Width 130 `
					-VerticalContentAlignment Center `
					-HorizontalAlignment Left -PasswordChar "*" `
					-On_PasswordChanged {$NewPassword2 = $this.password}
				New-Button -Name btnChange -Content "_Change" `
					-HorizontalAlignment Left `
					-Row 5 -Column 2 `
					-Margin "0 10 0 0" -Width 50
				New-Button -Name btnCancel -Content "_Cancel" `
					-On_Click {$Window.Close(); Start-Process $ApplicationPath} `
					-HorizontalAlignment Left `
					-Row 5 -Column 2 `
					-Margin "55 10 0 0" -Width 50
				}
			} -On_Loaded {
				if (($PwdLastSetDays -ge $MinPasswordAge) -or ($PwdLastSetDays -ge $MaxPasswordAge)) {
					$rtbHeader = $Window | Get-ChildControl rtbHeader
					$rtbMessage = $Window | Get-ChildControl rtbMessage
					$pbNewPassword1 = $Window | Get-ChildControl pbNewPassword1
					$pbNewPassword2 = $Window | Get-ChildControl pbNewPassword2
					$btnChange = $Window | Get-ChildControl btnChange
					$btnCancel = $Window | Get-ChildControl btnCancel
					
					# Disable relevate controls
					$pbNewPassword1.IsEnabled = $false
					$pbNewPassword2.IsEnabled = $false
					$btnChange.IsEnabled = $false
				
					# If we haven't gotten to the MaxPasswordAge The user can change their password.
					if ($PwdLastSetDays -ge $MinPasswordAge) {
						$rtbHeader.Content = "***WARNING***"
						$rtbMessage.Text = "Your password will expire in $($PwdExpire) days. Please change your password now or click Cancel to continue."
						}
					
					# If we are at the MaxPasswordAge. The user must change their password.
					if ($PwdLastSetDays -ge $MaxPasswordAge) {
						$rtbHeader.Content = "***WARNING***"
						$rtbMessage.Text = "Your password is about to expire. You must change your password now."
						$btnCancel.IsEnabled = $false
						}
					
					# Here is the password change logic.
					$Command = {if (!($NewPassword1 -eq $NewPassword2)){
									$rtbHeader.Foreground = "Red"
									$rtbHeader.Content = "***WARNING***"
									$rtbMessage.Foreground = "Red"
									$rtbMessage.Text = "Passwords do not match, please try again."	
									}
								else {
									$rtbHeader.Foreground = "Black"
									$rtbHeader.Content = "Progress..."
									$rtbMessage.Foreground = "Black"
									$rtbMessage.Text = "Please wait, trying to change password."
									
									try{
										$User = $UserObject.GetDirectoryEntry()
										$User.psbase.invoke("ChangePassword",$ExistingPassword, $NewPassword1)
										
										# Nothing to do, start application
										Start-Process $ApplicationPath
										}
									catch {
										$rtbHeader.Foreground = "Red"
										$rtbHeader.Content = "***ERROR***"
										$rtbMessage.Foreground = "Red"
										$rtbMessage.Text = $_.Exception.InnerException.Message
											}
									}
								}
					$btnChange.Add_Click($Command)
					}
				}
			}
		else{
			# Nothing to do, start application
			Start-Process $ApplicationPath
			}

	}
catch {
	# Nothing to do, start application
	Start-Process $ApplicationPath
	}
	
	
	

