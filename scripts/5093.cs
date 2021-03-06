using System;
using System.IO;
using System.Security;
using System.Reflection;
using System.Collections;
using System.Globalization;
using System.Security.Policy;
using System.Text.RegularExpressions;

[assembly: AssemblyCopyright("Copyright (C) 2014 greg zakharov")]
[assembly: AssemblyCulture("")]
[assembly: AssemblyDescription("Looking for an assembly in GAC")]
[assembly: AssemblyTitle("GACSearch")]
[assembly: AssemblyVersion("1.0.0.19")]
[assembly: CLSCompliant(true)]

namespace GACSearch {
  internal sealed class AssemblyInfo {
    internal Type a;
    internal AssemblyInfo() { a = typeof(Program); }
    
    internal String Copyright {
      get {
        return ((AssemblyCopyrightAttribute)a.Assembly.GetCustomAttributes(
                  typeof(AssemblyCopyrightAttribute), false)[0]).Copyright;
      }
    }
    
    internal String Description {
      get {
        return ((AssemblyDescriptionAttribute)a.Assembly.GetCustomAttributes(
                typeof(AssemblyDescriptionAttribute), false)[0]).Description;
      }
    }
    
    internal String Title {
      get { return a.Assembly.GetName().Name; }
    }
    
    internal String Version {
      get { return a.Assembly.GetName().Version.ToString(2); }
    }
  } //AssemblyInfo
  
  internal sealed class Program {
    static void Main(String[] args) {
      if (args.Length != 1) {
        AssemblyInfo ai = new AssemblyInfo();
        
        Console.WriteLine("{0} v{1} - {2}", ai.Title, ai.Version, ai.Description);
        Console.WriteLine("{0}\n\nUsage: {1} <assembly_name>", ai.Copyright, ai.Title);
        Console.WriteLine(".e.g.: {0} System.Xml", ai.Title);
        Environment.Exit(1);
      }
      
      String asm = args[0].ToLower(CultureInfo.CurrentCulture);
      String gac = null; //GAC path
      Int32  itm = 0;    //items found
      
      AssemblyName an;
      
      IEnumerator ie = AppDomain.CurrentDomain.GetAssemblies()[0].Evidence.GetHostEnumerator();
      while (ie.MoveNext()) {
        Url url = ie.Current as Url;
        if (url != null) //shouldn't be null
          gac = (new Regex(@"(?<=file:///)(.*)(?=GAC)")).Match(url.ToString()).Value;
      }
      
      //looking for specified assembly
      Console.WriteLine("The Global Assembly Cache contains the following assemblies:");
      foreach (String dll in Directory.GetFiles(gac, "*.dll", SearchOption.AllDirectories)) {
        if (Path.GetFileName(dll).ToLower(CultureInfo.CurrentCulture).Equals(asm + ".dll")) {
          an = AssemblyName.GetAssemblyName(dll);
          Console.WriteLine("  {0}, processorArchitecture={1}", an.FullName, an.ProcessorArchitecture);
          itm++;
        }
      }
      Console.WriteLine("\nNumber of items = {0}", itm);
    }
  } //Program
}
