Function Get-RandomPassword {
  Param(
    [parameter()]
    [ValidateRange(8,100)]
    [int]$Length=12,

    [parameter()]
    [switch]$SpecialChars

  )
    $aUpper      = [char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $aLower      = [char[]]'abcdefghijklmnopqrstuvwxyz'
    $aNumber     = [char[]]'1234567890'
    $aSCharacter = [char[]]'!@#$%^&*()_+|~-=\{}[]:;<>,./' # Depending on usage, you may want to strip out some of the special characters if they are not supported
    $aClasses    = [char[]]'ULN' #represents the different classes of characters
    $thePass     = ""
    if ($SpecialChars){
        $aClasses += 'S'
    }
    $notOneOfEach = $true
    while ($notOneOfEach){
        $pPattern = ''
        for ($i=0; $i-lt $Length; $i++){
            $pPattern += get-random -InputObject $aClasses
        }
        if (($pPattern -match 'U' -and $pPattern -match 'L' -and $pPattern -match 'N' -and (-not $specialChars)) -or ($pPattern -match 'U' -and $pPattern -match 'L' -and $pPattern -match 'N' -and $pPattern -match 'S')){
            $notOneOfEach = $false
        }
    }
    foreach ($chr in [char[]]$pPattern){
        switch ($chr){
            U {$thePass += get-random -InputObject $aUpper; break}
            L {$thePass += get-random -InputObject $aLower; break}
            N {$thePass += get-random -InputObject $aNumber; break}
            S {$thePass += get-random -InputObject $aSCharacter; break}
        }
    }
    $thePass
}

for ($i=0; $i -le 20; $i++){Get-RandomPassword -length 12}
