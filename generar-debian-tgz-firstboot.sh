#!/bin/bash

GIT_PREFIX=dinomi-firstboot
TREE_ISH=DINOMI_ISO

# Se requiere especificar la versión de empaquetamiento a usar para encriptar
# TODO: parsearla del archivo debian/changelog cuando ya exista
if [ "x$1" == "x" ] ; then
    echo "Se requiere versión de dinomi-firstboot a empaquetar (por ejemplo 1.0.0)"
    exit 1
fi
DINOMIVER=$1
TGZ=$GIT_PREFIX.tar.gz

if [ "$2" != "" ] ; then
    TREE_ISH=$2
fi

# Asegurar directorio raíz del proyecto
cd `dirname $0`

echo "Borrando tar.gz previo sin encriptar ..."
rm -f $TGZ

echo "Preparando tarball con fuente de la rama $TREE_ISH ..."
git archive --format=tar.gz --prefix=$GIT_PREFIX/ --output=$TGZ $TREE_ISH apps/core/dinomi-firstboot/

DEB_DIRNAME="$GIT_PREFIX-$DINOMIVER"
DEB_TGZ="$GIT_PREFIX"_$DINOMIVER.orig.tar.gz

echo "Preparando $DEB_DIRNAME hacia $DEB_TGZ ..."

tar -xzf $TGZ
mv `find dinomi-firstboot/ -name debian` dinomi-firstboot/
mv $GIT_PREFIX $DEB_DIRNAME
tar -czf $DEB_TGZ $DEB_DIRNAME/
rm -rf $DEB_DIRNAME/
