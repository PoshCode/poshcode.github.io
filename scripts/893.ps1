$a = @"

using System;
namespace ClassLibrary1
{
#proof of concept
public static class Class1
{
public static string Foo(string value)
{
if (value == null)
    return "Special processing of null.";
else
    return "'" + value + "' has been processed.";
}
}
}
"@

$b = @"
using System;
namespace testnullD
{
public class nulltest
{
public nulltest(){}
public override string ToString() {return null;}
}
}
"@
add-type $a
add-type $b
$psnull = new-object testnullD.nulltest
add-type $a
[ClassLibrary1.Class1]::Foo($null)
[ClassLibrary1.Class1]::Foo($psnull)
