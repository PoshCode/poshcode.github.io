## USING the binaries from:
## http://downloads.sourceforge.net/sharpssh/SharpSSH-1.1.1.13.bin.zip
[void][reflection.assembly]::LoadFrom( (Resolve-Path "~\Documents\WindowsPowerShell\Libraries\Tamir.SharpSSH.dll") )

## NOTE: These are bare minimum functions, and only cover ssh, not scp or sftp
##       also, if you "expect" something that doesn't get output, you'll be completely stuck.
##
## As a suggestion, the best way to handle the output is to "expect" your prompt,  and then do 
## select-string matching on the output that was captured before the prompt.

function New-SshSession {
Param(
   [string]$UserName
,  [string]$HostName
,  [string]$RSAKeyFile
,  [switch]$Passthru
)
   if($RSAKeyFile -and (Test-Path $RSAKeyFile)){
      $global:LastSshSession = new-object Tamir.SharpSsh.SshShell `
                                          $cred.GetNetworkCredential().Domain, 
                                          $cred.GetNetworkCredential().UserName
      $global:LastSshSession.AddIdentityFile( (Resolve-Path $RSAKeyFile) )
   }
   else {
      $cred = $host.UI.PromptForCredential("SSH Login Credentials",
                                           "Please specify credentials in user@host format",
                                           "$UserName@$HostName","")
      $global:LastSshSession = new-object Tamir.SharpSsh.SshShell `
                                          $cred.GetNetworkCredential().Domain, 
                                          $cred.GetNetworkCredential().UserName,
                                          $cred.GetNetworkCredential().Password
   }


   $global:LastSshSession.Connect()
   $global:LastSshSession.RemoveTerminalEmulationCharacters = $true
   if($Passthru) {
      return $global:LastSshSession
   }
}

function Remove-SshSession {
Param([Tamir.SharpSsh.SshShell]$SshShell=$global:LastSshSession)
   $SshShell.WriteLine( "exit" )
   sleep -milli 500
   if($SshShell.ShellOpened) { Write-Warning "Shell didn't exit cleanly, closing anyway." }
   $SshShell.Close()
   $SshShell = $null
}

function Invoke-Ssh {
Param(
   [string]$command
,  [regex]$expect ## there ought to be a non-regex parameter set...
,  [Tamir.SharpSsh.SshShell]$SshShell=$global:LastSshSession
)

   if($SshShell.ShellOpened) {
      $SshShell.WriteLine( $command )
      if($expect) {
         $SshShell.Expect( $expect ).Split("`n")
      }
      else {
         sleep -milli 500
         $SshShell.Expect().Split("`n")
      }
   }
   else { throw "The ssh shell isn't open!" } 
}

function Send-Ssh {
Param(
   [string]$command
,  [Tamir.SharpSsh.SshShell]$SshShell=$global:LastSshSession
)

   if($SshShell.ShellOpened) {
      $SshShell.WriteLine( $command )
   }
   else { throw "The ssh shell isn't open!" } 
}


function Receive-Ssh {
Param(
   [RegEx]$expect  ## there ought to be a non-regex parameter set...
,  [Tamir.SharpSsh.SshShell]$SshShell=$global:LastSshSession
)
   if($SshShell.ShellOpened) {
      if($expect) {
         $SshShell.Expect( $expect ).Split("`n")
      }
      else {
         sleep -milli 500
         $SshShell.Expect().Split("`n")
      }
   }
   else { throw "The ssh shell isn't open!" } 
}
