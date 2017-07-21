#!/usr/bin/php
<?php
$user_home="/home/".get_current_user();
//include $user_home."/bin/progressbar.class.php";
require_once 'Console/ProgressBar.php';
//$arch="elastix";
//$arch="x86_64";
$arch="Dinomi_Pelado_10022017";
$rppath="repodata";
$distroFolder="kickstart_build";
$tmpltsndstff="utils";
$repoTemplatepath="RepodataOriginalC7/repodata";
$compsTemplatepath="compsELXTemplate";
$output_path=$user_home."/".$distroFolder."/".$arch."/".$rppath."/";
$repopath=$user_home."/".$distroFolder."/".$tmpltsndstff."/".$repoTemplatepath."/";
$compspath=$user_home."/".$distroFolder."/".$tmpltsndstff."/".$compsTemplatepath."/";
$crtrppath=$user_home."/".$distroFolder."/".$arch."/";

if (PHP_SAPI === 'cli'){
	if ( "$argc" <> "1"){
		exit("Use: $argv[0] \n\n Ej: $argv[0] ".PHP_EOL);
	}
}


$fname = 'comps.xml';
$fname = $output_path.$fname;

printf("\nBORRANDO Y COPIANDO LOS ARCHIVOS NECESARIOS EN LA RUTA ELASTIX".PHP_EOL);
printf("ESPERE UN MOMENTO POR FAVOR...".PHP_EOL);
system("rm -f $output_path"."*");
system("rsync -avh --exclude '*comps.xml' --progress $repopath $output_path");
system("rsync -avh --progress $compspath'comps.xml' $output_path");


date_default_timezone_set('America/Guayaquil');


if (file_exists($fname)) {
	//A lo que inserta no hace un salto de linea. El .PHP_EOL funciona a medias
	$xml = simplexml_load_file($fname);
	printf("\nLIMPIANDO LOS NOMBRES DE LOS RPMS DE LA RUTA ELASTIX".PHP_EOL);
	printf("ESPERE UN MOMENTO POR FAVOR...".PHP_EOL);
	//$pkgsarr = arraymaker_rpms($crtrppath."Elastix");
	$pkgsarr = arraymaker_rpms($crtrppath."Dinomi");
	printf("ACTUALIZANDO LA INFORMACION DEL ARCHIVO COMPS.XML CON LOS PAQUETES ACTUALES DE LA RUTA ELASTIX".PHP_EOL);
	printf("ESPERE UN MOMENTO POR FAVOR...".PHP_EOL);
	//$progressBar = new ProgressBar(100);


	$endarr = count($pkgsarr)-1;
	$bar1 = new Console_ProgressBar('[%bar%] %percent%', '=>', ' ', 80, $endarr);


	$inidate1 = date("Y-d-m H:i:s");
	//echo $inidate1."\n";
	for ($nmpkg = 0; $nmpkg < count($pkgsarr) ; $nmpkg++ ){
		//printf($pkgsarr[$namepkg].PHP_EOL);
		$namepkg = trim($pkgsarr[$nmpkg]);
		$entry = $xml->group[1]->packagelist->addChild('packagereq',"$namepkg");
		$entry->addAttribute('type', 'mandatory');

		$bar1->update($nmpkg);

		sleep(1);
	}
	//echo date('h:i:s') . "\n";
	$enddate1 = date("Y-d-m H:i:s");
	//echo $enddate1."\n";
	echo "\n";
	echo "Han pasado ".dateDiff($inidate1, $enddate1). "\n";
	echo "\n";
	$xml = $xml->asXML();
	//$xml1 = $xml->asXML();
	$dom = new DOMDocument();
	$dom->loadXML($xml);
	#$dom->formatOutput = true;
	$formatedXML = $dom->saveXML();
	$dom = new DOMDocument();
	$dom->preserveWhiteSpace = false;
	$dom->formatOutput = true;
	$dom->loadXML($formatedXML);
	$formatedXML = $dom->saveXML();

	$fp = fopen($fname,'w+');
	fwrite($fp, $formatedXML.PHP_EOL);
	fclose($fp);
	printf("".PHP_EOL);
	printf("ACTUALIZANDO EL REPOSITORIO CON LA INFORMACION DEL NUEVO ARCHIVO COMPS.XML".PHP_EOL);
	system("createrepo -g $fname $crtrppath");

}else {
	printf('The file '.$fname.' does not exist.'.PHP_EOL);
}


function arraymaker_rpms($path){
$rpms = glob($path."/*.rpm");
$endrpms = count($rpms)-1;
$bar0 = new Console_ProgressBar('[%bar%] %percent%', '=>', ' ', 80, $endrpms);
date_default_timezone_set('America/Guayaquil');
//echo date('h:i:s') . "\n";
$inidate = date("Y-d-m H:i:s");
	for ($rpm = 0; $rpm < count($rpms); $rpm++){
		$parse = pathinfo($rpms[$rpm]);
		$resultname = exec("sed 's/-[^-]*-[^-]*$//' <<< ".$parse['basename']);
		$resultname = trim($resultname);
		$armpsT[] = $resultname;
		$bar0->update($rpm);
	}
	//echo date('h:i:s') . "\n";
$enddate = date("Y-d-m H:i:s");
echo "\n";
echo "Han pasado ".dateDiff($inidate, $enddate) . "\n";
echo "\n";

return $armpsT;
}

function dateDiff($time1, $time2, $precision = 6) {
    // If not numeric then convert texts to unix timestamps
    if (!is_int($time1)) {
      $time1 = strtotime($time1);
    }
    if (!is_int($time2)) {
      $time2 = strtotime($time2);
    }

    // If time1 is bigger than time2
    // Then swap time1 and time2
    if ($time1 > $time2) {
      $ttime = $time1;
      $time1 = $time2;
      $time2 = $ttime;
    }

    // Set up intervals and diffs arrays
    $intervals = array('year','month','day','hour','minute','second');
    $diffs = array();

    // Loop thru all intervals
    foreach ($intervals as $interval) {
      // Create temp time from time1 and interval
      $ttime = strtotime('+1 ' . $interval, $time1);
      // Set initial values
      $add = 1;
      $looped = 0;
      // Loop until temp time is smaller than time2
      while ($time2 >= $ttime) {
        // Create new temp time from time1 and interval
        $add++;
        $ttime = strtotime("+" . $add . " " . $interval, $time1);
        $looped++;
      }

      $time1 = strtotime("+" . $looped . " " . $interval, $time1);
      $diffs[$interval] = $looped;
    }

    $count = 0;
    $times = array();
    // Loop thru all diffs
    foreach ($diffs as $interval => $value) {
      // Break if we have needed precission
      if ($count >= $precision) {
 break;
      }
      // Add value and interval
      // if value is bigger than 0
      if ($value > 0) {
 // Add s if value is not 1
 if ($value != 1) {
   $interval .= "s";
 }
 // Add value and interval to times array
 $times[] = $value . " " . $interval;
 $count++;
      }
    }

    // Return string with times
    return implode(", ", $times);
  }

?>
