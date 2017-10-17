function run-csharpexpression([string] $expression )
{
$local:name  =  [system.guid]::NewGuid().tostring().replace('-','_').insert(0,"csharpexpr")
$local:template = @"
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
namespace ShellTools.DynamicCSharpExpression.N[[COUNTER]]
{
    public class [[CLASSNAME]]
    {
        public static object RunExpression()
        {
            return [[EXPRESSION]];
        }
    }
}
"@
$global:ccounter = [int]$ccounter + 1
$local:source = $local:template.replace("[[CLASSNAME]]",$local:name).replace("[[EXPRESSION]]",$expression).replace("[[COUNTER]]", $ccounter)

add-Type $local:source -Language CsharpVersion3 | out-Null
 invoke-Expression $('[ShellTools.DynamicCsharpExpression.' + $local:name + ']::RunExpression()' )
}
set-alias c run-csharpexpression 
c DateTime.Now
c "new{a=1,b=2,c=3}"
c 'from x in Directory.GetFiles(@"c:\downloads") where x.Contains("win") select x'
