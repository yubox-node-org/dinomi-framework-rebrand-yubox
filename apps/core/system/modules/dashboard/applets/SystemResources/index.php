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
  $Id: index.php,v 1.1 2007/01/09 23:49:36 alex Exp $
*/
require_once "libs/paloSantoGraphImage.lib.php";

class Applet_SystemResources
{
    function handleJSON_getContent($smarty, $module_name, $appletlist)
    {
        $respuesta = array(
            'status'    =>  'success',
            'message'   =>  '(no message)',
        );

        $smarty->assign(array(
            'LABEL_CPU'         =>  _tr('CPU'),
            'LABEL_RAM'         =>  _tr('RAM'),
            'LABEL_SWAP'        =>  _tr('SWAP'),
            'LABEL_CPUINFO'     =>  _tr('CPU Info'),
            'LABEL_UPTIME'      =>  _tr('Uptime'),
            'LABEL_CPUSPEED'    =>  _tr('CPU Speed'),
            'LABEL_MEMORYUSE'   =>  _tr('Memory usage'),
        ));

        $status = $this->_recolectarCargaSistema($module_name);

        $cpuinfo = $this->getCPUInfo();
        $speed = number_format($cpuinfo['CpuMHz'], 2)." MHz";
        $cpu_info = $cpuinfo['CpuModel'];

        //MEMORY USAGE
        $inf2 = number_format($status['MemTotal']/1024, 2)." Mb";

        //SWAP USAGE
        $inf3 = number_format($status['SwapTotal']/1024, 2)." Mb";

        //UPTIME
        $upfields = array();
        $up = $this->getUptime(); // Segundos de actividad desde arranque
        $upfields[] = $up % 60; $up = ($up - $upfields[0]) / 60;
        $upfields[] = $up % 60; $up = ($up - $upfields[1]) / 60;
        $upfields[] = $up % 24; $up = ($up - $upfields[2]) / 24;
        $upfields[] = $up;

        $uptime = $upfields[1].' '._tr('minute(s)');
        if ($upfields[2] > 0) $uptime = $upfields[2].' '._tr('hour(s)').' '.$uptime;
        if ($upfields[3] > 0) $uptime = $upfields[3].' '._tr('day(s)').' '.$uptime;

        $smarty->assign(array(
            'cpu_info'      =>  $cpu_info,
            'uptime'        =>  $uptime,
            'speed'         =>  $speed,
            'memtotal'      =>  $inf2,
            'swaptotal'     =>  $inf3,
        ));
        $smarty->assign($this->_formatGauges($status['cpugauge'], $status['memgauge'], $status['swapgauge']));
        $local_templates_dir = dirname($_SERVER['SCRIPT_FILENAME'])."/modules/$module_name/applets/SystemResources/tpl";
        $respuesta['html'] = $smarty->fetch("$local_templates_dir/system_resources.tpl");

        $json = new Services_JSON();
        Header('Content-Type: application/json');
        return $json->encode($respuesta);
    }

    function handleJSON_updateStatus($smarty, $module_name, $appletlist)
    {
        $respuesta['status'] = $this->_recolectarCargaSistema($module_name);
        unset($respuesta['status']['MemTotal']);
        unset($respuesta['status']['SwapTotal']);
        $json = new Services_JSON();
        Header('Content-Type: application/json');
        return $json->encode($respuesta);
    }

    private function _recolectarCargaSistema($module_name)
    {
        $cpu_b = $this->obtener_muestra_actividad_cpu();
        if (isset($_SESSION[$module_name]['cpusample'])) {
            $cpu_a = $_SESSION[$module_name]['cpusample'];
        } else {
            $cpu_a = $cpu_b;
            /* Se cierra la sesión para quitar el candado sobre la sesión y permitir
             * que otras operaciones ajax puedan funcionar. */
            session_commit();

            usleep(200000);
            $cpu_b = $this->obtener_muestra_actividad_cpu();
            @session_start();
        }
        $fraction_cpu_used = $this->calcular_carga_cpu_intervalo($cpu_a, $cpu_b);
        $_SESSION[$module_name]['cpusample'] = $cpu_b;

        $respuesta = array(
            'status'    =>  'success',
            'message'   =>  '(no message)',
        );

        $meminfo = $this->getMemInfo();
        $fraction_mem_used = ($meminfo['MemTotal'] - $meminfo['MemFree'] - $meminfo['Cached'] - $meminfo['MemBuffers']) / $meminfo['MemTotal'];
        $fraction_swap_used = ($meminfo['SwapTotal'] > 0) ? ($meminfo['SwapTotal'] - $meminfo['SwapFree']) / $meminfo['SwapTotal'] : 0.0;

        return array(
            'cpugauge'  =>  $fraction_cpu_used,
            'memgauge'  =>  $fraction_mem_used,
            'swapgauge' =>  $fraction_swap_used,
            'MemTotal'  =>  $meminfo['MemTotal'],
            'SwapTotal' =>  $meminfo['SwapTotal'],
        );
    }

