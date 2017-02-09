<?php
class Panel_Testpanel2
{
    static function templateContent($smarty, $module_name)
    {
        $sDirScript = dirname($_SERVER['SCRIPT_FILENAME']);
        $local_templates_dir = "$sDirScript/panels/$module_name/tpl";

        $smarty->assign('CONTENIDO_DINAMICO', _tr('Test Content'));
        $smarty->assign('BTN_TESTPANEL', _tr('Test Button'));
        $smarty->assign('PANEL_NAME', $module_name);
        return array(
            'title'     =>  _tr('Test Title'),
            'content'   =>  $smarty->fetch("$local_templates_dir/test.tpl"),
            'iconclass' =>  'fa fa-paw',
            //'icon'      =>  'images/application_link.png',
        );

    }

    static function handleJSON_algo($smarty, $module_name)
    {
        $json = new Services_JSON();
        Header('Content-Type: application/json');
        return $json->encode(array(
            'action'    =>  'success',
            'data'      =>  'data from '.__METHOD__,
        ));
    }
}
