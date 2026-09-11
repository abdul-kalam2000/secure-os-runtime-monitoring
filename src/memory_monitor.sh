#!/bin/bash
# Author: Abdul Kalam Mansoor | EMPL ID: 24712243
# Secure OS Project - Runtime Memory Monitor

LOGFILE="memory_log.txt"
THRESHOLD_KB=10000   # Warn if memory usage exceeds this many KB

echo "=== Memory Monitor Started at $(date) ===" >> $LOGFILE

for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    if [ -r /proc/$pid/status ]; then
        name=$(grep Name /proc/$pid/status | awk '{print $2}')
        vmrss=$(grep VmRSS /proc/$pid/status | awk '{print $2}')
        if [ "$vmrss" -gt "$THRESHOLD_KB" ]; then
            echo "WARNING: High memory usage detected!" >> $LOGFILE
            echo "PID: $pid | Process: $name | Memory: ${vmrss}KB" >> $LOGFILE
        fi
    fi
done

echo "=== Memory Monitor Finished at $(date) ===" >> $LOGFILE