    private function _formatGauges($fraction_cpu_used, $fraction_mem_used, $fraction_swap_used)
    {
        return array(
            'cpugauge'      =>  array(
                'height_used'   =>  (int)(100.0 * $fraction_cpu_used),
                'height_free'   =>  100 - (int)(100.0 * $fraction_cpu_used),
                'fraction'      =>  $fraction_cpu_used,
                'percent'       =>  number_format($fraction_cpu_used * 100.0, 1),
            ),
            'memgauge'      =>  array(
                'height_used'   =>  (int)(100.0 * $fraction_mem_used),
                'height_free'   =>  100 - (int)(100.0 * $fraction_mem_used),
                'fraction'      =>  $fraction_mem_used,
                'percent'       =>  number_format(100.0 * $fraction_mem_used, 1),
            ),
            'swapgauge'      =>  array(
                'height_used'   =>  (int)(100.0 * $fraction_swap_used),
                'height_free'   =>  100 - (int)(100.0 * $fraction_swap_used),
                'fraction'      =>  $fraction_swap_used,
                'percent'       =>  number_format(100.0 * $fraction_swap_used, 1),
            ),
        );
    }

    private function getMemInfo()
    {
        $arrInfo = array(
            'MemTotal'      =>  0,
            'MemFree'       =>  0,
            'MemBuffers'    =>  0,
            'SwapTotal'     =>  0,
            'SwapFree'      =>  0,
            'Cached'        =>  0,
        );
        foreach (file('/proc/meminfo') as $linea) {
            $regs = NULL;
            if (preg_match('/^(\w+):\s+(\d+) kB/', $linea, $regs)) {
                if (isset($arrInfo[$regs[1]])) $arrInfo[$regs[1]] = $regs[2];
            }
        }
        return $arrInfo;
    }

    private function getCPUInfo()
    {
        $arrInfo = array(
            'CpuModel'      =>  '(unknown)',
            'CpuVendor'     =>  '(unknown)',
            'CpuMHz'        =>  0.0,
        );
        foreach (file('/proc/cpuinfo') as $linea) {
            $regs = NULL;
            if (preg_match('/^(.+?)\s*:\s*(.+)/', $linea, $regs)) {
                $regs[1] = trim($regs[1]);
                $regs[2] = trim($regs[2]);
                if ($regs[1] == 'model name' || $regs[1] == 'Processor')
                    $arrInfo['CpuModel'] = $regs[2];
                if ($regs[1] == 'vendor_id')
                    $arrInfo['CpuVendor'] = $regs[2];
                if ($regs[1] == 'cpu MHz')
                    $arrInfo['CpuMHz'] = $regs[2];
            }
        }
        return $arrInfo;
    }

    private function getUptime()
    {
        $btime = NULL;
        foreach (file('/proc/stat') as $linea) {
            if (strpos($linea, 'btime ') === 0) {
                $t = explode(' ', $linea);
                $btime = $t[1];
                break;
            }
        }
        return $this->_info_sistema_diff_stat($btime, time());
    }

    private function obtener_muestra_actividad_cpu()
    {
        if (!function_exists('_info_sistema_linea_cpu')) {
            function _info_sistema_linea_cpu($s) { return (strpos($s, 'cpu ') === 0); }
        }
        $cpuline = array_filter(file('/proc/stat', FILE_IGNORE_NEW_LINES), '_info_sistema_linea_cpu');
        $muestra = preg_split('/\s+/', array_shift($cpuline));
        array_shift($muestra);
        return $muestra;
    }

    private function calcular_carga_cpu_intervalo($m1, $m2)
    {
        $diffmuestra = array_map(array($this, '_info_sistema_diff_stat'), $m1, $m2);
        $cpuActivo = $diffmuestra[0] + $diffmuestra[1] + $diffmuestra[2] + $diffmuestra[4] + $diffmuestra[5] + $diffmuestra[6];
        $cpuTotal = $cpuActivo + $diffmuestra[3];
        return ($cpuTotal > 0) ? $cpuActivo / $cpuTotal : 0;
    }

    /* Método para poder realizar la resta de dos cantidades enteras que pueden
     * no caber en un entero de PHP, pero cuya diferencia es pequeña y puede
     * caber en el mismo entero. */
    private function _info_sistema_diff_stat($a, $b)
    {
        $aa = str_split("$a");
        $bb = str_split("$b");
        while (count($aa) < count($bb)) array_unshift($aa, '0');
        while (count($aa) > count($bb)) array_unshift($bb, '0');
        while (count($aa) > 0 && $aa[0] == $bb[0]) {
            array_shift($aa);
            array_shift($bb);
        }
        if (count($aa) <= 0) return 0;
        $a = implode('', $aa); $b = implode('', $bb);
        return (int)$b - (int)$a;
    }

    function handleJSON_graphic($smarty, $module_name, $appletlist)
    {
        $value = $_REQUEST['percent'];
        if (!is_numeric($value)) return;

        $size = '140,140';

        $result = array();
        $result['ATTRIBUTES'] = array('TYPE'=>'gauge','SIZE'=>$size);  // bar => gauge
        $result['MESSAGES'] = array('ERROR'=>'Error','NOTHING_SHOW'=>'Nada que mostrar');

        $temp = array();
        $temp['DAT_1'] = array('VALUES'=>array("value"=>$value));
        $result['DATA'] = $temp;

        displayGraphResult($result);
    }
}

?>