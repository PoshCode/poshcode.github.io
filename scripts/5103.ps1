#search default browser path
([Regex]"(?<=`")(.*)(?=`"\s)").Match((cmd /c ftype (cmd /c assoc .html).Split('=')[1])).Value
