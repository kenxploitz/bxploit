# BloodHound Usage and Analysis

## 1. Data Collection
```bash
# Python ingestor
bloodhound-python -u user -p password -d domain.com -dc dc.domain.com -c All
# SharpHound (Windows)
SharpHound.exe -c All
# Remote collection
bloodhound-python -u user -p password -d domain.com -dc dc.domain.com --zip
```

## 2. Common Queries
```
# Find all Domain Admins
MATCH p=shortestPath((u:User {adminCount:1}),(g:Group {name:"DOMAIN ADMINS@DOMAIN.COM"})) RETURN p

# Find path from user to Domain Admin
MATCH p=shortestPath((u:User {name:"USER@DOMAIN.COM"}),(g:Group {name:"DOMAIN ADMINS@DOMAIN.COM"})) RETURN p

# Find Kerberoastable users
MATCH (u:User {hasspn:true}) RETURN u

# Find AS-REP roastable users
MATCH (u:User {dontreqpreauth:true}) RETURN u

# Find computers with unconstrained delegation
MATCH (c:Computer {unconstraineddelegation:true}) RETURN c

# Find users with DCSync rights
MATCH p=(u)-[:GetChanges|GetChangesAll]->(d:Domain) RETURN p

# Find shortest path to Domain Admin
MATCH p=shortestPath((u:User),(g:Group {name:"DOMAIN ADMINS@DOMAIN.COM"})) WHERE NOT u=g RETURN p
```

## 3. Attack Path Analysis
```
# High-value targets
1. Users with adminCount=1
2. Computers with unconstrained delegation
3. Users with SPNs (Kerberoastable)
4. Users without preauth (AS-REP)
5. Users with DCSync rights
```

## 4. Custom Queries
```
# Find users with description containing password
MATCH (u:User) WHERE u.description CONTAINS "password" RETURN u

# Find computers where user is local admin
MATCH p=(u:User {name:"USER@DOMAIN.COM"})-[:AdminTo]->(c:Computer) RETURN p

# Find all users in group
MATCH (u:User)-[:MemberOf]->(g:Group {name:"GROUP@DOMAIN.COM"}) RETURN u
```

## 5. Sharphound Collection
```bash
# All collection methods
.\SharpHound.exe -c All --zipfilename output.zip
# Specific methods
.\SharpHound.exe -c Group,LocalAdmin,Session,Trusts
# Loop collection
.\SharpHound.exe -c All --loop --loopduration 02:00:00
```

## 6. Neo4j Queries
```cypher
// Count nodes
MATCH (n) RETURN labels(n), count(n)

// Find all users
MATCH (u:User) RETURN u.name

// Find all groups
MATCH (g:Group) RETURN g.name

// Find all computers
MATCH (c:Computer) RETURN c.name
```
