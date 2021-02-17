#!/bin/bash

# Se requiere especificar la versión de empaquetamiento a usar para encriptar
# TODO: parsearla del archivo debian/changelog cuando ya exista
if [ "x$1" == "x" ] ; then
    echo "Se requiere versión de DINOMI Framework a empaquetar (por ejemplo 1.0.0)"
    exit 1
fi
DINOMIVER=$1
TGZ=dinomi-framework.tar.gz

if [ ! -e $TGZ ] ; then
    echo "No se encuentra archivo de tarball $TGZ !"
    exit 1
fi

DEB_DIRNAME=dinomi-framework-$DINOMIVER
DEB_TGZ=dinomi-framework_$DINOMIVER.orig.tar.gz

tar -xzf $TGZ
mv dinomi-framework/framework/setup/build/debian dinomi-framework/
mv dinomi-framework $DEB_DIRNAME
tar -czf $DEB_TGZ $DEB_DIRNAME/
rm -rf $DEB_DIRNAME/
