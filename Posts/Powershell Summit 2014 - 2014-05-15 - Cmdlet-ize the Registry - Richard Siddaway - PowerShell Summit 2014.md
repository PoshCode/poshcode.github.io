---
title: Cmdlet-ize the Registry - Richard Siddaway - PowerShell Summit 2014
date: 2014-05-15
tags: PowerShellOrg, Summit, USA, English, Conference, Powershell Summit 2014
author: Aaron Hoover https://www.youtube.com/channel/UCX27-k3xeNSgXVklCx-dnXQ
---

[![Cmdlet-ize the Registry - Richard Siddaway - PowerShell Summit 2014](https://i1.ytimg.com/vi/xkzAHUndq4w/hqdefault.jpg "Cmdlet-ize the Registry - Richard Siddaway - PowerShell Summit 2014")](https://www.youtube.com/watch?v=xkzAHUndq4w)

PowerShell supplies a number of ways for you to work with the Registry. On the local machine you have the registry provider -- but you can't use it against remote machines. For remote access you can use WMI or .NET. The WMI, CIM and WSMAN cmdlets can be used to work with the registry on remote machines. All of these cmdlets involve using large constants and an awkward syntax with no consistencies between them. This session will show you how to create your own module to work with the registry on the local or remote machines. Using the CDXML -- objects over cmdlets -- technology introduced with PowerShell 3.0 you can take the registry WMI class and make cmdlets to search for , read, write, create and delete items in the registry. Your take away is a module of cmdlets that enable you to work easily with the registry. You will aslo understend the techniques you can use to create your own cmdlets from WMI classes -- this is the way Microsoft writes many of their cmdlets.
