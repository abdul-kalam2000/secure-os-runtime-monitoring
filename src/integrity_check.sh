#!/bin/bash
# Author: Abdul Kalam Mansoor | EMPL ID: 24712243
# Secure OS Project - Cryptographic Hash Integrity Check
#
# Simulates TPM-style integrity validation using sha256sum as a
# substitute for a hardware TPM (used here because /dev/tpm0 is not
# available under WSL). Creates a baseline hash of a "protected" file,
# tampers with it, re-hashes, and diffs the two to detect the change.

echo "Original system configuration baseline" > systemfile.txt
sha256sum systemfile.txt > baseline.hash

echo "--- Baseline hash recorded ---"
cat baseline.hash

# Simulate unauthorized tampering
echo "Malicious code inserted" >> systemfile.txt

sha256sum systemfile.txt > current.hash

echo "--- Current hash after modification ---"
cat current.hash

echo "--- Diff between baseline and current ---"
diff baseline.hash current.hash

if ! diff -q baseline.hash current.hash > /dev/null; then
    echo "ALERT: Integrity violation detected in systemfile.txt at $(date)" >> alerts.log
    echo "Integrity violation detected — see alerts.log"
else
    echo "No integrity violation detected."
fi
