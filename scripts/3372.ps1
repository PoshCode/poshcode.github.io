#--------------------------------------------------------------------------------------------------------------
#Convert Untitled1.ps1 to ASCII encoding
$psise.CurrentPowerShellTab.Files | % { 
    # set private field which holds default encoding to ASCII 
    $_.gettype().getfield("encoding","nonpublic,instance").setvalue($_, [text.encoding]::ascii) 
} 

# watch for changes to the Files collection of the current Tab 
register-objectevent $psise.CurrentPowerShellTab.Files collectionchanged -action { 
    # iterate ISEFile objects 
    $event.sender | % { 
        # set private field which holds default encoding to ASCII 
        $_.gettype().getfield("encoding","nonpublic,instance").setvalue($_, [text.encoding]::ascii) 
    } 
}
#--------------------------------------------------------------------------------------------------------------
