#!/bin/bash

cat /proc/cpuinfo | grep -oP '(?<=model\sname\s\:\s)(.*)' | uniq
