# Image OSINT

## 1. EXIF Data Extraction
```bash
# exiftool
exiftool image.jpg
# Specific tags
exiftool -GPSLatitude -GPSLongitude image.jpg
exiftool -DateTimeOriginal image.jpg
exiftool -Make -Model image.jpg
exiftool -Artist -Copyright image.jpg
```

## 2. Reverse Image Search
```bash
# Google Images
# https://images.google.com
# TinEye
# https://tineye.com
# Yandex Images
# https://yandex.com/images/
# Bing Visual Search
# https://www.bing.com/images
```

## 3. Geolocation from Images
```bash
# Extract GPS coordinates
exiftool -GPSLatitude -GPSLongitude image.jpg
# Convert to decimal
# Map coordinates
```

## 4. Image Metadata Analysis
```bash
# All metadata
exiftool -a -G1 image.jpg
# GPS info
exiftool -gps:all image.jpg
# Camera info
exiftool -Make -Model -Software image.jpg
# Timestamps
exiftool -DateTimeOriginal -CreateDate -ModifyDate image.jpg
```

## 5. Image Steganography
```bash
# steghide
steghide extract -sf image.jpg
steghide info image.jpg
# zsteg
zsteg image.png
# stegsolve
java -jar Stegsolve.jar
# binwalk
binwalk -e image.jpg
```

## 6. Face Recognition
```bash
# Find person across platforms
# PimEyes
# FindClone
```

## 7. Screenshot Analysis
```bash
# Extract text (OCR)
tesseract image.jpg output
# Identify locations from screenshots
# Identify UI elements
```

## 8. Image Forensics
```bash
# Check for manipulation
# Forensically
# FotoForensics
# Error Level Analysis (ELA)
```

## Tools
```bash
# exiftool
# steghide
# zsteg
# stegsolve
# binwalk
# tesseract (OCR)
# GIMP
```
