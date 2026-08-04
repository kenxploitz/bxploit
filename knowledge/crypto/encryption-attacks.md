# Encryption Attacks

## 1. Padding Oracle (CBC)
```bash
# PadBuster
padBuster http://target/encrypted EncryptedValue 16
# Decrypt
padBuster http://target/encrypted EncryptedValue 16 -decrypt
# Encrypt (forge)
padBuster http://target/encrypted EncryptedValue 16 -encrypt -plaintext "admin"
```

## 2. CBC Bit Flipping
```python
# Modify ciphertext to change plaintext
# XOR the byte you want to change with the byte it is now XOR the byte you want it to be
def flip(iv, pos, desired):
    iv = bytearray(iv)
    iv[pos] ^= desired
    return bytes(iv)
```

## 3. ECB Oracle
```bash
# ECB mode - identical plaintext = identical ciphertext
# Use for:
# - Block boundary detection
# - Plaintext recovery
# - Byte-at-a-time attack
```

## 4. ECB Cut and Paste
```python
# Rearrange ECB blocks to modify ciphertext
# Swap blocks to change user role
```

## 5. Key Recovery
```bash
# If key is derived from weak source
# Brute force
# Known plaintext attack
```

## 6. IV Reuse (AES-CBC)
```bash
# If IV is reused with same key
# XOR ciphertexts to XOR plaintexts
```

## 7. Weak Random
```bash
# If PRNG is weak
# Predict next value
# seed recovery
```

## 8. Timing Attack
```bash
# Measure response time to guess valid padding
# Or valid MAC
```

## 9. Length Extension Attack (MD5/SHA1)
```bash
# If MAC is hash(secret || message)
# Can extend message without knowing secret
hashpump -s original_mac -d original_data -a append_data -k key_length
```

## 10. Bleichenbacher Attack (RSA)
```bash
# PKCS#1 v1.5 padding oracle
# Decrypt RSA ciphertext
```

## 11. Hash Length Extension
```bash
# For MD5, SHA1, SHA256 (not SHA3, not HMAC)
hashpump -s original_hash -d original_data -a append_data -k key_length
```

## 12. AES-GCM Nonce Reuse
```bash
# If nonce is reused
# XOR ciphertexts
# Recover authentication key
```

## Tools
```bash
# PadBuster
# hashpump
# openssl
openssl enc -aes-256-cbc -d -in encrypted -out decrypted -K key -iv iv
# CyberChef
```
