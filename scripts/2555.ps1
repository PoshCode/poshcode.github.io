Add-Type -Type @"
using System;
internal class ArgsTest 
{
   private static void Main(string[] args)
   {
      Console.WriteLine();
      /* 
         I've commented this out because (at least in C#)
         it is the same as Environment.GetCommandLineArgs() 
         Except that GetCommandLineArgs shows parameter 0 as the executable path
      */
      // Console.WriteLine("Using args:");
      // Console.WriteLine();
      // for (int i = 0; i < args.Length; i++)
      // {
      //    Console.WriteLine("   Arg {0} is: {1}", i, args[i]);
      // }
      // Console.WriteLine();
      // Console.WriteLine();
      
      Console.WriteLine("CommandLine:");
      Console.WriteLine();
      Console.WriteLine("   " + Environment.CommandLine);
      Console.WriteLine();
      Console.WriteLine();
      
      Console.WriteLine("CommandLineArgs:");
      Console.WriteLine();
      string[] arguments = Environment.GetCommandLineArgs();
      for (int i = 0; i < arguments.Length; i++)
      {
         Console.WriteLine("   Arg {0} is: {1}", i, arguments[i]);
      }
      Console.WriteLine();
      Console.WriteLine();
      
      System.Threading.Thread.Sleep(10000);
   }
}
"@ -OutputAssembly ArgsTest.exe -OutputType ConsoleApplication
