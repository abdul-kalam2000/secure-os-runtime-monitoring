#!/bin/bash
# Author: Abdul Kalam Mansoor | EMPL ID: 24712243
# Secure OS Project - Simulated Detection & Response Actions
#
# Demonstrates the response side of the system: once memory_monitor.sh
# or integrity_check.sh flags an anomaly, this script simulates the
# kinds of automated responses a secure OS would take.

LOGFILE="alerts.log"

# 1. Log the event (assumes memory_log.txt warnings already exist)
grep "WARNING" memory_log.txt 2>/dev/null | while read -r line; do
    echo "ALERT: $line at $(date)" >> $LOGFILE
done

# 2. Simulated automated alert to an administrator
echo "Simulated response: Security alert sent to system administrator. [$(date)]" >> $LOGFILE

# 3. Simulated process termination (future scope: replace echo with real kill)
echo "Simulated response: High-memory process would be terminated to protect system integrity. [$(date)]" >> $LOGFILE

# 4. Simulated file restoration after an integrity violation (future scope: restore from backup)
echo "Simulated response: systemfile.txt restored from backup after integrity violation. [$(date)]" >> $LOGFILE

cat $LOGFILE
