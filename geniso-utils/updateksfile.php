#!/usr/bin/php
<?php
$user_home="/home/".get_current_user();
$output_path=$user_home."/";
//var_dump($argv);
//var_dump($argc);
if (PHP_SAPI === 'cli'){
	if ( "$argc" <> "1"){
		exit("Use: $argv[0] nameoffile");
	}
}

$ksFileTemplate = "/home/palosanto/kickstart_build/Dinomi_Pelado_10022017/ks/anaconda-ks.cfg";

$path = "/home/palosanto/kickstart_build/Dinomi_Pelado_10022017/Dinomi";

$ksFile = file($ksFileTemplate);
$nini = findPckg($ksFile, "0");
printf($nini.PHP_EOL);
$nini = $nini + 1;
printf($nini.PHP_EOL);

$nend = findPckg($ksFile, "1");
printf($nend.PHP_EOL);
$nend = $nend - 1;
printf($nend.PHP_EOL);
printf("Se borra el archivo desde la linea $nini hasta la linea $nend".PHP_EOL);
system("sed -i $ksFileTemplate -re '$nini,$nend d'");

//Insertar la actualizacion

$pkgsarr = arraymaker_rpms($path);
//var_dump($pkgsarr);


$ksFile = file($ksFileTemplate);
$nini = findPckg($ksFile, "0");
printf("\n$nini".PHP_EOL);


foreach ($pkgsarr as $linepkg){
	//printf($linepkg.PHP_EOL);
	array_splice($ksFile,$nini,0,$linepkg);	//investigar a fondo el splice...
}

$ksFile = array_values($ksFile); //array values no es el problema de la inverción

file_put_contents($ksFileTemplate,implode($ksFile));


function findPckg($file,$iniorend){
	if (is_array($file)){
		for( $i = 0; $i < count($file); $i++){
			$lineFile = $file[$i];
			//$ws=trim($lol);
			//%packages --ignoremissing
			switch($iniorend){
				case "0":
					$pattern="/\%(packages+)/";
				break;

				case "1":
					$pattern="/\%(end+)/";
				break;
			}
			
			if (preg_match($pattern,$lineFile)){
				$num=$i+1;
				return $num;
			}else{
				//echo("No se encontro");
			}
		}
	}else{
			echo("No es un array");
	}		
}

function arraymaker_rpms($path){
$rpms = glob($path."/*.rpm");
	foreach($rpms as $p){
		$parse = pathinfo($p);
		$resultname = exec("sed 's/-[^-]*-[^-]*$//' <<< ".$parse['basename']);
		$resultname = trim($resultname);
		$armpsT[] = "$resultname\n";
	}
return $armpsT;
}

function handlingErrors($val){
    if ($val <> FALSE){
        exit("\nOcurrio un error\n");
    }else{
        echo ("\nSe cumplio la acción correctamente\n");
    }
}
?>
