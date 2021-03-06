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
        public static Dictionary<string, List<string>> optionspaths = new Dictionary<string, List<string>>
            { {"-x", new List<string>()},{"-i",new List<string>()},{"-xf",new List<string>()},{"-if",new List<string>()},
            {"-xd",new List<string>()},{"-id",new List<string>()},{"-paths",new List<string>()} };
        public static Dictionary<string, Boolean> optionsbools = new Dictionary<string, bool> { { "-recurse", false }, { "-regex", false }, { "-noerr", false } };

        public static void Main(string[] args)
        {            
            Console.WriteLine("Findup.exe v2.0 - By James Gentile - JamesRaymondGentile@gmail.com - 2012.");
            Console.WriteLine(" ");                        
            string optionspathskey = "-paths";
            
            List<FileInfo> files = new List<FileInfo>();            
            long numOfDupes = 0;                                 // number of duplicate files found.
            long dupeBytes = 0;                                  // number of bytes in duplicates.
            int i = 0;            

            for (i = 0; i < args.Length; i++)
            {
                string argitem=args[i].ToLower();

                if ((System.String.Compare(argitem, "-help", true) == 0) || (System.String.Compare(argitem, "-h", true) == 0))
                {
                    Console.WriteLine("Usage:    findup.exe <file/directory #1> <file/directory #2> ... <file/directory #N> [-recurse] [-noerr] [-x] <files/directories/regx> [-regex]");
                    Console.WriteLine(" ");
                    Console.WriteLine("Options:  -help     - displays this help message.");
                    Console.WriteLine("          -recurse  - recurses through subdirectories when directories or file specifications (e.g. *.txt) are specified.");                    
                    Console.WriteLine("          -noerr    - discards error messages.");
                    Console.WriteLine("          -x        - eXcludes if full file path starts with (or RegEx matches if -regex supplied) one of the items following this switch until another switch is used.");
                    Console.WriteLine("          -i        - include if full file path starts with (or Regex matches if -regex supplied) one of the items following this switch until another switch is used.");
                    Console.WriteLine("          -xd       - eXcludes all directories (using RegEx if -regex supplied) including subdirs following this switch until another switch is used.");
                    Console.WriteLine("          -id       - Include only directories (using RegEx if -regex supplied) including subdirs following this switch until another switch is used.");
                    Console.WriteLine("          -xf       - eXcludes all files (using RegEx if -regex supplied) following this switch until another switch is used.");
                    Console.WriteLine("          -if       - Include only files (using RegEx if -regex supplied) following this switch until another switch is used.");
                    Console.WriteLine("          -regex    - Use Regex notation for exclude (-x) and include (-i) option.");
                    Console.WriteLine("          -paths    - not needed unless you want to specify files/dirs after an include/exclude without using another non-exclude/non-include option.");
                    Console.WriteLine(" ");
                    Console.WriteLine("Examples: findup.exe c:\\finances -recurse -noerr");
                    Console.WriteLine("                     - Find dupes in c:\\finance.");
                    Console.WriteLine("                     - recurse all subdirs of c:\\finance.");
                    Console.WriteLine("                     - suppress error messages.");
                    Console.WriteLine("          findup.exe c:\\users\\alice\\plan.txt d:\\data -recurse -x d:\\data\\webpics");
                    Console.WriteLine("                     - Find dupes in c:\\users\\alice\\plan.txt, d:\\data");
                    Console.WriteLine("                     - recurse subdirs in d:\\data.");
                    Console.WriteLine("                     - exclude any files in d:\\data\\webpics and subdirs.");
                    Console.WriteLine("          findup.exe c:\\data *.txt c:\\reports\\quarter.doc -x \"(jim)\" -regex");
                    Console.WriteLine("                     - Find dupes in c:\\data, *.txt in current directory and c:\\reports\\quarter.doc");
                    Console.WriteLine("                     - exclude any file with 'jim' in the name as specified by the Regex item \"(jim)\"");
                    Console.WriteLine("          findup.exe c:\\data *.txt c:\\reports\\bobsmithquarter.doc -x \"[bf]\" -i \"(smith)\" -regex");
                    Console.WriteLine("                     - Find dupes in c:\\data, *.txt in current directory and c:\\reports\\bobsmithquarter.doc");
                    Console.WriteLine("                     - Include only files with 'smith' and exclude any file with letters b or f in the name as specified by the Regex items \"[bf]\",\"(smith)\"");
                    Console.WriteLine("Note:     Exclude takes precedence over Include.");
                    Console.WriteLine("          -xd,-id,-xf,-if are useful if for instance you want to apply a RegEx to only file names but not directory names or vice versa.");
                    Console.WriteLine("          if for instance you wanted all files that contained the letter \"d\" on your D: drive but didn't want the d:\\ to cause all files on the d:\\ ");
                    Console.WriteLine("          drive to be included, you would specify:");
                    Console.WriteLine("          findup.exe d:\\ -recurse -noerr -regex -if \"[d]\"  ");
                    return;
                }
                if (optionsbools.ContainsKey(argitem))
                {
                    optionsbools[argitem] = true;
                    optionspathskey = "-paths";
                    continue;
                }                
                if (optionspaths.ContainsKey(argitem))
                {
                    optionspathskey = argitem;
                    continue;
                }                
                optionspaths[optionspathskey].Add(argitem);                                    
            }
            if (optionspaths["-paths"].Count == 0)
            {
                WriteErr("No files, file specifications, or directories specified. Try findup.exe -help. Assuming current directory.");
                optionspaths["-paths"].Add(".");
            }
            Console.Write("Getting file info and sorting file list...");
            getFiles(optionspaths["-paths"], "*.*", optionsbools["-recurse"], files);
                         
            if (files.Count < 2)
            {
                WriteErr("\nFindup.exe needs at least 2 files to compare. Try findup.exe -help");
                return;
            }

            files.Sort(new FileLengthComparer());
            Console.WriteLine("Completed!");  

            Console.Write("Building dictionary of file sizes, SHA512 hashes and full paths...");

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
            if (optionsbools["-noerr"] == false)
                Console.WriteLine(Str);
        }

        private static Boolean CheckAll(string full)
        {
            if (!CheckWorker(full, optionspaths["-x"]))
                return false;
            if ((optionspaths["-i"].Count > 0) == CheckWorker(full, optionspaths["-i"]))
                return false;

            var filePart = Path.GetFileName(full);
            var dirPart = Path.GetDirectoryName(full);

            if (!CheckWorker(filePart, optionspaths["-xf"]))
                return false;
            if (!CheckWorker(dirPart, optionspaths["-xd"]))
                return false;            
            if ((optionspaths["-if"].Count > 0) == CheckWorker(filePart, optionspaths["-if"]))
                return false;
            if ((optionspaths["-id"].Count > 0) == CheckWorker(dirPart, optionspaths["-id"]))
                return false;
            return true;
        }

        private static Boolean CheckWorker(string full, List<string> pathsitems)
        {
            foreach (var x in pathsitems)
            {
                if (optionsbools["-regex"] == true)
                {
                    try
                    {
                        Regex rgx = new Regex(x);
                        if (rgx.IsMatch(full))
                            return false;
                    }
                    catch (Exception e)
                    {
                        WriteErr("Invalid regex used: " + x + " exception: " + e);
                    }
                }
                else { if (full.ToLower().StartsWith(x)) { return false; } }
            }
            return true;
        }        
        private static void getFiles(List<string> pathRec, string searchPattern, Boolean recursiveFlag, List<FileInfo> returnList)
        {

            foreach (string d in pathRec)
            {
                getFiles(d, searchPattern, recursiveFlag, returnList);
            }
            return;
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
                    if (((addf.Attributes & FileAttributes.ReparsePoint) == 0) && CheckAll(addf.FullName))
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
                        if (((addf.Attributes & FileAttributes.ReparsePoint) == 0) && CheckAll(addf.FullName))
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
                    if (Directory.Exists(dirPart))
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
