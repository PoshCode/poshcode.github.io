
function OnApplicationLoad
{
	#TODO: Add custom code to validate application load
	#TODO: Add Snapins here
	Import-Module ActiveDirectory
	return $true #return true for success or false for failure
	
}

function OnApplicationExit
{
	#TODO: Add custom code clean up on application exit
}

$textbox1_TextChanged = {
	#TODO: Place custom script here
}

$handler_btnQuery_Click = {
	$btnQuery.Text = "Processing..."
	$btnQuery.Enabled = $false
	$stringBuilder3 = New-Object System.Text.StringBuilder
	$text3 = "Querying remote computers. This can take a while, please wait..."
	$stringBuilder3.AppendLine($text3)
	$stringBuilder3.AppendLine("")
	$textboxResults.Text = $stringBuilder3.ToString()
	
	function Get-UserInformation
	{
		Param
		(
			# -Identity, usually samaccountname etc.
			[Parameter(Mandatory = $true,
					   ValueFromPipelineByPropertyName = $true,
					   Position = 0)]
			$identity
		)
		
		Begin
		{
			
		}
		
		Process
		{
			$ManagedUserList = @()
			try
			{
				$ADUserData.managedobjects | ForEach-Object -process {
					$objManagedUserObject = New-Object System.Object
					$QueryUser = Get-ADUser -Identity "$($txtUserName.Text)" -Properties Name, PasswordExpired, LockedOut, Enabled, LastBadPasswordAttempt | Select-Object -Property Name, PasswordExpired, LockedOut, Enabled, LastBadPasswordAttempt
					
					$Firstname = $QueryUser.Name.Split(" ")[1]
					$Surname = $QueryUser.Name.Split(" ")[0]
					$Username = $Firstname + " " + $Surname
				}
			}
			catch
			{
				Write-Output "No such user found in Active Directory"
			}
		}
		
		End
		{
			return $ManagedUserList
		}
	}
	
	function Get-UserComputers
	{
		Param
		(
			# -Identity, usually samaccountname etc.
			[Parameter(Mandatory = $true,
					   ValueFromPipelineByPropertyName = $true,
					   Position = 0)]
			$identity
		)
		
		Begin
		{
			try
			{
				$ADUserData = Get-ADUser -Identity $identity -Properties managedobjects
			}
			catch
			{
				$text = Write-Output "Error retrieving data from AD"
				#break
			}
			
		}
		Process
		{
			
			$ManagedObjectsList = @()
			$ADUserData.managedobjects | foreach -process {
				$objManagedObject = New-Object System.Object
				
				#Reset Error Variable
				$Error = ""
				
				#Clean the output
				$_ = (($_ -replace ('^CN\=', '')) -replace (',.*', ''))
				
				#Add the computers name to a list.
				if ($_ -like "*" -and $($_.length) -lt 16)
				{
					#Check if PC is available in AD
					try
					{
						$PC = Get-ADComputer -Identity $_ -Properties Operatingsystem, Enabled, IPV6Address, IPV4Address, LockedOut, LastBadPasswordAttempt | Select-Object -Property Operatingsystem, Enabled, IPV6Address, IPV4Address, LockedOut, LastBadPasswordAttempt
					}
					catch
					{
						Write-Output "No such object found in Active Directory."
						Write-Output ""
						Write-Output "Errorstack: $_"
						Write-Output ""
						Write-Output ""
						$Status = "Error"
					}
					if ($Status -ne "Error")
					{
						# Get information about the user being queried about
						try
						{
							$User = Get-ADUser -Identity "$($txtUserName.Text)" -Properties Name, PasswordExpired, LockedOut, Enabled, LastBadPasswordAttempt | Select-Object -Property Name, PasswordExpired, LockedOut, Enabled, LastBadPasswordAttempt
						}
						catch
						{
							Write-Output "No such user found in Active Directory"
						}
						
						$objManagedObject | Add-Member -Type NoteProperty -Name Computername -Value "$_ `n"
						
						if ((Test-Connection -Count 1 -ComputerName $_ -Quiet))
						{
							$IP = Test-Connection -Count 1 -ComputerName $_
							try
							{
								Function Get-LastLogon
								{
<#

.SYNOPSIS
	This function will list the last user logged on or logged in.

.DESCRIPTION
	This function will list the last user logged on or logged in.  It will detect if the user is currently logged on
	via WMI or the Registry, depending on what version of Windows is running on the target.  There is some "guess" work
	to determine what Domain the user truly belongs to if run against Vista NON SP1 and below, since the function
	is using the profile name initially to detect the user name.  It then compares the profile name and the Security
	Entries (ACE-SDDL) to see if they are equal to determine Domain and if the profile is loaded via the Registry.

.PARAMETER ComputerName
	A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

.PARAMETER FilterSID
	Filters a single SID from the results.  For use if there is a service account commonly used.
	
.PARAMETER WQLFilter
	Default WQLFilter defined for the Win32_UserProfile query, it is best to leave this alone, unless you know what
	you are doing.
	Default Value = "NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'"
	
.EXAMPLE
	$Servers = Get-Content "C:\ServerList.txt"
	Get-LastLogon -ComputerName $Servers

	This example will return the last logon information from all the servers in the C:\ServerList.txt file.

	Computer          : SVR01
	User              : WILHITE\BRIAN
	SID               : S-1-5-21-012345678-0123456789-012345678-012345
	Time              : 9/20/2012 1:07:58 PM
	CurrentlyLoggedOn : False

	Computer          : SVR02
	User              : WILIHTE\BRIAN
	SID               : S-1-5-21-012345678-0123456789-012345678-012345
	Time              : 9/20/2012 12:46:48 PM
	CurrentlyLoggedOn : True
	
.EXAMPLE
	Get-LastLogon -ComputerName svr01, svr02 -FilterSID S-1-5-21-012345678-0123456789-012345678-012345

	This example will return the last logon information from all the servers in the C:\ServerList.txt file.

	Computer          : SVR01
	User              : WILHITE\ADMIN
	SID               : S-1-5-21-012345678-0123456789-012345678-543210
	Time              : 9/20/2012 1:07:58 PM
	CurrentlyLoggedOn : False

	Computer          : SVR02
	User              : WILIHTE\ADMIN
	SID               : S-1-5-21-012345678-0123456789-012345678-543210
	Time              : 9/20/2012 12:46:48 PM
	CurrentlyLoggedOn : True

.LINK
	http://msdn.microsoft.com/en-us/library/windows/desktop/ee886409(v=vs.85).aspx
	http://msdn.microsoft.com/en-us/library/system.security.principal.securityidentifier.aspx

.NOTES
	Author:	 Brian C. Wilhite
	Email:	 bwilhite1@carolina.rr.com
	Date: 	 "09/20/2012"
	Updates: Added FilterSID Parameter
	         Cleaned Up Code, defined fewer variables when creating PSObjects
	ToDo:    Clean up the UserSID Translation, to continue even if the SID is local
#>
									
									[CmdletBinding()]
									param (
										[Parameter(Position = 0, ValueFromPipeline = $true)]
										[Alias("CN", "Computer")]
										[String[]]$ComputerName = "$env:COMPUTERNAME",
										[String]$FilterSID,
										[String]$WQLFilter = "NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'"
									)
									
									Begin
									{
										#Adjusting ErrorActionPreference to stop on all errors
										$TempErrAct = $ErrorActionPreference
										$ErrorActionPreference = "Stop"
										#Exclude Local System, Local Service & Network Service
									}#End Begin Script Block
									
									Process
									{
										Foreach ($Computer in $ComputerName)
										{
											$Computer = $Computer.ToUpper().Trim()
											Try
											{
												#Querying Windows version to determine how to proceed.
												$Win32OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
												$Build = $Win32OS.BuildNumber
												
												#Win32_UserProfile exist on Windows Vista and above
												If ($Build -ge 6001)
												{
													If ($FilterSID)
													{
														$WQLFilter = $WQLFilter + " AND NOT SID = `'$FilterSID`'"
													}#End If ($FilterSID)
													$Win32User = Get-WmiObject -Class Win32_UserProfile -Filter $WQLFilter -ComputerName $Computer
													$LastUser = $Win32User | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1
													$Loaded = $LastUser.Loaded
													$Script:Time = ([WMI]'').ConvertToDateTime($LastUser.LastUseTime)
													
													#Convert SID to Account for friendly display
													$Script:UserSID = New-Object System.Security.Principal.SecurityIdentifier($LastUser.SID)
													$User = $Script:UserSID.Translate([System.Security.Principal.NTAccount])
												}#End If ($Build -ge 6001)
												
												If ($Build -le 6000)
												{
													If ($Build -eq 2195)
													{
														$SysDrv = $Win32OS.SystemDirectory.ToCharArray()[0] + ":"
													}#End If ($Build -eq 2195)
													Else
													{
														$SysDrv = $Win32OS.SystemDrive
													}#End Else
													$SysDrv = $SysDrv.Replace(":", "$")
													$Script:ProfLoc = "\\$Computer\$SysDrv\Documents and Settings"
													$Profiles = Get-ChildItem -Path $Script:ProfLoc
													$Script:NTUserDatLog = $Profiles | ForEach-Object -Process { $_.GetFiles("ntuser.dat.LOG") }
													
													#Function to grab last profile data, used for allowing -FilterSID to function properly.
													function GetLastProfData ($InstanceNumber)
													{
														$Script:LastProf = ($Script:NTUserDatLog | Sort-Object -Property LastWriteTime -Descending)[$InstanceNumber]
														$Script:UserName = $Script:LastProf.DirectoryName.Replace("$Script:ProfLoc", "").Trim("\").ToUpper()
														$Script:Time = $Script:LastProf.LastAccessTime
														
														#Getting the SID of the user from the file ACE to compare
														$Script:Sddl = $Script:LastProf.GetAccessControl().Sddl
														$Script:Sddl = $Script:Sddl.split("(") | Select-String -Pattern "[0-9]\)$" | Select-Object -First 1
														#Formatting SID, assuming the 6th entry will be the users SID.
														$Script:Sddl = $Script:Sddl.ToString().Split(";")[5].Trim(")")
														
														#Convert Account to SID to detect if profile is loaded via the remote registry
														$Script:TranSID = New-Object System.Security.Principal.NTAccount($Script:UserName)
														$Script:UserSID = $Script:TranSID.Translate([System.Security.Principal.SecurityIdentifier])
													}#End function GetLastProfData
													GetLastProfData -InstanceNumber 0
													
													#If the FilterSID equals the UserSID, rerun GetLastProfData and select the next instance
													If ($Script:UserSID -eq $FilterSID)
													{
														GetLastProfData -InstanceNumber 1
													}#End If ($Script:UserSID -eq $FilterSID)
													
													#If the detected SID via Sddl matches the UserSID, then connect to the registry to detect currently loggedon.
													If ($Script:Sddl -eq $Script:UserSID)
													{
														$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"Users", $Computer)
														$Loaded = $Reg.GetSubKeyNames() -contains $Script:UserSID.Value
														#Convert SID to Account for friendly display
														$Script:UserSID = New-Object System.Security.Principal.SecurityIdentifier($Script:UserSID)
														$User = $Script:UserSID.Translate([System.Security.Principal.NTAccount])
													}#End If ($Script:Sddl -eq $Script:UserSID)
													Else
													{
														$User = $Script:UserName
														$Loaded = "Unknown"
													}#End Else
													
												}#End If ($Build -le 6000)
												
												#Creating Custom PSObject For Output
												New-Object -TypeName PSObject -Property @{
													Computer = $Computer
													User = $User
													SID = $Script:UserSID
													Time = $Script:Time
													CurrentlyLoggedOn = $Loaded
												} | Select-Object Computer, User, SID, Time, CurrentlyLoggedOn
												
											}#End Try
											
											Catch
											{
												If ($_.Exception.Message -Like "*Some or all identity references could not be translated*")
												{
													Write-Warning "Unable to Translate $Script:UserSID, try filtering the SID `nby using the -FilterSID parameter."
													Write-Warning "It may be that $Script:UserSID is local to $Computer, Unable to translate remote SID"
												}
												Else
												{
													Write-Warning $_
												}
											}#End Catch
											
										}#End Foreach ($Computer in $ComputerName)
										
									}#End Process
									
									End
									{
										#Resetting ErrorActionPref
										$ErrorActionPreference = $TempErrAct
									}#End End
									
								}# End Function Get-LastLogon
								# Filter out built in system acccounts SID when compiling code with system account credentials
								$Lastlogon = Get-LastLogon -ComputerName $_ -FilterSID S-1-5-21-1547161642-1844823847-682003330-143460
								$Lastlogondate = $LastLogon.Time.Year.ToString() + "-" + $LastLogon.Time.Month.ToString() + "-" + $LastLogon.Time.Day.ToString() + " " + $LastLogon.Time.Hour.ToString() + ":" + $LastLogon.Time.Minute.ToString()
								$DaysSinceLastLogon = New-TimeSpan -Start $Lastlogon.time -End (Get-Date) | Select-Object -ExpandProperty Days
							}
							catch
							{
								$Lastlogondate = $null
							}
							
							try
							{
								$PCModel = Get-WmiObject Win32_ComputerSystem -Property Model -ComputerName $_ | Select-Object -ExpandProperty Model
							}
							catch
							{
								$PCModel = $Null
							}
							
							$objManagedObject | Add-Member -Type NoteProperty -Name Connection -Value "Connected `t `n"
							
							if ($Lastlogon -eq $null)
							{
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Last Logon Date' -Value "Access Denied `t `n"
								$objManagedObject | Add-Member -Type NoteProperty -Name 'Last Logged On User' -Value "Access Denied `t `n"
								$objManagedObject | Add-Member -Type NoteProperty -Name 'Currently Logged On' -Value "Access Denied `t `n"
							}
							else
							{
								try
								{
									$UserName = $Null
									$UserName = $Lastlogon.User.Value.Split("\")
									$Fullname = Get-ADUser -Identity $Username[1] -Properties Name | Select-Object -ExpandProperty Name
									$Firstname = $Fullname.Split(" ")[1]
									$Surname = $Fullname.Split(" ")[0]
									$NewUsername = $Firstname + " " + $Surname
									$Lastlogondate = $LastLogon.Time.Year.ToString() + "-" + $LastLogon.Time.Month.ToString() + "-" + $LastLogon.Time.Day.ToString() + " " + $LastLogon.Time.Hour.ToString() + ":" + $LastLogon.Time.Minute.ToString()
								}
								catch
								{
									$NewUsername = $null
									$Username = $Null
									$Lastlogondate = $null
								}
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Last Logged On' -Value "Username: $($Username[1]) `t Real name: $NewUsername `n"
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Last Logon Date' -Value "$LastLogonDate `t `n"
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Currently Logged On' -Value "$($Lastlogon.CurrentlyLoggedOn) `t `n"

								
								if ($Lastlogon.CurrentlyLoggedOn -eq $true)
								{
									$Lastlogondate = $LastLogon.Time.Year.ToString() + "-" + $LastLogon.Time.Month.ToString() + "-" + $LastLogon.Time.Day.ToString() + " " + $LastLogon.Time.Hour.ToString() + ":" + $LastLogon.Time.Minute.ToString()
									$DaysSinceLastLogon = New-TimeSpan -Start $Lastlogon.time -End (Get-Date) | Select-Object -ExpandProperty Days
									$HoursSinceLastLogon = New-TimeSpan -Start $Lastlogon.time -End (Get-Date) | Select-Object -ExpandProperty Hours
									$MinutesSinceLastLogon = New-TimeSpan -Start $Lastlogon.time -End (Get-Date) | Select-Object -ExpandProperty Minutes
									$Logonduration = "$NewUsername has been logged on for $DaysSinceLastLogon days, $HoursSinceLastLogon hours and $MinutesSinceLastLogon minutes"
									$objManagedObject | Add-Member -Type NoteProperty -Name 'User Logon Duration' -Value "$Logonduration `t `n"
									
								}
								else
								{
									$Logonduration = $null
									$objManagedObject | Add-Member -Type NoteProperty -Name 'User Currently Logged Duration' -Value "$Logonduration `t `n"
								}
							}
							
							if ($User.LastBadPasswordAttempt -ne $null)
							{
								$LastBadPassword = $User.LastBadPasswordAttempt.Year.ToString() + "-" + $User.LastBadPasswordAttempt.Month.ToString() + "-" + $User.LastBadpasswordattempt.Day.ToString() + " " + $User.LastBadPasswordAttempt.Hour.ToString() + ":" + $User.LastBadPasswordAttempt.Minute.ToString()
								$DaysSinceLastBadPassword = New-TimeSpan -Start $User.lastbadpasswordattempt -End (Get-Date) | Select-Object -ExpandProperty Days
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Last Bad Password Attempt' -Value "$Lastbadpassword `t($DaysSinceLastBadPassword days ago) `t `n"
							}
							else
							{
								$LastBadPassword = "No last bad password entry was found"
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Last Bad Password Attempt' -Value "$Lastbadpassword `t `n"
								
							}
							
							$objManagedObject | Add-Member -Type NoteProperty -Name 'User Password Expired' -Value "$($User.PasswordExpired) `t `n"
							
							if ($Lastlogon.User.value -ne $null)
							{
								$UserName = $Lastlogon.User.Value.Split("\")
								$PasswordExpires = Get-ADUser -Identity $Username[1] -Properties PasswordLastSet, PasswordNeverExpires, PasswordExpired | Select-Object -Property PasswordLastSet, PasswordNeverExpires, PasswordExpired
								if ($PasswordExpires.PasswordNeverExpires -eq $false)
								{
									$DaysLapsed = New-Timespan -Start $PasswordExpires.PasswordLastSet -End (Get-Date)
									$Days = $DaysLapsed.Days
									$TotalDaysLapsed = 90 - $Days
									$PasswordExpirationDate = (Get-Date).AddDays($TotalDaysLapsed).ToShortDateString()
									$objManagedObject | Add-Member -Type NoteProperty -Name 'User Password Expires At' -Value "$PasswordExpirationDate `t (expires in $TotalDaysLapsed days) `t `n"
								}
								else
								{
									$PasswordExpirationDate = $Null
									$objManagedObject | Add-Member -Type NoteProperty -Name 'User Password Expires At' -Value "$PasswordExpirationDate `t `n"
								}
							}
							else
							{
								$PasswordExpirationDate = $Null
								$objManagedObject | Add-Member -Type NoteProperty -Name 'User Password Expires At' -Value "$PasswordExpirationDate `t `n"
							}
							
							$objManagedObject | Add-Member -Type NoteProperty -Name 'User Locked Out' -Value "$($User.LockedOut) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'User Enabled' -Value "$($User.Enabled) `t `n `n"
							
							# Get IP from WMI
							try
							{
								$IPV4 = $null
								$IPV6 = $null
								$IPAddresses = Get-WmiObject -class Win32_NetworkAdapterConfiguration -ComputerName $_ | Where-Object { $_.DHCPEnabled -eq $True -and $_.DNSDomain -eq "btworld.net" }
								$IPS = $IPAddresses | Select-Object -ExpandProperty IPAddress
								$IPV4 = $IPS[0]
								$IPV6 = $IPS[1]
							}
							catch
							{
								$IPV4 = $null
								$IPV6 = $null
							}
							
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV6 Address From WMI' -Value "$IPV6 `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV6 Address From ICMP' -Value "$($IP.IPV6Address.IPAddressToString) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV6 Address From AD' -Value "$($PC.IPv6Address) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV4 Address From WMI' -Value "$IPV4 `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV4 Address From ICMP' -Value "$($IP.IPV4Address.IPAddressToString) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'IPV4 Address From AD' -Value "$($PC.IPv4Address) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'PC Model' -Value "$PCModel `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'PC Operating System' -Value "$($PC.Operatingsystem) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'PC Locked Out' -Value "$($PC.LockedOut) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'PC Enabled' -Value "$($PC.Enabled) `t `n"
							$objManagedObject | Add-Member -Type NoteProperty -Name 'PC Last Bad Password Attempt' -Value "$($PC.LastBadPasswordAttempt) `t `n"
						}
						else
						{
							$objManagedObject | Add-Member -Type NoteProperty -Name Connection -Value "Unreachable `n `n `n `n"
						}
						$ManagedObjectsList += $objManagedObject
					}
					else
					{
					}
				}
			}
		}
		End
		{
			return $ManagedObjectsList
		}
	}
	#save the current cursor
	$cursor = $formManagedComputerQuery.Cursor
	#change to wait cursor
	$formManagedComputerQuery.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
	
	# "Gathering system information for {0}" -f $txtComputerName.Text.toUpper() Format-Table -Wrap -HideTableHeaders -AutoSize
	$stringBuilder = New-Object System.Text.StringBuilder
	$stringBuilder.AppendLine($text)
	try
	{
		# Get the users real name and reverse the order so it shows Firstname and then Surname
		$Username = Get-ADUser -Identity "$($txtUserName.Text)" -Properties Name | Select-Object -ExpandProperty Name
		$Firstname = $Username.Split(" ")[1]
		$Surname = $Username.Split(" ")[0]
		$Username = $Firstname + " " + $Surname
	}
	catch
	{
		Write-Output "Could not find the users name"
	}
	
	if ($UserName -ne $null)
	{
		$text = "Computer(s) managed by {0} ({1}) {2}" -f $txtUserName.Text.toUpper(), $Username, (Get-Date -Format g)
	}
	else
	{
		$text = "Computer(s) managed by {0} {1}" -f $txtUserName.Text.toUpper(), (Get-Date -Format g)
	}
	
	$stringBuilder.AppendLine($text)
	$stringBuilder.AppendLine("")
	$stringBuilder.AppendLine("User information is based on the user currently logged in or on the user who was the last one to logon to the computer.")
	
	if ($chkOS.Checked)
	{
		#$stringBuilder.AppendLine("Computername")
		#$stringBuilder.Append("*" * 50)
		$text = ""
		$text = (Get-UserComputers -identity "$($txtUserName.Text)") | Format-List | Out-String -Width 250
		$stringBuilder.AppendLine($text)
	}
	
	#write data to the pipeline
	$textboxResults.Text = $stringBuilder.ToString()
	
	#restore the cursor
	$formManagedComputerQuery.Cursor = $cursor
	
	$btnQuery.Text = "Query"
	$btnQuery.Enabled = $true
}



$lblPrompt_Click = {
	#TODO: Place custom script here
	
}

$labelPrerequisitesRemoteS_Click = {
	#TODO: Place custom script here
}

$label264bitOperatingSyste_Click = {
	#TODO: Place custom script here
	
}

$textboxResults_TextChanged = {
	#TODO: Place custom script here
	
}

$handler_btnPrerequisiteCheck_Click = {
	#TODO: Place custom script here
	
	$buttonPrerequisiteCheck.Text = "Processing..."
	$buttonPrerequisiteCheck.Enabled = $false
	$stringBuilder2 = New-Object System.Text.StringBuilder
	
	$AvailableModules = Get-Module -ListAvailable | Where-Object { $_.name -like "ActiveDirectory" } | Select-Object -ExpandProperty Name
	
	$PSVersion = $PSVersionTable.PSVersion.major.tostring()
	$LoadedModule = Get-Module ActiveDirectory | Select-Object -ExpandProperty Description
	$OS = Get-WmiObject Win32_OperatingSystem | Select-Object -Property Caption, OSArchitecture
	$RSATHotfix = Get-WmiObject -Class "win32_quickfixengineering" | Select-Object -Property "HotfixID" | Where-Object { $_.hotfixid -eq "KB958830" }
	if ($RSATHotfix.hotfixid -eq "KB958830" -or $PSVersion -gt 2)
	{
		$RSAT = "Pass"
	}
	else
	{
		$RSAT = "Fail"
	}
	
	if ($OS.Caption -like "Microsoft Windows Server 2003*" -or $OS.Caption -like "Microsoft Windows Server 2008*" -or $OS.Caption -like "Microsoft Windows Server 2012*" -or $OS.Caption -like "Microsoft Windows 7*" -or $OS.Caption -like "Microsoft Windows 8*" -and $OS.OSArchitecture -eq "64-bit")
	{
		$OSStatus = "Pass"
	}
	else
	{
		$OSStatus = "Fail"
	}
	if ($LoadedModule -eq "Active Directory Module")
	{
		$ModuleLoaded = "Pass"
	}
	elseif ($AvailableModules -eq "ActiveDirectory" -and $PSVersion -gt 2)
	{
		$ModuleLoaded = "Pass"
	}
	else
	{
		$ModuleLoaded = "Fail"
	}
	
	if ($PSVersion -like 1)
	{
		$PSVersion = "Fail"
	}
	else
	{
		$PSVersion = "Pass"
	}
	
	$stringBuilder2.AppendLine("Supported Powershell Version: $PSVersion")
	$stringBuilder2.AppendLine("Supported Operating System: $OSStatus")
	$stringBuilder2.AppendLine("Remote Server Administration Tools Installed: $RSAT")
	$stringBuilder2.AppendLine("Active Directory Module Loaded: $Moduleloaded")
	$stringBuilder2.AppendLine("")
	$textbox1.Text = $stringBuilder2.ToString()
	
	if ($RSAT -eq "Pass" -and $ModuleLoaded -eq "Fail" -and $OS.caption -like "Microsoft Windows 7*" -or $OS.Caption -like "Microsoft Windows 8*")
	{
		$buttonInstallPrerequisites.Visible = $False
		$buttonEnableADModule.Visible = $True
	}
	elseif ($RSAT -eq "Fail" -and $ModuleLoaded -eq "Fail" -and $OS.caption -like "Microsoft Windows 7*" -or $OS.Caption -like "Microsoft Windows 8*")
	{
		$buttonEnableADModule.Visible = $False
		$buttonInstallPrerequisites.Visible = $True
	}
	$buttonPrerequisiteCheck.Text = "Prerequisite Check"
	$buttonPrerequisiteCheck.Enabled = $True
}

$txtUserName_TextChanged = {
	#TODO: Place custom script here
	
}

$buttonInstallPrerequisites_Click = {
	#TODO: Place custom script here
	
}

$handler_buttonInstallPrerequisites_Click = {
	#TODO: Place custom script here
	<#

Date: 13-Feb-2012 ; 19:51
Author: Aman Dhally
Email: amandhally@gmail.com
www: www.amandhally.net/blog
blog: http://newdelhipowershellusergroup.blogspot.com/

More Info about this script : http://newdelhipowershellusergroup.blogspot.in/2012/02/automate-server-administration-tools.html 
This is only to Enable "Active Directory Powershell Module"

Version : 1

				/^(o.o)^\ 
				
Remote Administration server tool : http://www.microsoft.com/download/en/details.aspx?id=7887 | for x86 Select Windows6.1-KB958830-x86-RefreshPkg.msu 				

#>
	
	## You can download Hostfix from the above link
	
	$OS = Get-WmiObject Win32_OperatingSystem | Select-Object -Property Caption, OSArchitecture
	$RSATHotfixWin7 = Get-WmiObject -Class "win32_quickfixengineering" | Select-Object -Property "HotfixID" | Where-Object { $_.hotfixid -eq "KB958830" }
	$RSATHotfixWin81 = Get-WmiObject -Class "win32_quickfixengineering" | Select-Object -Property "HotfixID" | Where-Object { $_.hotfixid -eq "KB2693643" }
	$RSATHotfixWin8 = Get-WmiObject -Class "win32_quickfixengineering" | Select-Object -Property "HotfixID" | Where-Object { $_.hotfixid -eq "KB2693643" }
	
	if ($OS.caption -like "Microsoft Windows 7" -and $RSATHotfixWin7 -eq $null -and $OS.OSArchitecture -like "64-bit")
	{
		$Hotfix = "Windows6.1-KB958830-x64-RefreshPkg.msu"
		$HotfixSource = "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows 7 admin tools\$hotfix"
		
		$HotfixDestination = "C:\Windows\Temp"
		$Testpath = Test-path -path "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows 7 admin tools\$hotfix"
		$Tool = Test-Path "C:\Windows\Temp\Tools"
		if ($Tool -eq $false)
		{
			Write-Output "Download folder not found. Creating folder at C:\Windows\Temp\Tools\"
			New-Item -Name "Tools" -Path $HotfixDestination -ItemType Directory
		}
		else
		{
			Write-Output "Download directory found. Copying RSAT from network drive, please wait..."
		}
		
		
		if ($Testpath -eq $True)
		{
			Copy-Item $HotfixSource -Destination "$HotfixDestination\Tools"
		}
		$TransferStatus = Test-Path "$HotfixDestination\Tools\$Hotfix"
		if ($TransferStatus -eq $True)
		{
			Write-Output "File $Hotfix has been copied to $HotfixDestination\Tools\ Sucessfully. Initiating installation."
		}
		else
		{
			Write-Output "Failed to transfer file to $Hotfixdestination\Tools\. Please install the application manually"
		}
	}
	elseif ($OS.caption -like "Microsoft Windows 8.1*" -and $RSATHotfixWin81 -eq $null -and $OS.OSArchitecture -like "64-bit")
	{
		$Hotfix = "Windows8.1-KB2693643-x64.msu"
		$HotfixSource = "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows81 admin tools\$Hotfix"
		
		$HotfixDestination = "C:\Windows\Temp"
		$Testpath = Test-path -path "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows 7 admin tools\$hotfix"
		$Tool = Test-Path "C:\Windows\Temp\Tools"
		if ($Tool -eq $false)
		{
			Write-Output "Download folder not found. Creating folder at C:\Windows\Temp\Tools\"
			New-Item -Name "Tools" -Path $HotfixDestination -ItemType Directory
		}
		else
		{
			Write-Output "Download directory found. Copying RSAT from network drive, please wait..."
		}
		
		
		if ($Testpath -eq $True)
		{
			Copy-Item $HotfixSource -Destination "$HotfixDestination\Tools"
		}
		$TransferStatus = Test-Path "$HotfixDestination\Tools\$Hotfix"
		if ($TransferStatus -eq $True)
		{
			Write-Output "File $Hotfix has been copied to $HotfixDestination\Tools\ Sucessfully. Initiating installation."
		}
		else
		{
			Write-Output "Failed to transfer file to $Hotfixdestination\Tools\. Please install the application manually"
		}
	}
	elseif ($OS.caption -like "Microsoft Windows 8*" -and $RSATHotfixWin8 -eq $null -and $OS.Architecture -like "64-bit")
	{
		$Hotfix = "Windows6.2-KB2693643-x64.msu"
		$HotfixSource = "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows 8 admin tools\$hotfix"
		
		$HotfixDestination = "C:\Windows\Temp"
		$Testpath = Test-path -path "\\semjgroup2\manager$\Program_Drivers_SP\Program\Microsoft\AD Admin tools\Windows 7 admin tools\$hotfix"
		$Tool = Test-Path "C:\Windows\Temp\Tools"
		if ($Tool -eq $false)
		{
			Write-Output "Download folder not found. Creating folder at C:\Windows\Temp\Tools\"
			New-Item -Name "Tools" -Path $HotfixDestination -ItemType Directory
		}
		else
		{
			Write-Output "Download directory found. Copying RSAT from network drive, please wait..."
		}
		
		
		if ($Testpath -eq $True)
		{
			Copy-Item $HotfixSource -Destination "$HotfixDestination\Tools"
		}
		$TransferStatus = Test-Path "$HotfixDestination\Tools\$Hotfix"
		if ($TransferStatus -eq $True)
		{
			Write-Output "File $Hotfix has been copied to $HotfixDestination\Tools\ Sucessfully. Initiating installation."
		}
		else
		{
			Write-Output "Failed to transfer file to $Hotfixdestination\Tools\. Please install the application manually"
		}
	}
	
	Write-Output "Installing Remote Server Administration Tools......Accept the license agreement and begin installation. Script will continue when installation is completed."
	& wusa.exe "$HotfixDestination\Tools\$Hotfix"
	Start-Sleep -Seconds 15
	$X = 0
	do
	{
		try
		{
			$Installation = Get-Process "wusa"
			if ($Installation -ne $Null)
			{
				Write-Output "Still installing update please wait..."
				Start-Sleep -Seconds 15
				$X = 0
			}
			elseif ($Installation -eq $Null)
			{
				$X = 1
			}
		}
		catch
		{
			$Installation = $Null
		}
	}
	until ($X -eq 1)
	
	
	Write-Output "HotFix Installed. Attempting to enable the Active Directory Module for Windows Powershell"
	& dism.exe /Online /Enable-Feature /FeatureName:RemoteServerAdministrationTools  /FeatureName:RemoteServerAdministrationTools-Roles /FeatureName:RemoteServerAdministrationTools-Roles-AD  /FeatureName:RemoteServerAdministrationTools-Roles-AD-Powershell
	
	do
	{
		try
		{
			$Activation = Get-Process dism -ErrorAction -silentlycontinue
			if ($Activation -ne $Null)
			{
				Write-Output "Still activating Windows features please wait..."
				Start-Sleep -Seconds 15
			}
			else
			{
			}
		}
		catch
		{
			$Activation = $Null
		}
	}
	until ($Activation -eq $Null)
	
	Write-Output "Installation completed. Attempting to load the module now."
	Import-Module ActiveDirectory
	Start-Sleep -Seconds 10
	$Module = Get-Module ActiveDirectory | Select-Object -ExpandProperty Description
	if ($Module -eq "Active Directory Module")
	{
		Write-Output "Module was successfully installed and loaded"
	}
	else
	{
		Write-Output "Module was not installed successfully and has not been loaded"
	}
}

$buttonEnableADModule_Click = {
	#TODO: Place custom script here
}

$handler_buttonEnableADModule_Click = {
	#TODO: Place custom script here
	& dism.exe /Online /Enable-Feature /FeatureName:RemoteServerAdministrationTools  /FeatureName:RemoteServerAdministrationTools-Roles /FeatureName:RemoteServerAdministrationTools-Roles-AD  /FeatureName:RemoteServerAdministrationTools-Roles-AD-Powershell
	
	do
	{
		try
		{
			$Activation = Get-Process dism -ErrorAction -silentlycontinue
			if ($Activation -ne $Null)
			{
				Write-Output "Still activating Windows features please wait..."
				Start-Sleep -Seconds 15
			}
			else
			{
			}
		}
		catch
		{
			$Activation = $Null
		}
	}
	until ($Activation -eq $Null)
	
	Write-Output "Installation completed. Attempting to load the module now."
	Start-Sleep -Seconds 5
	Import-Module ActiveDirectory
	Start-Sleep -Seconds 10
	$Module = Get-Module ActiveDirectory | Select-Object -ExpandProperty Description
	if ($Module -eq "Active Directory Module")
	{
		Write-Output "Module was successfully installed and loaded"
	}
	else
	{
		Write-Output "Module was not installed successfully and has not been loaded"
	}
}
