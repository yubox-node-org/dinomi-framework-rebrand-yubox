<?php
/* vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
  Codificación: UTF-8
  +----------------------------------------------------------------------+
  | Elastix version 0.5                                                  |
  | http://www.elastix.com                                               |
  +----------------------------------------------------------------------+
  | Copyright (c) 2006 Palosanto Solutions S. A.                         |
  +----------------------------------------------------------------------+
  | Cdla. Nueva Kennedy Calle E 222 y 9na. Este                          |
  | Telfs. 2283-268, 2294-440, 2284-356                                  |
  | Guayaquil - Ecuador                                                  |
  | http://www.palosanto.com                                             |
  +----------------------------------------------------------------------+
  | The contents of this file are subject to the General Public License  |
  | (GPL) Version 2 (the "License"); you may not use this file except in |
  | compliance with the License. You may obtain a copy of the License at |
  | http://www.opensource.org/licenses/gpl-license.php                   |
  |                                                                      |
  | Software distributed under the License is distributed on an "AS IS"  |
  | basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See  |
  | the License for the specific language governing rights and           |
  | limitations under the License.                                       |
  +----------------------------------------------------------------------+
  | The Original Code is: Elastix Open Source.                           |
  | The Initial Developer of the Original Code is PaloSanto Solutions    |
  +----------------------------------------------------------------------+
  $Id: default.conf.php,v 1.1.1.1 2007/07/06 21:31:56 gcarrillo Exp $ */

global $arrConf;

// Lo siguiente asume que no se debe preservar ningún valor anterior
$arrConf = array(
    'basePath'                      =>  realpath(dirname(__FILE__).'/..'),
    'theme'                         =>  'default',
    'language'                      =>  'en',
    'elastix_dbdir'                 =>  '/var/www/db',
    'elastix_dsn'                   =>  array(),

    /* La siguiente lista define los módulos provistos por el framework que deben
     * estar siempre disponibles sin importar el estado del menú. Estos módulos deben
     * funcionar únicamente con requerimientos AJAX, y para consistencia, todo
     * requerimiento a un módulo listado aquí debe usar rawmode=yes.
     * El módulo _elastixutils sirve para contener las utilidades json que
     * atienden requerimientos de varios widgets de la interfaz Elastix. Todo
     * requerimiento nuevo que no sea un módulo debe de agregarse en _elastixutils.
     * El módulo registration atiende las funcionalidades de registro de Elastix.
     * El módulo _elastixpanel redirige la petición al panel indicado por el parámetro panel.*/
    'elx_framework_globalmodules'   =>  array('_elastixutils', 'registration', '_elastixpanel'),
);

// Fuentes de datos heredadas
foreach (array('acl', 'settings', 'menu', 'samples') as $k) {
    $arrConf['elastix_dsn'][$k] = "sqlite3:///{$arrConf['elastix_dbdir']}/{$k}.db";
}

// Oportunidad para redefinir elementos de la configuración global
$customdir = $arrConf['basePath'].'/configs.d';
if (is_dir($customdir) && is_readable($customdir)) {
    foreach (glob($customdir.'/*.conf.php') as $f) {
        if (is_readable($f)) include_once($f);
    }
}

// Los siguientes elementos requieren acceso a la base de datos
if (!isset($arrConf['mainTheme'])) $arrConf['mainTheme'] = load_theme($arrConf['basePath']."/");
if (!isset($arrConf['elastix_version'])) $arrConf['elastix_version'] = load_version_elastix($arrConf['basePath']."/");
