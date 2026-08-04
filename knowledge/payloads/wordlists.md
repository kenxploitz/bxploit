# Useful Wordlists

## Web Content Discovery
```
/usr/share/wordlists/dirb/common.txt
/usr/share/wordlists/dirb/big.txt
/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
/usr/share/seclists/Discovery/Web-Content/common.txt
/usr/share/seclists/Discovery/Web-Content/big.txt
/usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt
/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
```

## Subdomains
```
/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt
/usr/share/seclists/Discovery/DNS/namelist.txt
```

## Passwords
```
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/fasttrack.txt
/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt
/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-10000.txt
/usr/share/seclists/Passwords/Common-Credentials/top-20-common-SSH-passwords.txt
```

## Users
```
/usr/share/seclists/Usernames/top-usernames-shortlist.txt
/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt
```

## LFI
```
/usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-linux.txt
/usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-windows.txt
/usr/share/seclists/Fuzzing/LFI/LFI-LFISuite-pathtotest-huge.txt
```

## SQL Injection
```
/usr/share/seclists/Fuzzing/SQLi/Generic-SQLi.txt
/usr/share/seclists/Fuzzing/special-chars.txt
```

## XSS
```
/usr/share/seclists/Fuzzing/XSS/XSS-Jhaddix.txt
/usr/share/seclists/Fuzzing/XSS/bruteXSS.txt
```

## API
```
/usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt
/usr/share/seclists/Discovery/Web-Content/swagger.txt
```

## SecLists Repository
```bash
# Install SecLists
apt install seclists
# Or clone
git clone https://github.com/danielmiessler/SecLists.git
```

## Custom Wordlists
```bash
# Cewl - generate wordlist from website
cewl http://target.com -w wordlist.txt
# Crunch - generate custom wordlists
crunch 8 8 -t @@@@@@@% -o wordlist.txt
# Username generation
username-anarchy --inputfile names.txt --select-format first.last
```
