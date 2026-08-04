# Email OSINT

## 1. Email Harvesting
```bash
# theHarvester
theHarvester -d target.com -b google,bing,yahoo,linkedin
# hunter.io
# email-format.com
```

## 2. Breach Database Search
```bash
# Have I Been Pwned
curl -sk "https://haveibeenpwned.com/api/v3/breachedaccount/email@example.com"
# dehashed
# leakedsource
# breachdirectory
```

## 3. Email Validation
```bash
# Verify email exists
# SMTP VRFY
telnet target 25
VRFY user@target.com
# RCPT TO
telnet target 25
MAIL FROM:<test@test.com>
RCPT TO:<user@target.com>
```

## 4. Email Header Analysis
```bash
# Extract IP from headers
# Check SPF, DKIM, DMARC
dig TXT target.com | grep -i "spf\|dmarc"
dig TXT _dmarc.target.com
```

## 5. Email Pattern Discovery
```bash
# Find naming convention
# firstname.lastname@target.com
# firstinitial.lastname@target.com
# firstname@target.com
```

## 6. Credential Stuffing
```bash
# If credentials found in breach
# Try on target services
```

## 7. Phishing Recon
```bash
# Identify email security
# Check for email gateways
# Identify spam filters
```

## Tools
```bash
# theHarvester
# holehe
# h8mail
# hunter.io
# emailrep.io
```
