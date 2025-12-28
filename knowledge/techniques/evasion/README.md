---
title: Evasion Techniques
category: techniques
tags: [evasion, amsi, applocker, defender]
last_updated: 2025-12-27
---

# Evasion Techniques

## Overview

Evasion techniques are methods used to bypass security controls during penetration testing and red team engagements. Understanding these techniques is essential for both offensive security professionals and defenders.

Modern Windows environments employ multiple layers of security:
- **Antivirus/EDR**: Signature and behavior-based detection
- **AMSI**: Script-based attack detection
- **AppLocker/WDAC**: Application whitelisting
- **Windows Defender**: Built-in protection suite

## Categories of Evasion

### 1. Antimalware Scan Interface (AMSI) Bypass

AMSI provides visibility into script execution for security products. Bypassing AMSI allows execution of malicious PowerShell, VBScript, and JScript without triggering alerts.

**Techniques covered:**
- Memory patching
- Reflection-based bypasses
- PowerShell downgrade attacks
- Obfuscation methods

[AMSI Bypass Techniques](amsi-bypass.md)

### 2. AppLocker Bypass

AppLocker restricts which applications can run. Bypassing involves finding trusted locations or binaries that can execute arbitrary code.

**Techniques covered:**
- Trusted folder abuse
- LOLBAS (Living Off The Land Binaries)
- Alternate Data Streams
- .NET framework abuse

[AppLocker Bypass Techniques](applocker-bypass.md)

### 3. Windows Defender Evasion

Windows Defender combines multiple protection technologies. Evasion requires understanding and circumventing each component.

**Techniques covered:**
- Signature evasion
- Obfuscation techniques
- In-memory execution
- Living off the land

[Windows Defender Evasion](defender-evasion.md)

## General Evasion Principles

### Defense in Depth Considerations

Modern environments layer multiple controls:

```
┌─────────────────────────────────────┐
│         Network Security            │
├─────────────────────────────────────┤
│      Application Whitelisting       │
├─────────────────────────────────────┤
│          AMSI / Script Block        │
├─────────────────────────────────────┤
│         AV/EDR Detection            │
├─────────────────────────────────────┤
│      Behavioral Analysis            │
└─────────────────────────────────────┘
```

### Key Evasion Strategies

1. **Know Your Target**: Enumerate security controls before payload delivery
2. **Test Payloads**: Use isolated environments matching target configuration
3. **Layer Techniques**: Combine multiple evasion methods
4. **Stay Current**: Security controls and bypasses evolve constantly
5. **Clean Up**: Remove artifacts and restore original state

### Enumeration Before Evasion

```powershell
# Check Windows Defender status
Get-MpComputerStatus

# Check AppLocker policies
Get-AppLockerPolicy -Effective | Select-Object -ExpandProperty RuleCollections

# Check AMSI providers
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\AMSI\Providers"

# Check running security processes
Get-Process | Where-Object {$_.ProcessName -match 'defender|sense|sentinel|crowd|carbon|cylance'}
```

## Quick Reference

| Control | Primary Bypass | Risk Level |
|---------|---------------|------------|
| AMSI | Memory patching | Medium |
| AppLocker | LOLBAS/Trusted folders | Low-Medium |
| Defender Real-time | Obfuscation/In-memory | High |
| Defender Cloud | Custom payloads | High |
| EDR | Varies by product | Very High |

## Legal and Ethical Notice

These techniques should only be used:
- During authorized penetration tests
- In lab environments for learning
- With explicit written permission

Unauthorized use of these techniques is illegal and unethical.

## Related Resources

- [LOLBAS Project](https://lolbas-project.github.io/)
- [GTFOBins](https://gtfobins.github.io/)
- [MITRE ATT&CK - Defense Evasion](https://attack.mitre.org/tactics/TA0005/)
