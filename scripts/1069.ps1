# I want do demonstrate a Compare-object bug
# Bernd Kriszio - http://pauerschell.blogspot.com/ 
 
1, 2, 3, 4, 5 > .\textfile_a.txt
1, 2, 4, 5, 6 > .\textfile_b.txt
cat .\textfile_a.txt
cat .\textfile_b.txt
compare-object (gc .\textfile_a.txt) (gc .\textfile_b.txt) -inc
<#yields
InputObject                                SideIndicator                             
-----------                                -------------                             
1                                          ==                                        
2                                          ==                                        
4                                          ==                                        
5                                          ==                                        
6                                          =>                                        
3                                          <=                                        

I think it has to be
InputObject                                SideIndicator                             
-----------                                -------------                             
1                                          ==                                        
2                                          ==                                        
3                                          <=                                        
4                                          ==                                        
5                                          ==                                        
6                                          =>                                        
#>

