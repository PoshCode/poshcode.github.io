    # When in the cert provider - objects returned by gci must be completed by a particular member (not by ToString).
    # This can be done more generically but for now this is super handy to complete with these types

      $firstChildType = $childitems[0].GetType()
      if ($firstChildType -is  [Microsoft.Powershell.Commands.X509StoreLocation])
      {
          $childitems = childitems | % { $_.Location }
      }

      if ($firstChildType -is  [System.Security.Cryptography.X509Certificates.X509Store])
      {
          $childitems = childitems | % { $_.Name }
      }
      if ($firstChildType -is  [Microsoft.Win32.RegistryKey])
      {  
# registry provider returns full path names - split by \ and take the final item.
          $childitems = childitems | % { $_.Name.Split("\")[-1] } 
      }
