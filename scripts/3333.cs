using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using Microsoft.Win32;
using System.IO;
using System.Text.RegularExpressions;



namespace Findup
{
    public class FileLengthComparer : IComparer<FileInfo>
    {
        public int Compare(FileInfo x, FileInfo y)
        {
            return (x.Length.CompareTo(y.Length));
        }
    }
    
    class Findup
    {
        public static System.String[] paths = new string[0];
        public static System.String[] excpaths = new string[0];
        public static System.String[] incpaths = new string[0];
            
        public static System.Boolean noerr = false;
        public static System.Boolean useregex = false;
        public static System.Boolean includeflag = false;

        public static void Main(string[] args)
        {            
            Console.WriteLine("Findup.exe v2.0 - By James Gentile - JamesRaymondGentile@gmail.com - 2012.");
            Console.WriteLine(" ");            
            System.Boolean recurse = false;
            System.Boolean exc = false;
            System.Boolean inc = false;
            List<FileInfo> files = new List<FileInfo>();            
            long numOfDupes = 0;                                 // number of duplicate files found.
            long dupeBytes = 0;                                  // number of bytes in duplicates.
            int i = 0;            

            for (i = 0; i < args.Length; i++)
            {
                if ((System.String.Compare(args[i], "-help", true) == 0) || (System.String.Compare(args[i], "-h", true) == 0))
                {
                    Console.WriteLine("Usage:    findup.exe <file/directory #1> <file/directory #2> ... <file/directory #N> [-recurse] [-noerr] [-x] <files/directories/regx> [-regex]");
                    Console.WriteLine(" ");
                    Console.WriteLine("Options:  -help     - displays this help message.");
                    Console.WriteLine("          -recurse  - recurses through subdirectories when directories or file specifications (e.g. *.txt) are specified.");                    
                    Console.WriteLine("          -noerr    - discards error messages.");
                    Console.WriteLine("          -x        - eXcludes all directories\\files (or RegEx if -regex used) including subdirs following this switch until another switch is used.");
                    Console.WriteLine("          -i        - Include only directories\\files (or RegEx if -regex used) including subdirs following this switch until another switch is used.");
                    Console.WriteLine("          -regex    - Use Regex notation for exclude (-x) and include (-i) option.");
                    Console.WriteLine(" ");
                    Console.WriteLine("Examples: findup.exe c:\\finances -recurse -noerr");
                    Console.WriteLine("                     - Find dupes in c:\\finance.");
                    Console.WriteLine("                     - recurse all subdirs of c:\\finance.");
                    Console.WriteLine("                     - suppress error messages.");
                    Console.WriteLine("          findup.exe c:\\users\\alice\\plan.txt d:\\data -recurse -x d:\\data\\webpics");
                    Console.WriteLine("                     - Find dupes in c:\\users\\alice\\plan.txt, d:\\data");
                    Console.WriteLine("                     - recurse subdirs in d:\\data.");
                    Console.WriteLine("                     - exclude any files in d:\\data\\webpics and subdirs.");
                    Console.WriteLine("          findup.exe c:\\data *.txt c:\\reports\\quarter.doc -x \"(?:jim)\" -regex");
                    Console.WriteLine("                     - Find dupes in c:\\data, *.txt in current directory and c:\\reports\\quarter.doc");
                    Console.WriteLine("                     - exclude any file with 'jim' in it as specified by the Regex item \"(?:jim)\"");
                    Console.WriteLine("          findup.exe c:\\data *.txt c:\\reports\\quarter.doc -x \"(?:jim)\" -i \"(?:smith)\" -regex");
                    Console.WriteLine("                     - Find dupes in c:\\data, *.txt in current directory and c:\\reports\\bobsmithquarter.doc");
                    Console.WriteLine("                     - Include only files with 'smith' and exclude any file with 'jim' in it as specified by the Regex items \"(?:jim)\",\"(?:smith)\"");
                    Console.WriteLine("Note:     Exclude takes precedence over Include.");
                    return;
                }
                if (System.String.Compare(args[i], "-recurse", true) == 0)
                {
                    recurse = true;
                    inc = false;
                    exc = false;
                    continue;
                }
                if (System.String.Compare(args[i], "-regex", true) == 0)
                {
                    useregex = true;
                    inc = false;
                    exc = false;
                    continue;
                }                               
                if (System.String.Compare(args[i], "-noerr", true) == 0)
                {
                    noerr = true;
                    inc = false;
                    exc = false;
                    continue;
                }
                if (System.String.Compare(args[i], "-i", true) == 0)
                {
                    inc = true;
                    exc = false;                    
                    continue;
                }
                if (System.String.Compare(args[i], "-x", true) == 0)
                {
                    exc = true;
                    inc = false;
                    continue;
                }
                if (exc == true)
                {
                    Array.Resize(ref excpaths, excpaths.Length + 1);
                    excpaths[excpaths.Length - 1] = args[i];
                    continue;
                }
                if (inc == true)
                {
                    Array.Resize(ref incpaths, incpaths.Length + 1);
                    incpaths[incpaths.Length - 1] = args[i];
                    includeflag = true;
                    continue;
                }
                else
                {
                    Array.Resize(ref paths, paths.Length + 1);
                    paths[paths.Length - 1] = args[i];
                }
            }
            if (paths.Length == 0)
            {
                WriteErr("No files, file specifications, or directories specified. Try findup.exe -help");
                return;
            }
            Console.Write("Getting file info...");
            getFiles(paths, "*.*", recurse, files);
            Console.WriteLine("Completed!");               
            if (files.Count < 2)
            {
                WriteErr("Findup.exe needs at least 2 files to compare. Try findup.exe -help");
                return;
            }

            Console.Write("Sorting file list...");
            files.Sort(new FileLengthComparer());
            Console.WriteLine("Completed!");

            Console.Write("Computing SHA512 & Size matches...");

            var SizeHashName = new Dictionary<long, Dictionary<string,List<string>>>();            

            for (i = 0; i < (files.Count - 1); i++)
            {
                if (files[i].Length != files[i + 1].Length) { continue; }
                var breakout = false;
                while (true)
                {
                    var _SHA512 = SHA512.Create();
                    try
                    {                       
                        using (var fstream = File.OpenRead(files[i].FullName))
                        {                    
                            _SHA512.ComputeHash(fstream);
                        }
                        System.Text.Encoding enc = System.Text.Encoding.ASCII;
                        string SHA512string = enc.GetString(_SHA512.Hash);

                        if (SizeHashName.ContainsKey(files[i].Length))
                        {
                            if (!SizeHashName[files[i].Length].ContainsKey(SHA512string))
                            {                                
                                SizeHashName[files[i].Length][SHA512string] = new List<string>() {};
                            }
                        }
                        else
                        {
                            SizeHashName.Add(files[i].Length, new Dictionary<string,List<string>>());
                            SizeHashName[files[i].Length][SHA512string] = new List<string>() {};
                        }
                        SizeHashName[files[i].Length][SHA512string].Add(files[i].FullName);
                    }
                    catch (Exception e)
                    {
                        WriteErr("Hash error: " + e.Message);                     
                    }

                    if (breakout == true) {break;}
                    i++;
                    if (i == (files.Count - 1)) { breakout = true; continue; }
                    if (files[i].Length != files[i + 1].Length) { breakout = true; }
                }
            }

            Console.WriteLine("Completed!");

            foreach (var SizeGroup in SizeHashName)
            {
                foreach (var HashGroup in SizeGroup.Value)
                {
                    if (HashGroup.Value.Count > 1)
                    {                        
                        Console.WriteLine("Duplicates (size: {0:N0} Bytes) - ", (long)SizeGroup.Key);                        
                        foreach (var FileName in HashGroup.Value)
                        {
                            Console.WriteLine(FileName);
                            numOfDupes++;
                            dupeBytes += (long)SizeGroup.Key;
                        }
                    }
                }                
            }

            Console.WriteLine("\n ");
            Console.WriteLine("Files checked      : {0:N0}", files.Count);
            Console.WriteLine("Duplicate files    : {0:N0}", numOfDupes);
            Console.WriteLine("Duplicate bytes    : {0:N0}", dupeBytes);
            return;                                                                             // Exit after displaying statistics.
        }               

