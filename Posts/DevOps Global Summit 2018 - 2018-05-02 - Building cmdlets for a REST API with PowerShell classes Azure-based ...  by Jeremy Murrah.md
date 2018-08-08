---
title: Building cmdlets for a REST API with PowerShell classes, Azure-based ...  by Jeremy Murrah
date: 2018-05-02
tags: PowerShellOrg, Summit, USA, English, Conference, DevOps Global Summit 2018
author: PowerShell.org https://www.youtube.com/channel/UCqIw7UUwC5fUBFXYX68aMrQ
---

[![Building cmdlets for a REST API with PowerShell classes, Azure-based ...  by Jeremy Murrah](https://i3.ytimg.com/vi/RgwrHpE0IK4/hqdefault.jpg "Building cmdlets for a REST API with PowerShell classes, Azure-based ...  by Jeremy Murrah")](https://www.youtube.com/watch?v=RgwrHpE0IK4)

Building cmdlets for a REST API with PowerShell classes, Azure-based integration tests and continuous deployment  by Jeremy Murrah

This talk will cover a project to write a set of cmdlets for an Infoblox dns appliance.  Code is split between cmdlets for the interface and parameter validation, and classes for modeling all the REST calls.  Will also cover the CD pipeline via appveyor with tests against an Azure appliance.
    Classes, the new feature in PowerShell 5.0, was added just for writing DSC resources right?  Not so!  Come see how classes can be used as part of a PowerShell cmdlet, providing code separation, easier parameter validation, and more.  This session will cover a working module that uses class definitions alongside standard PowerShell cmdlets to integrate with a REST API.  Learn how using defined classes makes integration between get and set cmdlets easier and potentially safer. It will also cover the release pipeline for testing and deployment, with a little Azure Resource Manager template design thrown in for fun.  All code for this session will be available on GitHub.
   This session will cover:
    - How to build a REST Uri and payload from user-provided parameter values
    - How to model objects and build class definitions and methods to reflect actions on those objects
    - How to build cmdlets that interface with both the user and the class definitions, isolating code for improved readability
    - How to build a test environment in Azure for running Pester tests and deploy to the PS Gallery with Appveyor
     This has been an amazing side project that I've been working on for over a year.  I've learned a ton about classes, github, appveyor, azure, etc. and I'm eager to share all that. Current project code can be found here:  github.com/murrahjm/Infoblox-Classy
