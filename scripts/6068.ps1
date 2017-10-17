$results = New-Object -TypeName psobject -Property @{
    name =  "$($user.'First Name') $($user.'Last Name')"
    userprincipalname = ""
    enabled = "AD User does not match email"

}
