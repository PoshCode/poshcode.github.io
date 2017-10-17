Filter Enquote-CmdlineArgument #Escapes according to CmdlineToArgvW's rules
{
    '"{0}"' -f $($($_ -replace '(\x5C*)$', '$1$1') -replace '(\x5C*)(\x22)', '$1$1\"')
}

<# In human terms, these are the steps it takes:
    * Double all terminal backslashes
    * Replace all double-quotes with a backslash followed by a double-quote, AND double any original preceding backslashes
    * Enclose the whole thing between a pair of double-quotes
#>
