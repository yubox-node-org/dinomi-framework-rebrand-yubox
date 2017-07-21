#!/usr/bin/php
<?php

if ($argc < 3) {
    fputs(STDERR, "Uso: {$argv[0]} ruta/a/comps.xml lista/de/paquetes");
    exit(1);
}

$xml = simplexml_load_file($argv[1]);
if (!is_object($xml)) {
    fputs(STDERR, "Fallo al cargar archivo XML\n");
    exit(1);
}
$pkgs = file($argv[2]);
if (!is_array($pkgs)) {
    fputs(STDERR, "Fallo al cargar lista de paquetes\n");
    exit(1);
}
foreach (array_map('trim', $pkgs) as $pkg) {
    // Agregar TODOS los paquetes a grupo DINOMI
    $entry = $xml->group[1]->packagelist->addChild('packagereq',$pkg);
    $entry->addAttribute('type', 'mandatory');
}
$xml = $xml->asXML();

$dom = new DOMDocument();
$dom->preserveWhiteSpace = FALSE;
$dom->formatOutput = TRUE;
$dom->loadXML($xml);
$r = file_put_contents($argv[1], $dom->saveXML()."\n");
if ($r === FALSE) {
    fputs(STDERR, "Fallo al escribir archivo XML\n");
    exit(1);
}

exit(0);
