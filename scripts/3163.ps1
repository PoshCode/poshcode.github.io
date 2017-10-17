import-module ActiveDIrectory
search-adaccount -searchbase "ou=UserObjectsPendingDeletion,DC=mydomain,DC=com" -Accountinactive -Timespan 400.00:00:00 | where {$_.objectclass -eq 'user'} |  remove-aduser -confirm:$false

