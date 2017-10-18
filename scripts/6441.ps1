
        $escapedGuid =  "\" + ((([GUID]$guid).ToByteArray() |% {"{0:x2}" -f $_}) -join '\')



