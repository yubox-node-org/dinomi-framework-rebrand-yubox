<?php
class Panel_Testpanel
{
    static function templateContent($module_name, $smarty, $local_templates_dir, $oPaloConsola, $estado)
    {
        $smarty->assign('CONTENIDO_DINAMICO', _tr('Test Content'));
        $smarty->assign('BTN_TESTPANEL', _tr('Test Button'));
        return array(
            'title'     =>  _tr('Test Title'),
            'content'   =>  $smarty->fetch("$local_templates_dir/test.tpl"),
        );

    }

    static function handleJSON_algo($module_name, $smarty, $local_templates_dir, $oPaloConsola, $estado)
    {
        $json = new Services_JSON();
        Header('Content-Type: application/json');
        return $json->encode(array(
            'action'    =>  'success',
            'data'      =>  'data from '.__METHOD__,
        ));
    }
}

?>