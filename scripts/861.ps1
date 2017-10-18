function foreach-withexception ([scriptblock]$process,$outputexception)
{
  begin { $global:foreachex = @() }
  process { 
            try 
            {
            $local:inputitem = $_
            &$process 
            }
            catch
            {
            $local:exceptionitem = 1 | select-object object,exception
            $local:exceptionitem.object = $local:inputitem 
            $local:exceptionitem.exception = $_
            $global:foreachex += $local:exceptionitem
            }
          }
  end {}
}
set-alias %ex foreach-withexception

100..-5 | %ex {  "yo $_" ;  1 / $_ }
$lastex
