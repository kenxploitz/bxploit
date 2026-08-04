# Domain Reconnaissance

## 1. WHOIS
```bash
whois target.com
# Registrar, creation date, name servers
```

## 2. DNS Records
```bash
dig ANY target.com
dig A target.com
dig AAAA target.com
dig MX target.com
dig NS target.com
dig TXT target.com
dig SOA target.com
dig CNAME target.com
```

## 3. Subdomain Enumeration
```bash
# Subfinder
subfinder -d target.com -silent
# Amass
amass enum -d target.com
# assetfinder
assetfinder --subs-only target.com
# crt.sh
curl -sk "https://crt.sh/?q=%25.target.com&output=json" | jq '.[].name_value'
# DNSRecon
dnsrecon -d target.com
# Fierce
fierce -domain target.com
```

## 4. Subdomain Takeover Check
```bash
# subjack
subjack -w subdomains.txt -t 100 -timeout 30 -o results.txt
# nuclei
nuclei -l subdomains.txt -t takeovers/
```

## 5. Port Scanning
```bash
# nmap
nmap -sV -sC -p- target.com
# masscan
masscan -p0-65535 target.com --rate=1000
# rustscan
rustscan -a target.com -- -sV
```

## 6. Technology Fingerprinting
```bash
# whatweb
whatweb target.com
# wappalyzer
# BuiltWith
```

## 7. Certificate Transparency
```bash
# crt.sh
curl -sk "https://crt.sh/?q=%25.target.com&output=json"
# Censys
# Certificate search
```

## 8. Google Dorking
```
site:target.com
inurl:admin site:target.com
intitle:"index of" site:target.com
filetype:pdf site:target.com
ext:php site:target.com
```

## 9. Wayback Machine
```bash
# waybackurls
echo "target.com" | waybackurls
# gau
gau target.com
```

## 10. Shodan
```bash
shodan search "hostname:target.com"
shodan search "ssl.cert.subject.cn:target.com"
```

## 11. Censys
```bash
censys search "target.com"
```

## Tools
```bash
# subfinder
# amass
# assetfinder
# httpx
# nuclei
# waybackurls
# gau
# Shodan CLI
# Censys CLI
```
