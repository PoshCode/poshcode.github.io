### NOTE: the <#PS ... #> is the prompt!

<#PS [40] #> $ConfirmPreference

High

<#PS [41] #> function get-confirmed { [CmdletBinding(SupportsShouldProcess=$true)]param() $ConfirmPreference }


<#PS [42] #> get-confirmed

High

<#PS [43] #> get-confirmed -confirm

Low

<#PS [44] #> get-confirmed -confirm:$false

None

<#PS [45] #> $ConfirmPreference = "Medium"


<#PS [46] #> get-confirmed

Medium

<#PS [47] #> get-confirmed -confirm

Low

<#PS [48] #> get-confirmed -confirm:$false

None
