function new-parameterTransform 
{
	[cmdletbinding()]
	param( 
		[Parameter(Mandatory=$true,Position=0)]
		[string] $name,
		
		[Parameter(Mandatory=$true, Position=1)]
		[scriptblock] $script
	)
	
add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Collections.ObjectModel;

[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
public class ${name}Attribute : ArgumentTransformationAttribute {
   private ScriptBlock _scriptblock;
   private string _noOutputMessage = "Transform Script had no output.";

   public ${name}Attribute() {
      this.Script = ScriptBlock.Create( @"
	  	$($script.ToString() -replace '"','""' )
" );
   }
   public override string ToString() {
      return Script.ToString();
   }

   public override Object Transform( EngineIntrinsics engine, Object inputData) {
      try {
         Collection<PSObject> output =
            engine.InvokeCommand.InvokeScript( engine.SessionState, Script, inputData );
         
         if(output.Count > 1) {
            Object[] transformed = new Object[output.Count];
            for(int i =0; i < output.Count;i++) {
               transformed[i] = output[i].BaseObject;
            }
            return transformed;
         } else if(output.Count == 1) {
            return output[0].BaseObject;
         } else {
            throw new ArgumentTransformationMetadataException(NoOutputMessage);
         }
      } catch (ArgumentTransformationMetadataException) {
         throw;
      } catch (Exception e) {
         throw new ArgumentTransformationMetadataException(string.Format("Transform Script threw an exception ('{0}'). See `$Error[0].Exception.InnerException.InnerException for more details.",e.Message), e);
      }
   }
   
   public ScriptBlock Script {
      get { return _scriptblock; }
      set { _scriptblock = value; }
   }
   
   public string NoOutputMessage {
      get { return _noOutputMessage; }
      set { _noOutputMessage = value; }
   }  
}
"@
}

New-Alias -Name Transform -Value New-ParameterTransform;
Export-ModuleMember -Alias Transform -Function *
