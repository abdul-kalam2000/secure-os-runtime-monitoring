# Memory-Assisted Secure OS with Hardware-Level Runtime Monitoring

A simulated secure operating system architecture that pairs lightweight runtime memory monitoring with cryptographic integrity checking to detect the kind of low-level attacks that typically evade software-only defenses: memory tampering, race-condition privilege escalation, and unauthorized file modification.

> Course project — Secure Operating Systems (I0420), CUNY City College
> Author: **Abdul Kalam Mansoor**

## Threat model

The project targets three concrete attack classes:

| Threat | Risk | How it's simulated |
|---|---|---|
| **Race condition exploits** | Unsynchronized access to shared resources lets an attacker escalate privileges or corrupt state | Two threads concurrently withdraw from a shared balance with no locking |
| **Memory abuse / code injection** | Malicious code injected into a process's memory space, or memory permissions abused | A runtime monitor scans `/proc` for processes with abnormal memory usage |
| **Integrity violations** | Silent tampering with critical files (backdoors, config changes) | Cryptographic hashing establishes a baseline and detects any drift from it |

The design leans on the hardware security primitives a real secure OS would use — MMU-enforced access boundaries and TPM-verified integrity — implemented here in software where the target hardware/VM didn't expose them directly (see [Notes on the WSL environment](#notes-on-the-wsl-environment)).

## What's in this repo

```
src/
  memory_monitor.sh      # Scans /proc for processes exceeding a memory threshold, logs warnings
  race_condition.c       # Two unsynchronized threads racing on a shared balance
  integrity_check.sh     # Hash-based (sha256sum) baseline-vs-current integrity check
  response_actions.sh    # Simulated detection responses: alerting, logging, "termination", restore
docs/
  Secure_OS_Report.pdf   # Full written report with setup, screenshots, and analysis
```

## How it works

**1. Memory monitoring** — `memory_monitor.sh` walks every PID in `/proc`, reads `VmRSS` from `/proc/<pid>/status`, and flags anything over a configurable threshold (10MB, tuned down from 50MB for demo visibility) into `memory_log.txt`.

**2. Race condition demo** — `race_condition.c` spins up two threads that both read, delay (`usleep`), and write a shared `balance` variable with no mutex. This is the classic read-modify-write race that lets concurrent, unsynchronized access corrupt shared state or be exploited for privilege escalation.

**3. Integrity checking** — `integrity_check.sh` hashes a "protected" file with `sha256sum`, tampers with it, re-hashes, and diffs the two hashes to prove the change is detectable. This substitutes for a hardware TPM, which wasn't available in the WSL test environment.

**4. Detection & response** — `response_actions.sh` ties it together: memory warnings and hash mismatches get written to `alerts.log`, alongside simulated response actions (administrator notification, process termination, file restoration) that stand in for what a production system would automate via `cgroups`, `AppArmor`, or SELinux.

## Running it

```bash
chmod +x src/*.sh
./src/memory_monitor.sh          # produces memory_log.txt
gcc -O0 -static -o race_demo src/race_condition.c -lpthread
./race_demo
./src/integrity_check.sh         # produces baseline.hash, current.hash, alerts.log
./src/response_actions.sh        # reads memory_log.txt, appends simulated responses to alerts.log
```

## Notes on the WSL environment

The original plan called for `auditd` for syscall-level auditing and a real TPM (`/dev/tpm0`) for hardware-backed hashing. Neither was available in the WSL test environment, so the project substitutes a `/proc`-based Bash monitor for `auditd` and `sha256sum` for the TPM. The report documents this limitation and what a full deployment (real TPM, kernel hooks, `AppArmor`/SELinux sandboxing) would add.

## References

1. Linux Foundation, *proc — process information pseudo-filesystem*, man7.org.
2. Trusted Computing Group, *Trusted Platform Module Library Specification*.
3. MITRE, *CWE-362: Race Condition*.
4. Red Hat, *SELinux Project Overview*.

(Full reference list in the report.)
