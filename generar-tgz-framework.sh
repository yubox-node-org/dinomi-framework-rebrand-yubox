#!/bin/bash

GIT_PREFIX=elastix-framework
TREE_ISH=4.0.0

if [ "$1" != "" ] ; then
    TREE_ISH=$1
fi

# Asegurar directorio raíz del proyecto
cd `dirname $0`

echo "Borrando tar.gz previo sin encriptar ..."
rm -f $GIT_PREFIX.tar.gz

echo "Preparando tarball con fuente de la rama $TREE_ISH ..."
git archive --format=tar.gz --prefix=$GIT_PREFIX/ --output=$GIT_PREFIX.tar.gz $TREE_ISH framework/ additionals/
