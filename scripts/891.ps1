#requires -version 2.0
Add-Type @"
public class Shift {
   public static int   Right(int x,   int count) { return x >> count; }
   public static uint  Right(uint x,  int count) { return x >> count; }
   public static long  Right(long x,  int count) { return x >> count; }
   public static ulong Right(ulong x, int count) { return x >> count; }
   public static int    Left(int x,   int count) { return x << count; }
   public static uint   Left(uint x,  int count) { return x << count; }
   public static long   Left(long x,  int count) { return x << count; }
   public static ulong  Left(ulong x, int count) { return x << count; }
}                    
"@



#.Example 
#  Shift-Left 16 1        ## returns 8
#.Example 
#  8,16 |Shift-Left      ## returns 4,8
function Shift-Left {
PARAM( $x=1, $y )
BEGIN {
   if($y) {
      [Shift]::Left( $x, $y )
   }
}
PROCESS {
   if($_){
      [Shift]::Left($_, $x)
   }
}
}


#.Example 
#  Shift-Right 8 1        ## returns 16
#.Example 
#  2,4,8 |Shift-Right 2  ## returns 8,16,32
function Shift-Right {
PARAM( $x=1, $y )
BEGIN {
   if($y) {
      [Shift]::Right( $x, $y )
   }
}
PROCESS {
   if($_){
      [Shift]::Right($_, $x)
   }
}
}
