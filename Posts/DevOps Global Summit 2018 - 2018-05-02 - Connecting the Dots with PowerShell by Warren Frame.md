---
title: Connecting the Dots with PowerShell by Warren Frame
date: 2018-05-02
tags: PowerShellOrg, Summit, USA, English, Conference, DevOps Global Summit 2018
author: PowerShell.org https://www.youtube.com/channel/UCqIw7UUwC5fUBFXYX68aMrQ
---

[![Connecting the Dots with PowerShell by Warren Frame](https://i2.ytimg.com/vi/5SVRCkUtKJU/hqdefault.jpg "Connecting the Dots with PowerShell by Warren Frame")](https://www.youtube.com/watch?v=5SVRCkUtKJU)

One of PowerShell's greatest strengths is its ability to glue pretty much any technologies together. We'll use that strength to pull data from a number of services, connecting the resulting dots with a graph database that could be used as a lightweight CMDB.


We'll talk about:
 

* Different interfaces PowerShell can use, from modules to .NET libraries

* Graph databases like Neo4j, and how these can be useful for sysadmins

* A practical (janky) CMDB, and why these can be useful

     ## Why the topic:

I'm a fan of CMDBs that have useful data.  They can drive automation, monitoring and alerting, reporting, and anything else that benefits from visibility.

It just so happens that:

* This is a great way to illustrate the various ways to talk to things in PowerShell (modules, web APIs, .NET libraries, binaries, etc.)

* Graph databases are awesome, and map to real life systems more easily than the cumbersome fun of primary keys, foreign keys, and strict schemas

* Neo4j has a free, cross platform community edition, and there's a simple PowerShell module to work with it

* We can instill other important lessons, e.g. modules/abstraction, community/sharing

* We can provide a practical example that folks without a reasonable CMDB could borrow and extend

* Heavy weight, expensive, actual CMDBs are a poor fit for shops adopting DevOps practices and principles
