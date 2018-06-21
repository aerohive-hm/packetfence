pvcreate /dev/sdb
vgextend VolGroup00 /dev/sdb
lvextend /dev/VolGroup00/LogVol00 /dev/sdb
xfs_growfs /
