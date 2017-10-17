# Stick this anywhere
    filter convertTypeToTabCompletionName()
    {

        $typeToTabCompletion=@{
        [Microsoft.Powershell.Commands.X509StoreLocation]={$_.Location};
        [System.Security.Cryptography.X509Certificates.X509Store]={$_.Name};
        [Microsoft.Win32.RegistryKey]={ $_.Name.Split("\")[-1] };
        }

        $convertToTabCompletionFunction =$typeToTabCompletion[$_.GetType()]
        if (-not $convertToTabCompletionFunction  )
        {
            $convertToTabCompletionFunction  = {$_.Name}
        }

        $_ | % $convertToTabCompletionFunction 
    }

#Replace the final Invoke-TabItemSelector with: 
@@      $ChildItems | convertTypeToTabCompletionName |% {$container + "\" + $_}| Invoke-TabItemSelector $lastPath -SelectionHandler $SelectionHandler -return $lastword -ForceList |% {

