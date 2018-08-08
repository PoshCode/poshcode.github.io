# setup the test folders
   md c:\grandfather\father\son
   md c:\grandmother\mother\daughter

# By default the folders will inherit ACLs from the C: drive
# To toggle it or change it to the desired setting

# Will force the inheritance from parent
      $inheritance = get-acl c:\grandmother
      $inheritance.SetAccessRuleProtection($false,$false)
      set-acl c:\grandmother -aclobject $inheritance
#Display the new state
      (Get-Acl c:\grandmother).AreAccessRulesProtected

#############################################################
# Second script to go the other way
#############################################################

# Will remove the inheritance from parent

      $inheritance = get-acl c:\grandfather
      $inheritance.SetAccessRuleProtection($true,$true)
      set-acl c:\grandfather -aclobject $inheritance
#Display the new state
      (Get-Acl c:\grandfather).AreAccessRulesProtected

# As you can see changing the ($false,$false) to ($true,$true) is the only difference in the 2 scripts
