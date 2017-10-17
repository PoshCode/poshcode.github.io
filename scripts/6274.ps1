Function New-RandomComplexPassword ($length=20)
        $password = [System.Web.Security.Membership]::GeneratePassword($length,2)
        return $password
New-RandomComplexPassword