        private static void WriteErr(string Str)
        {
            if (noerr == false)
                Console.WriteLine(Str);
        }

        private static Boolean CheckExcludes(string Path)
        {
            foreach (var x in excpaths)
            {
                if (useregex == true)
                {
                    try
                    {
                        Regex rgx = new Regex(x);
                        if (rgx.IsMatch(Path))
                            return false;
                    }
                    catch (Exception e)
                    {
                        WriteErr("Invalid regex used: " + x + " exception: " + e);
                    }
                }
                else { if (Path.ToLower().StartsWith(x.ToLower())) { return false; } }
            }
            return true;
        }
        private static Boolean CheckIncludes(string Path)
        {
            if (!includeflag) { return true; }
            foreach (var i in incpaths)
            {
                if (useregex == true)
                {
                    try
                    {
                        Regex rgx = new Regex(i);
                        if (rgx.IsMatch(Path))
                            return true;
                    }
                    catch (Exception e)
                    {
                        WriteErr("Invalid regex used: " + i + " exception: " + e);
                    }
                }
                else {if (Path.ToLower().StartsWith(i.ToLower())) { return true; }}
            }
            return false;
        }

        private static void getFiles(string[] pathRec, string searchPattern, Boolean recursiveFlag, List<FileInfo> returnList)
        {

            foreach (string d in pathRec)
            {
                getFiles(d, searchPattern, recursiveFlag, returnList);
            }
            return;
        }

