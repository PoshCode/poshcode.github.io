import-csv c:\foo

net use z: \\0.0.0.0\c$ /user:foo foo

select-object -Path "z:\foo" -last 3 | select-string -pattern "FUTUB-CK"

select-object -Path "z:\foo" -last-3 | select-string -pattern "MSQLPATH"

Net use /delete z:

pause

