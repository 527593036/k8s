#!/bin/bash

data_dev={{ LVMDEV }}

m=`df -h | grep "^${data_dev}" | awk '{print $NF}'`
if [ "X${m}" != "X" ];then
    umount ${m} 
    echo d > /tmp/.fdisk.tmp
    echo w >> /tmp/.fdisk.tmp
    fdisk ${data_dev} < /tmp/.fdisk.tmp 
fi

pvcreate -y ${data_dev}
vgcreate docker ${data_dev}
lvcreate -y --wipesignatures y -n thinpool docker -l 95%VG
lvcreate -y  --wipesignatures y -n thinpoolmeta docker -l 1%VG
lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta
# need /etc/lvm/profile/docker-thinpool.profile
lvchange --metadataprofile docker-thinpool docker/thinpool
lvs -o+seg_monitor
