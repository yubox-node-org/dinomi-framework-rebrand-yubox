<?php
$dsn_elx4_mysql = generarDSNSistema('elx4', 'elxframework', $arrConf['basePath']."/");
foreach (array('acl', 'settings', 'menu') as $k) {
    $arrConf['elastix_dsn'][$k] = $dsn_elx4_mysql;
}

