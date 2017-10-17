#!/bin/bash
cat /proc/cpuinfo | grep -oP '(?<=name\s\:\s)(.*)' | uniq
