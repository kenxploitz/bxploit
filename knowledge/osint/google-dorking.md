# Google Dorking

## Basic Operators
```
site:target.com          # Limit to domain
inurl:admin              # URL contains
intitle:"index of"       # Title contains
filetype:pdf             # File type
ext:php                  # Extension
intext:password          # Text contains
```

## Common Dorks
```
# Directory listing
site:target.com intitle:"index of"
site:target.com intitle:"index of /"
site:target.com intitle:"index of" "parent directory"

# Login pages
site:target.com inurl:login
site:target.com inurl:admin
site:target.com intitle:"admin login"
site:target.com inurl:wp-login.php

# Configuration files
site:target.com ext:xml
site:target.com ext:json
site:target.com ext:env
site:target.com ext:yml
site:target.com ext:conf

# Database files
site:target.com ext:sql
site:target.com ext:bak
site:target.com ext:dump

# Log files
site:target.com ext:log
site:target.com inurl:log

# Error messages
site:target.com "error" "warning" "fatal"
site:target.com "SQL syntax"
site:target.com "mysql_fetch"
site:target.com "ORA-"

# Exposed documents
site:target.com filetype:pdf
site:target.com filetype:doc
site:target.com filetype:xls
site:target.com filetype:ppt

# API endpoints
site:target.com inurl:api
site:target.com inurl:v1
site:target.com inurl:v2

# Source code
site:target.com ext:php
site:target.com ext:jsp
site:target.com ext:asp
site:target.com ext:py

# Backup files
site:target.com ext:bak
site:target.com ext:old
site:target.com ext:backup
site:target.com ext:save

# Test environments
site:target.com inurl:test
site:target.com inurl:dev
site:target.com inurl:staging
site:target.com inurl:demo

# Sensitive information
site:target.com "password"
site:target.com "api_key"
site:target.com "secret"
site:target.com "token"
site:target.com "credentials"

# WordPress
site:target.com inurl:wp-content
site:target.com inurl:wp-admin
site:target.com inurl:wp-includes

# Joomla
site:target.com inurl:administrator
site:target.com inurl:components
```

## Advanced Dorks
```
# Combine operators
site:target.com inurl:admin ext:php
site:target.com intitle:"index of" "backup"
site:target.com ext:sql "INSERT INTO"
site:target.com inurl:config ext:php

# Exclude results
site:target.com -www
site:target.com -inurl:login

# Date range
site:target.com after:2023-01-01 before:2024-01-01

# Related sites
related:target.com
```

## Bing Dorks
```
site:target.com
ip:target.com
```

## Yandex Dorks
```
site:target.com
url:target.com
```
