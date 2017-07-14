#!/usr/bin/env bash
#
# Created on 2017/6/28
#
# @author: zhujin

NAME=$1
VER=$2
SDIR=$3
DDIR=$4

if [ $# -ne 4 ];then
    echo "Usage: ./pkgs.sh pkg_name pkg_version pkg_source pkg_install_dir"
    exit 1
fi

fpm -C ${SDIR} -s dir -t rpm -n ${NAME} -v ${VER} -f -p /data/vhosts/example.com/pkgs ${DDIR}

rsync -avzP /data/vhosts/example.com/pkgs/${NAME}-${VER}-1.x86_64.rpm \
    xcloud@example.com::xcloud/ \
    --password-file=/etc/rsync.pass
