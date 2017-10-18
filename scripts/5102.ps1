#generates random password with fixed length
-join ([Char[]](35..125) | random -c ([Int32]$len = Read-Host 'Enter pass length'))
