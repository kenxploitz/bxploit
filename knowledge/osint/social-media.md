# Social Media OSINT

## 1. LinkedIn
```bash
# Company employees
# Job postings (technology clues)
# Organization structure
# dork: site:linkedin.com "target company"
```

## 2. GitHub
```bash
# Search for secrets
trufflehog github --repo target/repo
gitleaks detect --source .
# Search organization
# Search for credentials, API keys
# git-dumper
python3 git-dumper.py http://target/.git/ output/
```

## 3. Twitter/X
```bash
# Search mentions
# Search for employees
# Search for technology mentions
# dork: site:twitter.com "target company"
```

## 4. Facebook
```bash
# Company page
# Employee profiles
# Posts with location data
```

## 5. Instagram
```bash
# Location data
# Employee photos (badge numbers, screens)
```

## 6. Reddit
```bash
# Search for company mentions
# Employee complaints (info leaks)
```

## 7. Username Enumeration
```bash
# sherlock
sherlock username
# maigret
maigret username
```

## 8. People Search
```bash
# pipl.com
# spokeo.com
# thatsthem.com
```

## 9. Company OSINT
```bash
# SEC filings
# Annual reports
# Press releases
# Job postings
```

## 10. Metadata Extraction
```bash
# EXIF from images
exiftool image.jpg
# PDF metadata
exiftool document.pdf
```

## Tools
```bash
# sherlock
# maigret
# holehe
# social-analyzer
# trufflehog
# gitleaks
```
