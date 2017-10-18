# ---------------------------------------------------------------------------
### From the Apress book "Pro Windows PowerShell" p. 164 I found the following trap handler that will get to the InnerException.Message
# ---------------------------------------------------------------------------
trap
{
    $exceptiontype = $_.Exception.gettype()
    $InnerExceptionType = "no inner exception"
    if($_.Exception.InnerException)
    {
        $InnerExceptionType = $_.Exception.InnerException.GetType()
        # RV - Added following line to display message
        $_.Exception.InnerException.Message
    }

    "FullyQualifiedErrorID: $($_.FullyQualifiedErrorID)"
    "Exception: $exceptionType"
    "InnerException: $innerExceptionType"

    continue
}
