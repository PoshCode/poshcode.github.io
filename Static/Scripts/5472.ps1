I am looking for a help, hope nobody will gala me for being an ignorant. Not that long ago I became something of an AD admin, organisation is big so the tasks vary. I can easily complete what I require via snap-ins in most cases. However I have a task on my hands that exceed my "creativity". I want to change security groups scop from Global to domain local and need to compare the users in other forest (Two way relationship) if users is available that users need to add in this security group. My two problems are: -I am very new to scripting and getting increasingly frustrated that I can't comprehend it 
and make my scripts work as I need them to -Deadline for this task and other responsibilities give me little
time to read more on scripting basics and learn. As such I am in most cases forced to look for script snippets on the web and modify them a bit to meet my needs. This worked up until now as the script I have on my hands is a bit too complex for me.
Biggest problem I was facing so far is creating a forest-wide search. My organization have a Two forest with two way trust relationship.
(Find all security groups in a branch of Active Directory.  Ie.  All groups in a given OrganizationalUnit and child OUs.

For each security group…
                If the name is on a list of those that should not be converted then skip to next security group
                Determine what type it is
                If it is global then convert it to domain local

                Enumerate the members of the list

                For each member
                                If the member is a user account then
                                                Determine the users sAMAccountName (short login name)
                                                Create a foreign security principal for the equivalent account in other forest domain
                                                Add the foreign security principal to the list
                                End if
                Next member
Next security group).


Get-ADGroup -Filter {GroupCategory -eq "Security" -and GroupScope -eq "Global"} | Set-ADGroup -GroupScope Universal

and 

Get-ADGroup -Filter {GroupCategory -eq "Security" -and GroupScope -eq "Universal"} | Set-ADGroup -GroupScope Domainlocal

