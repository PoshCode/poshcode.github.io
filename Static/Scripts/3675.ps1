#############################################################
#
#  PS II> Test-CommandValidation -command get-process | fl
#            VerbNounConvention : True
#            ReservedKeyWords   : True
#            VerbConvention     : True
#
# author: Walid Toumi
#############################################################

function Test-CommandValidation {

 param($Command,[switch]$SimpleForm)

 $keys = man key |

           Select-String "(\S+)(?=\s{5,}about_*)" |

                select -expand Matches |

                      select -expand value

 $verbNounConvention = $verbconvention = $reservedkeywords = $false

 $verb,$noun = $Command.Split('-')

 if($noun) {

    $verbNounConvention = $true

    if( (get-verb $verb) ) { $verbconvention = $true }

    if($keys -contains $noun) { $reservedkeywords = $true }

 }

 else {

     $reservedkeywords = $verbconvention = $null

 }

  $objPS=new-object PSObject -prop @{

     VerbNounConvention = $verbNounConvention

     VerbConvention = $verbconvention

     ReservedKeyWords = $reservedkeywords

  }

 if($SimpleForm) {

     switch($objPS) {

       {!$_.ReservedKeyWords -and $_.VerbConvention -and $_.VerbNounConvention}

         {Write-Host "PASS !!" -ForegroundColor green}

       {!$_.VerbConvention -and !$_.VerbConvention -and !$_.VerbNounConvention}

         {Write-Host "FAIL !!" -ForegroundColor red}

       default

        { Write-Host "MAYBE !!" -ForegroundColor DarkYellow }

     }

  } else {

    $objPS

 }

}
