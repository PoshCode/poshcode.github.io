#!/bin/bash
cat /proc/scsi/scsi | grep -oP '(?<=Model\:\s)(.*)(?=Rev)' | head -1
