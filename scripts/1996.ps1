Get-PSDrive -PSProvider FileSystem | foreach { $_.Root } | `
   Get-ChildItem -Recurse -Include '*.ps1', '*.psm1', '*.ps1xml' | `
   where { Select-String -Path $_ -SimpleMatch -Pattern `
            'VMware.VimAutomation.Types.', `
            'VMware.VimAutomation.Client20.', `
            '[Datastore]' }

