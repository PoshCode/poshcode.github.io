@@//Adapted from code @ http://mow001.blogspot.com/2006/01/msh-snap-in-to-translate.html Thanks!

using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Reflection;
using System.Diagnostics;


namespace space
{
    // This class defines the properties of a snap-in 
    [RunInstaller(true)]
    public class readIADsDNWithBinary : PSSnapIn
    {
        /// Creates instance of Snapin class. 
        public readIADsDNWithBinary() : base() { }
        ///Snapin name is used for registration 
        public override string Name
        { get { return "readIADsDNWithBinary"; } }
        /// Gets description of the snap-in.  
        public override string Description
        { get { return "Reads a IADsDNWithBinary"; } }
        public override string Vendor
        { get { return "Andrew"; } } 

    }
    /// Gets a IADsDNWithBinary
    [Cmdlet("Read", "IADsDNWithBinary")]
    public class readIADsDNWithBinaryCommand : Cmdlet
    {
        [Parameter(Position = 0, Mandatory = true)]
        public object DNWithBinary
        {
            get { return DNWithBin; }
            set { DNWithBin = value; }
        }

        private object DNWithBin;

        protected override void EndProcessing()
        {
            ActiveDs.IADsDNWithBinary DNB = (ActiveDs.IADsDNWithBinary)DNWithBin;
            ActiveDs.DNWithBinary boink = new ActiveDs.DNWithBinaryClass();
            boink.BinaryValue = (byte[])DNB.BinaryValue;
            boink.DNString = DNB.DNString;
            WriteObject(boink);
        }
    }
    /// Sets a IADsDNWithBinary
    [Cmdlet("Write", "IADsDNWithBinary")]
    public class writeIADsDNWithBinaryCommand : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public byte[] Bin
        {
            get { return bin; }
            set { bin = value; }
        }
        private byte[] bin;

        [Parameter(Mandatory = true)]
        public string DN
        {
            get { return dn; }
            set { dn = value; }
        }
        private string dn;
          

        protected override void EndProcessing()
        {
            ActiveDs.DNWithBinary boink2 = new ActiveDs.DNWithBinaryClass();
            boink2.BinaryValue = bin;
            boink2.DNString = dn;
            WriteObject(boink2);
        }
    }    
}
