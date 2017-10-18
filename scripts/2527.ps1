<#
    .Synopsis
        Creates new object based on hashtable definition
    .Description
        Function is wrapper for New-Object that allows user to create nested objects using nested hashtable as definition.
        If you want to take advantage of type use 'Type' key within hashtable that defines object.
    .Example
        $obj = New-ObjectRecursive @{Test = @{ InnerTest = 'Value'; AnotherInner = 'Another'; InnerwithInner = @{ Deepest = 'It is very deep'}}; Flat = 'SomeValue'}
        $obj.Test.InnerwithInner.Deepest
        It is very deep
        
        Create simpe custom object with several inner psobjects, depending of hashtable structure.
    .Example
        (New-ObjectRecursive @{ Type = 'Windows.Forms.Form'; Size = @{ Type = 'Drawing.Size'; width = 400; Height = 400}; Text = 'Title of window'}).ShowDialog()
        
        Display windows form of size 400 x 400 and title 'Title of window', assuming Windows.Forms are loaded.
#>

    param(
        $Property
        )
    if ($Property -is [hashtable]) {
        if ($Type = $Property.Type) {
            $Property.Remove('Type')
        } else {
            $Type = 'PSObject'
        }
        $PropertyHash = @{}
        foreach ($key in $Property.keys) {
            $PropertyHash.Add($key, $(New-ObjectRecursive $Property[$key]))
        }
        Try {
            New-Object $Type -Property $PropertyHash -ErrorAction SilentlyContinue
            if (!$?) {
                Write-Host -ForegroundColor Red $Error[0].Exception.Message
            }   
        } catch {
            Write-Host -ForegroundColor Red "Problems with creating object of type: $Type. Try to use PSObject instead . . ."
            New-Object PSObject -Property $PropertyHash -ErrorAction SilentlyContinue
            Write-Host -ForegroundColor Red "Error message:" $_.Exception.Message
        }
    } else {
        $Property
    }
