#!/usr/bin/php
<?php
require_once ("/var/www/html/modules/agent_console/libs/ECCP.class.php");

if (count($argv) < 2) die("Use: {$argv[0]} [agentchannel]\n");

$x = new ECCP();
try {
	print "Connect...\n";
	$cr = $x->connect("localhost", "agentconsole", "agentconsole");
	if (isset($cr->failure)) die('Failed to connect to ECCP - '.$cr->failure->message."\n");
	print_r($x->getagentqueues(count($argv) > 1 ? $argv[1] : NULL));
	print "Disconnect...\n";
	$x->disconnect();
} catch (Exception $e) {
	print_r($e);
	print_r($x->getParseError());
}
?>
