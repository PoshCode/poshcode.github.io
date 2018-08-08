function Get-BinarySum
{
<#
.SYNOPSIS
Performs binary addition of two Int32 values.

.DESCRIPTION
If a numeric overflow occurs in PowerShell, an error is generated making it impossible
to perform binary addition. Get-BinarySum will add two Int32 numbers together and if
the result exceeds [Int32]::MaxValue, the sum will wrap. This function emulates C-style
addition.

.EXAMPLE
PS> Get-BinarySum 0xFFFFFFFF 2
1

.EXAMPLE
PS> Get-BinarySum 2 (-bnot 3 + 1)
-1

Description
-----------
Performs the equivalent of binary subtraction of 2 - 3

.OUTPUTS
System.Int32
The sum of the addition. The Int32 will wrap if the result is greater than 0xFFFFFFFF

.LINK
http://www.exploit-monday.com/
#>

    Param (
        [Parameter(Mandatory = $True, Position = 0)] [Int32] $Num1,
        [Parameter(Mandatory = $True, Position = 1)] [Int32] $Num2
    )

    # The number of bits in an Int32 (DWORD)
    $BitWidth = 32

    # Convert each number to its binary equivalent
    [Char[]] $Num1Array = ([Convert]::ToString($Num1, 2)).PadLeft($BitWidth,'0')
    [Char[]] $Num2Array = ([Convert]::ToString($Num2, 2)).PadLeft($BitWidth,'0')
    
    # Initialize the sum to zero
    [Char[]] $Sum = '0' * $BitWidth
    
    $Carry = 0

    # Calculate sum for each bit and carry, if necessary
    for ($i = ($BitWidth-1); $i -ge 0; $i--)
    {
        $BxorResult = [Convert]::ToInt32($Num1Array[$i], 2) -bxor [Convert]::ToInt32($Num2Array[$i], 2)
        $BandResult = [Convert]::ToInt32($Num1Array[$i], 2) -band [Convert]::ToInt32($Num2Array[$i], 2)
        $Sum[$i] = ($BxorResult -bxor $Carry).ToString()
        $Carry = $BandResult -bor ($Carry -band $BxorResult)
    }

    # Return the result as an Int32
    [Convert]::ToInt32($Sum -join '', 2)
}

