<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF8" />
  <title>{$ELXFRAMEWORK_NAME} - {$PAGE_NAME}</title>
  <link rel="stylesheet" href="themes/blackmin/styles.css" /> 
  <link rel="stylesheet" href="themes/blackmin/help.css" /> 
</head>
<body class="elx-blackmin-login">
<div class="logo"><img src="images/framework-logo-mini-mono.png" /></div>
<form method="POST">
    <div>
        <div class="title">&nbsp;&raquo;&nbsp;{$WELCOME}</div>
        <br/>
        <div>{$ENTER_USER_PASSWORD}</div>
        <br/>
        <div>
            <div><div class="label">{$USERNAME}:</div><div class="input"><input type="text" id="input_user" name="input_user" /></div></div>
            <div><div class="label">{$PASSWORD}:</div><div class="input"><input type="password" name="input_pass" /></div></div>
            <div><input type="submit" name="submit_login" value="{$SUBMIT}" /></div>
        </div>
    </div>
</form>
<br/>
<div align="center" class="copyright"><a href="{$ELXFRAMEWORK_WEBSITE}" target='_blank'>{$ELXFRAMEWORK_NAME}</a> is licensed under <a href="http://www.opensource.org/licenses/gpl-license.php" target='_blank'>GPL</a>{if $ELXFOOTER_BYPALOSANTO} by <a href="http://www.palosanto.com" target='_blank'>PaloSanto Solutions</a>. 2006 - {$currentyear}.{/if}</div>
<script type="text/javascript">
    document.getElementById("input_user").focus();
</script>
</body>
</html>