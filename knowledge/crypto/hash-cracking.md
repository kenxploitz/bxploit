# Hash Identification and Cracking

## Hash Identification
```bash
# hashid
hashid '5f4dcc3b5aa765d61d8327deb882cf99'
# hash-identifier
hash-identifier
# haiti
haiti '5f4dcc3b5aa765d61d8327deb882cf99'
```

## Common Hash Types
```
MD5: 32 hex chars (e4d909c290d0fb1ca068ffaddf22cbd0)
SHA1: 40 hex chars (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d)
SHA256: 64 hex chars
SHA512: 128 hex chars
NTLM: 32 hex chars (similar to MD5 format)
bcrypt: $2a$/$2b$/$2y$ prefix
MySQL: *AABB... (starts with *)
Linux: $6$salt$hash (SHA-512)
```

## Hashcat Modes
```bash
# MD5
hashcat -m 0 hash.txt rockyou.txt
# SHA1
hashcat -m 100 hash.txt rockyou.txt
# SHA256
hashcat -m 1400 hash.txt rockyou.txt
# SHA512
hashcat -m 1800 hash.txt rockyou.txt
# NTLM
hashcat -m 1000 hash.txt rockyou.txt
# NetNTLMv2
hashcat -m 5600 hash.txt rockyou.txt
# Kerberos TGS
hashcat -m 13100 hash.txt rockyou.txt
# AS-REP
hashcat -m 18200 hash.txt rockyou.txt
# bcrypt
hashcat -m 3200 hash.txt rockyou.txt
# MySQL
hashcat -m 300 hash.txt rockyou.txt
# PostgreSQL
hashcat -m 12 hash.txt rockyou.txt
# Wordpress
hashcat -m 400 hash.txt rockyou.txt
# Joomla
hashcat -m 11 hash.txt rockyou.txt
# Django
hashcat -m 10000 hash.txt rockyou.txt
```

## John the Ripper
```bash
# Auto-detect
john hash.txt --wordlist=rockyou.txt
# Specify format
john hash.txt --format=raw-md5 --wordlist=rockyou.txt
john hash.txt --format=raw-sha1 --wordlist=rockyou.txt
john hash.txt --format=raw-sha256 --wordlist=rockyou.txt
john hash.txt --format=nt --wordlist=rockyou.txt
john hash.txt --format=bcrypt --wordlist=rockyou.txt
john hash.txt --format=krb5tgs --wordlist=rockyou.txt
john hash.txt --format=krb5asrep --wordlist=rockyou.txt
```

## Rules
```bash
# Best64
hashcat -m 0 hash.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule
# OneRuleToRuleThemAll
hashcat -m 0 hash.txt rockyou.txt -r OneRuleToRuleThemAll.rule
# d3ad0ne
hashcat -m 0 hash.txt rockyou.txt -r d3ad0ne.rule
```

## Mask Attack
```bash
# 8 char lowercase
hashcat -m 0 hash.txt -a 3 ?l?l?l?l?l?l?l?l
# 8 char mixed
hashcat -m 0 hash.txt -a 3 ?a?a?a?a?a?a?a?a
# Custom mask
hashcat -m 0 hash.txt -a 3 ?u?l?l?l?l?l?d?d
```

## Rainbow Tables
```bash
# rcrack
rcrack *.rt -h hash
# Online
# crackstation.net
# hashes.com
# hashes.org
```

## Online Cracking
```bash
# crackstation.net
# hashes.com
# md5decrypt.net
# hashkiller.com
```