        private static void getFiles(string pathRec, string searchPattern, Boolean recursiveFlag, List<FileInfo> returnList)
        {

            string dirPart;
            string filePart;

            if (File.Exists(pathRec))
            {
                try
                {
                    FileInfo addf = (new FileInfo(pathRec));
                    if (((addf.Attributes & FileAttributes.ReparsePoint) == 0) && CheckExcludes(addf.FullName) && CheckIncludes(addf.FullName))
                        returnList.Add(addf);
                }
                catch (Exception e)
                {
                    WriteErr("Add file error: " + e.Message);
                }                
            }
            else if (Directory.Exists(pathRec))
            {
                try
                {
                    DirectoryInfo Dir = new DirectoryInfo(pathRec);
                    foreach (FileInfo addf in (Dir.GetFiles(searchPattern)))
                    {
                        if (((addf.Attributes & FileAttributes.ReparsePoint) == 0) && CheckExcludes(addf.FullName) && CheckIncludes(addf.FullName))
                            returnList.Add(addf);
                    }
                }
                catch (Exception e)
                {
                    WriteErr("Add files from Directory error: " + e.Message);
                }

                if (recursiveFlag == true)
                {
                    try
                    {
                            getFiles((Directory.GetDirectories(pathRec)), searchPattern, recursiveFlag, returnList);
                    }
                    catch (Exception e)
                    {
                        WriteErr("Add Directory error: " + e.Message);
                    }
                }                
            }
            else
            {
                try
                {
                    filePart = Path.GetFileName(pathRec);
                    dirPart = Path.GetDirectoryName(pathRec);
                }
                catch (Exception e)
                {
                    WriteErr("Parse error on: " + pathRec);
                    WriteErr(@"Make sure you don't end a directory with a \ when using quotes. The console arg parser doesn't accept that.");
                    WriteErr("Exception: " + e.Message);
                    return;
                }

                if (filePart.IndexOfAny(new char[] {'?','*'}) >= 0)
                {
                    if ((dirPart == null) || (dirPart == ""))
                        dirPart = Directory.GetCurrentDirectory();
                    if (Directory.Exists(dirPart) && CheckExcludes(dirPart) && CheckIncludes(dirPart))
                    {
                        getFiles(dirPart, filePart, recursiveFlag, returnList);
                        return;
                    }
                }
                WriteErr("Invalid file path, directory path, file specification, or program option specified: " + pathRec);                                                        
            }            
        }
    }
}
