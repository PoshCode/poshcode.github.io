$menu = @"
=================================
      conference 2015 book sales
=================================
    1. Book Title
    2. Book discription
    3. book id
    4. Book List Price
    5. display Sales Info
    6. Write to File
    7. Exit Program
==================================
"@

switch ($responce)
{
    1 { [string] $title=read-host "enter title"
            if ($title -match '\w') {continue}
                else {write-warning "`@ enter a valid title..."
                pause
                break
                }
